// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: type=lint, type=warning

@ProviderFor(ProgramSetup)
final programSetupProvider = ProgramSetupProvider._();

final class ProgramSetupProvider
    extends $AsyncNotifierProvider<ProgramSetup, List<TrainingPlan>> {
  ProgramSetupProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programSetupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programSetupHash();

  @override
  ProgramSetup create() => ProgramSetup();
}

String _$programSetupHash() => r'program_setup_provider';

abstract class _$ProgramSetup extends $AsyncNotifier<List<TrainingPlan>> {
  FutureOr<List<TrainingPlan>> build();

  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TrainingPlan>>, List<TrainingPlan>>;
    final element = ref.element
        as $ClassProviderElement<
          AnyNotifier<AsyncValue<List<TrainingPlan>>, List<TrainingPlan>>,
          AsyncValue<List<TrainingPlan>>,
          Object?,
          Object?
        >;
    return element.handleCreate(ref, build);
  }
}
