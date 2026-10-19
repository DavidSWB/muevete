// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
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

  @$internal
  @override
  ProgramSetup create() => ProgramSetup();
}

String _$programSetupHash() => r'd79d7785b509b560cf43b9e292d163d632daa57b';

abstract class _$ProgramSetup extends $AsyncNotifier<List<TrainingPlan>> {
  FutureOr<List<TrainingPlan>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TrainingPlan>>, List<TrainingPlan>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TrainingPlan>>, List<TrainingPlan>>,
              AsyncValue<List<TrainingPlan>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
