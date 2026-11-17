import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:muevete/features/diagnosis/domain/repositories/questions_repository.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_repository_providers.dart';
import 'package:muevete/features/diagnosis/presentation/providers/questions_repository_providers.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/training/domain/entities/exercise.dart';
import 'package:muevete/features/training/domain/entities/exercise_level.dart';
import 'package:muevete/features/training/domain/entities/exercise_reference.dart';
import 'package:muevete/features/training/domain/entities/exercise_type.dart';
import 'package:muevete/features/training/domain/entities/exercise_variant.dart';
import 'package:muevete/features/training/domain/entities/plan_day.dart';
import 'package:muevete/features/training/domain/entities/progessionrules.dart';
import 'package:muevete/features/training/domain/entities/training_plan.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';
import 'package:muevete/features/training/domain/repositories/exercise_repository.dart';
import 'package:muevete/features/training/domain/repositories/progression_repository.dart';
import 'package:muevete/features/training/domain/repositories/training_repository.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/features/training/domain/services/variantSelector.dart';
import 'package:muevete/features/training/domain/services/workout_builder.dart';
import 'package:muevete/features/training/presentation/providers/training_repository_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_builder_provider.dart';
import 'package:muevete/features/training/presentation/providers/workout_controller.dart';
import 'package:timezone/timezone.dart' as tz;

