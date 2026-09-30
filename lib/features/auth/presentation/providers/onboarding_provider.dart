import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

enum OnboardingStatus {
  unauthenticated,
  noProfile,
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
  await for (final snapshot in firestore.collection('users').doc(user.uid).snapshots()) {
    if (!snapshot.exists || snapshot.data() == null) {
      yield OnboardingStatus.noProfile;
    } else {
      final data = snapshot.data()!;
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
          yield OnboardingStatus.complete;
        } on StateError catch (_) {
          yield OnboardingStatus.noTraining;
        } on FormatException catch (_) {
          yield OnboardingStatus.noTraining;
        }
      }
    }
  }
}

