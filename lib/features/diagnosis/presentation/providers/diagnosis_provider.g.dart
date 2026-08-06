// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiagnosisNotifier)
final diagnosisProvider = DiagnosisNotifierProvider._();

final class DiagnosisNotifierProvider
    extends $AsyncNotifierProvider<DiagnosisNotifier, DiagnosisState> {
  DiagnosisNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosisNotifierHash();

  @$internal
  @override
  DiagnosisNotifier create() => DiagnosisNotifier();
}

String _$diagnosisNotifierHash() => r'4fb6bd609777036a3ec738df63060932a3ba7119';

abstract class _$DiagnosisNotifier extends $AsyncNotifier<DiagnosisState> {
  FutureOr<DiagnosisState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DiagnosisState>, DiagnosisState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DiagnosisState>, DiagnosisState>,
              AsyncValue<DiagnosisState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
