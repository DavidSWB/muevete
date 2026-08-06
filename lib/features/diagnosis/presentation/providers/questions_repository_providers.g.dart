// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questions_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questionsRepository)
final questionsRepositoryProvider = QuestionsRepositoryProvider._();

final class QuestionsRepositoryProvider
    extends
        $FunctionalProvider<
          QuestionsRepository,
          QuestionsRepository,
          QuestionsRepository
        >
    with $Provider<QuestionsRepository> {
  QuestionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuestionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestionsRepository create(Ref ref) {
    return questionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestionsRepository>(value),
    );
  }
}

String _$questionsRepositoryHash() =>
    r'10a4099df0a936dd35b552a2167419d80fa53ca3';
