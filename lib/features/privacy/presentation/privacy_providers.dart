import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/privacy/data/bundled_privacy_policy.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_consent_repository.dart';
import 'package:muevete/features/privacy/data/firestore_privacy_policy_repository.dart';
import 'package:muevete/features/privacy/data/shared_preferences_policy_notice_store.dart';
import 'package:muevete/features/privacy/domain/policy_notice_store.dart';
import 'package:muevete/features/privacy/domain/privacy_consent_repository.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_document.dart';
import 'package:muevete/features/privacy/domain/privacy_policy_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';

final privacyConsentRepositoryProvider = Provider<PrivacyConsentRepository>(
  (ref) => FirestorePrivacyConsentRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  ),
);

final privacyPolicyRepositoryProvider = Provider<PrivacyPolicyRepository>(
  (ref) => FirestorePrivacyPolicyRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  ),
);

final bundledPrivacyPolicyProvider = Provider<BundledPrivacyPolicy>(
  (ref) => BundledPrivacyPolicy(),
);

/// The published policy metadata, kept up to date while the app runs. When
/// `policies/privacy` cannot be read, the bundled version stands in as the
/// current, mandatory one, so the gate keeps working offline.
final privacyPolicyMetadataProvider = StreamProvider<PrivacyPolicyMetadata>((
  ref,
) async* {
  final bundled = await ref.watch(bundledPrivacyPolicyProvider).load();
  final fallback = BundledPrivacyPolicy.metadataFor(bundled);

  Stream<PrivacyPolicyMetadata> remote;
  try {
    remote = ref.watch(privacyPolicyRepositoryProvider).watchMetadata();
  } catch (error, stackTrace) {
    _logFallback('metadata', error, stackTrace);
    yield fallback;
    return;
  }
  yield* remote.transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) {
        _logFallback('metadata', error, stackTrace);
        sink.add(fallback);
      },
    ),
  );
});

/// The text of the current version: the one the user reads and accepts.
/// Falls back to the bundled version when that text cannot be loaded; the
/// version number shown and stored is always the one of the text shown.
final currentPrivacyPolicyProvider = FutureProvider<PrivacyPolicyVersion>((
  ref,
) async {
  final bundled = ref.watch(bundledPrivacyPolicyProvider);
  try {
    final metadata = await ref.watch(privacyPolicyMetadataProvider.future);
    return await ref
        .watch(privacyPolicyRepositoryProvider)
        .getVersion(metadata.currentVersion);
  } catch (error, stackTrace) {
    _logFallback('text', error, stackTrace);
    return bundled.load();
  }
});

final policyNoticeStoreProvider = Provider<PolicyNoticeStore>(
  (ref) => SharedPreferencesPolicyNoticeStore(),
);

/// The version to announce on Home after a minor update the user has not
/// dismissed on this device, or null when there is nothing to announce.
/// Never fails: a problem only hides the notice.
final privacyPolicyNoticeProvider = FutureProvider<int?>((ref) async {
  try {
    final user = await ref.watch(profileProvider.future);
    // Without both records the gate asks for acceptance; there is nothing
    // to announce, so the policy is not even read.
    if (user.policyAccepted == null || user.healthDataAuthorization == null) {
      return null;
    }
    final metadata = await ref.watch(privacyPolicyMetadataProvider.future);
    final status = evaluatePrivacyPolicyStatus(
      metadata: metadata,
      policyAccepted: user.policyAccepted,
      healthDataAuthorization: user.healthDataAuthorization,
    );
    if (status != PrivacyPolicyStatus.updateNotice) return null;
    final dismissed = await ref
        .watch(policyNoticeStoreProvider)
        .dismissedVersion(user.id);
    if (dismissed != null && dismissed >= metadata.currentVersion) return null;
    return metadata.currentVersion;
  } catch (error, stackTrace) {
    developer.log(
      'Policy notice unavailable',
      name: 'muevete.privacy',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
});

void _logFallback(String what, Object error, StackTrace stackTrace) {
  developer.log(
    'Using the bundled privacy policy $what',
    name: 'muevete.privacy',
    error: error,
    stackTrace: stackTrace,
  );
}
