// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(diagnosisRepository)
final diagnosisRepositoryProvider = DiagnosisRepositoryProvider._();

final class DiagnosisRepositoryProvider
    extends
        $FunctionalProvider<
          DiagnosisRepository,
          DiagnosisRepository,
          DiagnosisRepository
        >
    with $Provider<DiagnosisRepository> {
  DiagnosisRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diagnosisRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diagnosisRepositoryHash();

  @$internal
  @override
  $ProviderElement<DiagnosisRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiagnosisRepository create(Ref ref) {
    return diagnosisRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiagnosisRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiagnosisRepository>(value),
    );
  }
}

String _$diagnosisRepositoryHash() =>
    r'6655e3cc8201d5a24b2e01a8dbad1afe21b251c2';
