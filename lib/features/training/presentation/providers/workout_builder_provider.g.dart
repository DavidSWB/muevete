// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_builder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutBuilder)
final workoutBuilderProvider = WorkoutBuilderProvider._();

final class WorkoutBuilderProvider
    extends $FunctionalProvider<WorkoutBuilder, WorkoutBuilder, WorkoutBuilder>
    with $Provider<WorkoutBuilder> {
  WorkoutBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutBuilderHash();

  @$internal
  @override
  $ProviderElement<WorkoutBuilder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkoutBuilder create(Ref ref) {
    return workoutBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutBuilder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutBuilder>(value),
    );
  }
}

String _$workoutBuilderHash() => r'a97fd0c50d51ebe5594d07f1db29e7f6e8f512bf';
