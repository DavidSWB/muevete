// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_training_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nextTraining)
final nextTrainingProvider = NextTrainingProvider._();

final class NextTrainingProvider
    extends $FunctionalProvider<AsyncValue<PlanDay>, PlanDay, FutureOr<PlanDay>>
    with $FutureModifier<PlanDay>, $FutureProvider<PlanDay> {
  NextTrainingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextTrainingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextTrainingHash();

  @$internal
  @override
  $FutureProviderElement<PlanDay> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlanDay> create(Ref ref) {
    return nextTraining(ref);
  }
}

String _$nextTrainingHash() => r'd7c456c6d3534e283dd7ea090aa5bc5a802259fe';
