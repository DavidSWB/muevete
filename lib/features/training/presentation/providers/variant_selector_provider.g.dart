// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant_selector_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(variantSelector)
final variantSelectorProvider = VariantSelectorProvider._();

final class VariantSelectorProvider
    extends
        $FunctionalProvider<Variantselector, Variantselector, Variantselector>
    with $Provider<Variantselector> {
  VariantSelectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'variantSelectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$variantSelectorHash();

  @$internal
  @override
  $ProviderElement<Variantselector> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Variantselector create(Ref ref) {
    return variantSelector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Variantselector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Variantselector>(value),
    );
  }
}

String _$variantSelectorHash() => r'6a6490fba2192a173a1ac196563109f33be27396';
