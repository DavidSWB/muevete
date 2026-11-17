import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/privacy/domain/consent_record.dart';
import 'package:muevete/features/privacy/domain/privacy_policy.dart';
import 'package:muevete/features/privacy/presentation/privacy_providers.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

enum OnboardingStatus {
  unauthenticated,
  noProfile,
  noPrivacyConsent,
  noDiagnosis,
  noTraining,
  complete,
}

@riverpod
Stream<OnboardingStatus> onboardingStatus(Ref ref) async* {
  final authState = ref.watch(authStateProvider);

  if (authState.isLoading) {
    return;
  }

  final user = authState.value;
  if (user == null) {
    yield OnboardingStatus.unauthenticated;
    return;
  }

  final firestore = ref.watch(firebaseFirestoreProvider);
  final trainingRepository = ref.watch(trainingRepositoryProvider);
  // Watched, so publishing a new version while the app runs re-checks the
  // user. Never fails: without Firestore the bundled version stands in.
  final policyFuture = ref.watch(privacyPolicyMetadataProvider.future);
  final policy = await policyFuture;
  if (!ref.mounted) return;
  try {
    await for (final snapshot in firestore.collection('users').doc(user.uid).snapshots()) {
      if (!snapshot.exists || snapshot.data() == null) {
        yield OnboardingStatus.noProfile;
      } else {
        final data = snapshot.data()!;
        final policyStatus = evaluatePrivacyPolicyStatus(
          metadata: policy,
          policyAccepted: ConsentRecord.fromJson(data[policyAcceptedField]),
          healthDataAuthorization: ConsentRecord.fromJson(
            data[healthDataAuthorizationField],
          ),
        );
        if (policyStatus == PrivacyPolicyStatus.mustAccept) {
          yield OnboardingStatus.noPrivacyConsent;
          continue;
        }
        final stats = data['stats'];
        if (stats == null) {
          yield OnboardingStatus.noDiagnosis;
        } else {
          final training = data['training'];
          final planId = training is Map ? training['activePlanId'] : null;

          if (planId is! String || planId.trim().isEmpty) {
            yield OnboardingStatus.noTraining;
            continue;
          }

          try {
            await trainingRepository.getPlan(planId);
          } on StateError catch (_) {
            yield OnboardingStatus.noTraining;
            continue;
          } on FormatException catch (_) {
            yield OnboardingStatus.noTraining;
            continue;
          }

          final rawSchedule = training is Map ? training['schedule'] : null;
          if (rawSchedule is! Map || rawSchedule.isEmpty) {
            yield OnboardingStatus.noTraining;
            continue;
          }
          final schedule = UserSchedule.fromJson(
            Map<String, dynamic>.from(rawSchedule),
          );
          if (schedule.days.isEmpty) {
            yield OnboardingStatus.noTraining;
            continue;
          }

          yield OnboardingStatus.complete;
        }
      }
    }
  } catch (_) {
    // Signing out cancels this stream, but the listener can still deliver
    // the permission error Firestore sends once auth is gone. Nobody listens
    // by then, so end quietly instead of leaving an unhandled error.
    if (!ref.mounted) return;
    rethrow;
  }
}