/// The training tab stays mounted in the main screen's IndexedStack, so its
/// workout is never disposed. Retaking the diagnosis must still change the
/// variants without restarting the app.
void main() {
  setUp(() => NotificationScheduler.setAdapterForTesting(_SilentAdapter()));
  tearDown(NotificationScheduler.resetForTesting);

  late _Profiles profiles;
  late _CountingBuilder builder;

  ProviderContainer makeContainer() {
    profiles = _Profiles();
    builder = _CountingBuilder();
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profiles),
        trainingRepositoryProvider.overrideWithValue(_FixedPlan()),
        workoutBuilderProvider.overrideWithValue(builder),
        questionsRepositoryProvider.overrideWithValue(_FixedQuestions()),
        diagnosisRepositoryProvider.overrideWithValue(_Diagnoses(profiles)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  List<String> variantIds(Workout workout) =>
      workout.exercises.map((e) => e.exercise.variantId).toList();

  /// Answers the one diagnosis question with [value] and finishes, as the
  /// diagnosis screen does when it is opened from the progress screen.
  Future<void> retakeDiagnosis(ProviderContainer container, int value) async {
    final screen = container.listen(diagnosisProvider, (_, _) {});
    await container.read(diagnosisProvider.future);
    final notifier = container.read(diagnosisProvider.notifier);
    notifier.answer('q1', value);
    await notifier.finish();
    screen.close();
  }

  test('retaking the diagnosis updates the loaded workout', () async {
    final container = makeContainer();
    // The training tab and the home screen keep both providers alive.
    final trainingTab = container.listen(workoutControllerProvider, (_, _) {});
    addTearDown(trainingTab.close);
    final home = container.listen(profileProvider, (_, _) {});
    addTearDown(home.close);

    final before = await container.read(workoutControllerProvider.future);
    expect(variantIds(before), ['push-beginner', 'row-beginner']);

    await retakeDiagnosis(container, 5);
    expect(profiles.current.stats!.shoulder, 5);

    final after = await container.read(workoutControllerProvider.future);
    expect(variantIds(after), ['push-intermediate', 'row-advanced']);
    expect(builder.lastStats!.shoulder, 5);
    expect(builder.builds, 2);
  });

  test('a lower diagnosis brings the easier variants back', () async {
    final container = makeContainer();
    profiles.current = profiles.current.copyWith(
      stats: const UserStats(knee: 5, hip: 5, ankle: 5, shoulder: 5),
    );
    final trainingTab = container.listen(workoutControllerProvider, (_, _) {});
    addTearDown(trainingTab.close);

    expect(
      variantIds(await container.read(workoutControllerProvider.future)),
      ['push-intermediate', 'row-advanced'],
    );

    await retakeDiagnosis(container, 1);

    expect(
      variantIds(await container.read(workoutControllerProvider.future)),
      ['push-beginner', 'row-beginner'],
    );
  });

  test('profile changes that keep the stats keep the workout', () async {
    final container = makeContainer();
    final trainingTab = container.listen(workoutControllerProvider, (_, _) {});
    addTearDown(trainingTab.close);
    final loaded = await container.read(workoutControllerProvider.future);

    // Unlocking a badge and reloading the profile, as recording an activity
    // does, must not rebuild the workout and lose the ticked sets.
    container.read(profileProvider.notifier).markBadgesUnlocked({'first'});
    await container.read(profileProvider.notifier).refresh();
    await container.pump();

    expect(builder.builds, 1);
    expect(
      identical(await container.read(workoutControllerProvider.future), loaded),
      isTrue,
    );
  });
}

final Map<String, Exercise> _exercises = {
  'deep-push-ups': _ex('deep-push-ups', 'push', ExerciseLevel.intermediate),
  'bw-rows': _ex('bw-rows', 'row', ExerciseLevel.advanced),
};

/// A shoulder exercise with a beginner variant and one harder variant.
Exercise _ex(String id, String variantPrefix, ExerciseLevel harder) {
  ExerciseVariant variant(ExerciseLevel level) => ExerciseVariant(
    variantId: '$variantPrefix-${level.name}',
    name: {'en': level.name},
    description: const {'en': ''},
    visualPath: '',
    requiredLevel: level,
  );
  return Exercise(
    exerciseId: id,
    name: {'en': id},
    type: ExerciseType.compound,
    hold: false,
    targets: const ['shoulder'],
    variants: [variant(ExerciseLevel.beginner), variant(harder)],
  );
}

const _plan = TrainingPlan(
  planId: 'plan-1',
  name: {'en': 'Plan'},
  description: {'en': 'Plan'},
  daysPerWeek: 1,
  template: [
    PlanDay(
      day: 1,
      name: {'en': 'Upper'},
      exercises: [
        ExerciseReference(exerciseId: 'deep-push-ups'),
        ExerciseReference(exerciseId: 'bw-rows'),
      ],
    ),
  ],
);

class _FixedPlan implements TrainingRepository {
  @override
  Future<TrainingPlan> getPlan(String id) async => _plan;

  @override
  Future<List<TrainingPlan>> getPlans() async => [_plan];
}

/// The real builder and selector, with the exercises above.
class _CountingBuilder extends WorkoutBuilder {
  _CountingBuilder()
    : super(
        exerciseRepository: _MapExercises(),
        progressionRepository: _FlatProgression(),
        variantSelector: Variantselector(),
      );

  int builds = 0;
  UserStats? lastStats;

  @override
  Future<Workout> buildWorkout({
    required TrainingPlan plan,
    required int day,
    required int week,
    required UserStats stats,
  }) {
    builds++;
    lastStats = stats;
    return super.buildWorkout(plan: plan, day: day, week: week, stats: stats);
  }
}

class _MapExercises implements ExerciseRepository {
  @override
  Future<Exercise> getExercise(String id) async => _exercises[id]!;
}

class _FlatProgression implements ProgressionRepository {
  @override
  Future<ProgessionRules> getRules(
    ExerciseType type,
    ExerciseLevel level,
    bool hold,
  ) async => ProgessionRules(
    id: type.name,
    cycle: const [ProgressionStep(week: 1, sets: 3, reps: 8)],
    level: level.name,
    reset: true,
    type: type.name,
  );
}

/// One question over every joint, so its answer is every joint's stat.
class _FixedQuestions implements QuestionsRepository {
  @override
  Future<List<Question>> getQuestions() async => const [
    Question(
      id: 'q1',
      question: {'es': 'Movilidad', 'en': 'Mobility'},
      categories: ['ankle', 'knee', 'hip', 'shoulder'],
      imagePath: '',
      options: [
        QuestionOption(text: {'es': 'Poco', 'en': 'Low'}, value: 1),
        QuestionOption(text: {'es': 'Mucho', 'en': 'High'}, value: 5),
      ],
      order: 1,
    ),
  ];
}

/// Writes the stats into [profiles], like the update on `users/{uid}`.
class _Diagnoses implements DiagnosisRepository {
  _Diagnoses(this.profiles);

  final _Profiles profiles;

  @override
  Future<void> saveDiagnosis(Diagnosis diagnosis) async {
    profiles.current = profiles.current.copyWith(
      stats: UserStats(
        knee: diagnosis.knee,
        hip: diagnosis.hip,
        ankle: diagnosis.ankle,
        shoulder: diagnosis.shoulder,
      ),
    );
  }
}

class _Profiles implements ProfileRepository {
  UserModel current = UserModel(
    id: 'user-1',
    email: 'user@example.com',
    username: 'user',
    stats: const UserStats(knee: 1, hip: 1, ankle: 1, shoulder: 1),
    training: UserTraining(activePlanId: 'plan-1', planStartDate: DateTime(2026)),
  );

  @override
  Future<UserModel> getProfile() async => current;

  @override
  Future<void> saveProfile(UserModel user) async => current = user;

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {}

  @override
  Future<void> createProfile(
    UserModel user, {
    int? acceptedPolicyVersion,
  }) async {}

  @override
  Future<void> unlockBadges(Set<String> badgeIds) async {}

  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) async {}
}

class _SilentAdapter extends NotificationPluginAdapter {
  @override
  Future<void> initialize({
    void Function(NotificationResponse)? onTap,
  }) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> checkPermissionStatus() async => true;

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    required UILocalNotificationDateInterpretation
    uiLocalNotificationDateInterpretation,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
