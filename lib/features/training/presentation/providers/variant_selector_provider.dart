import 'package:muevete/features/training/domain/services/variantSelector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'variant_selector_provider.g.dart';

@riverpod
Variantselector variantSelector(Ref ref) {
  return Variantselector();
}