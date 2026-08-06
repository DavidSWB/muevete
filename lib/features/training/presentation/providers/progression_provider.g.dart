// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(progressionRepository)
final progressionRepositoryProvider = ProgressionRepositoryProvider._();

final class ProgressionRepositoryProvider
    extends
        $FunctionalProvider<
          ProgressionRepository,
          ProgressionRepository,
          ProgressionRepository
        >
    with $Provider<ProgressionRepository> {
  ProgressionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProgressionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgressionRepository create(Ref ref) {
    return progressionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressionRepository>(value),
    );
  }
}

String _$progressionRepositoryHash() =>
    r'606541e5a7656244ca06400c88ac697a61f7d9c3';
