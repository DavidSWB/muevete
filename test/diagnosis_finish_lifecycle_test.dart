import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosis.dart';
import 'package:muevete/features/diagnosis/domain/entities/diagnosisState.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:muevete/features/diagnosis/domain/repositories/questions_repository.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_repository_providers.dart';
import 'package:muevete/features/diagnosis/presentation/providers/questions_repository_providers.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';

void main() {
  late _ControlledDiagnosisRepository diagnosisRepository;
  late int profileBuilds;

  ProviderContainer makeContainer() {
    diagnosisRepository = _ControlledDiagnosisRepository();
    profileBuilds = 0;
    final container = ProviderContainer(
      overrides: [
        questionsRepositoryProvider.overrideWithValue(_FixedQuestions()),
        diagnosisRepositoryProvider.overrideWithValue(diagnosisRepository),
        profileProvider.overrideWith(() => _FakeProfile(() => profileBuilds++)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<ProviderSubscription<AsyncValue<DiagnosisState>>> answerAll(
    ProviderContainer container,
  ) async {
    // Stands in for DiagnosisScreen, the provider's only listener.
    final screen = container.listen(diagnosisProvider, (_, _) {});
    await container.read(diagnosisProvider.future);
    final notifier = container.read(diagnosisProvider.notifier);
    for (final question in _questions) {
      notifier.answer(question.id, 2);
    }
    return screen;
  }

  test(
    'finish completes when the screen goes away while the diagnosis is saving',
    () async {
      final container = makeContainer();
      final screen = await answerAll(container);

      final finishing = container.read(diagnosisProvider.notifier).finish();
      await Future<void>.delayed(Duration.zero);
      expect(diagnosisRepository.saved, hasLength(1));

      // Saving the stats makes the onboarding gate swap DiagnosisScreen for
      // ProgramSetupScreen before the write returns.
      screen.close();
      await container.pump();

      expect(profileBuilds, 0, reason: 'the profile waits for the save');
      diagnosisRepository.completeSave();

      await expectLater(finishing, completes);
      // Nothing watches the profile here, so reading its notifier builds it
      // and refresh() then rebuilds it with the saved stats.
      expect(profileBuilds, 2, reason: 'the profile is reloaded after the save');
    },
  );

  test('finish still refreshes the profile while the screen stays', () async {
    final container = makeContainer();
    await answerAll(container);
    container.listen(profileProvider, (_, _) {});
    await container.read(profileProvider.future);
    expect(profileBuilds, 1);

    final finishing = container.read(diagnosisProvider.notifier).finish();
    await Future<void>.delayed(Duration.zero);
    diagnosisRepository.completeSave();

    await expectLater(finishing, completes);
    expect(profileBuilds, 2);
  });

  test('the diagnosis provider is disposed once finish is done', () async {
    final container = makeContainer();
    final screen = await answerAll(container);

    final finishing = container.read(diagnosisProvider.notifier).finish();
    await Future<void>.delayed(Duration.zero);
    screen.close();
    diagnosisRepository.completeSave();
    await finishing;
    await container.pump();

    expect(container.exists(diagnosisProvider), isFalse);
  });

  test('a failed save still reaches the caller', () async {
    final container = makeContainer();
    final screen = await answerAll(container);

    final finishing = container.read(diagnosisProvider.notifier).finish();
    await Future<void>.delayed(Duration.zero);
    screen.close();
    await container.pump();
    diagnosisRepository.failSave(StateError('offline'));

    await expectLater(finishing, throwsA(isA<StateError>()));
    expect(profileBuilds, 0);
  });
}

const _questions = [
  Question(
    id: 'q1',
    question: {'es': 'Shoulder mobility', 'en': 'Shoulder mobility'},
    categories: ['shoulder', 'hip'],
    imagePath: '',
    options: [QuestionOption(text: {'es': 'Yes', 'en': 'Yes'}, value: 2)],
    order: 1,
  ),
  Question(
    id: 'q2',
    question: {'es': 'Knee and ankle mobility', 'en': 'Knee and ankle mobility'},
    categories: ['knee', 'ankle'],
    imagePath: '',
    options: [QuestionOption(text: {'es': 'Yes', 'en': 'Yes'}, value: 2)],
    order: 2,
  ),
];

class _FixedQuestions implements QuestionsRepository {
  @override
  Future<List<Question>> getQuestions() async => _questions;
}

class _ControlledDiagnosisRepository implements DiagnosisRepository {
  final List<Diagnosis> saved = [];
  Completer<void> _save = Completer<void>();

  void completeSave() => _save.complete();

  void failSave(Object error) => _save.completeError(error);

  @override
  Future<void> saveDiagnosis(Diagnosis diagnosis) {
    saved.add(diagnosis);
    _save = Completer<void>();
    return _save.future;
  }
}

class _FakeProfile extends Profile {
  _FakeProfile(this._onBuild);

  final void Function() _onBuild;

  @override
  Future<UserModel> build() async {
    _onBuild();
    return const UserModel(id: 'user-1', email: 'user@example.com', username: 'user');
  }
}
