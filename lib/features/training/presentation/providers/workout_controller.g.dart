// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutController)
final workoutControllerProvider = WorkoutControllerProvider._();

final class WorkoutControllerProvider
    extends $AsyncNotifierProvider<WorkoutController, Workout> {
  WorkoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutControllerHash();

  @$internal
  @override
  WorkoutController create() => WorkoutController();
}

String _$workoutControllerHash() => r'6b09f9767e4420c2cb333182796dcd6d8280e55c';

abstract class _$WorkoutController extends $AsyncNotifier<Workout> {
  FutureOr<Workout> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Workout>, Workout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Workout>, Workout>,
              AsyncValue<Workout>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
