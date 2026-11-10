import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/gamification/domain/activity_reward.dart';
import 'package:muevete/features/profile/data/firestore_profile_repository.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/entities/biological_sex.dart';
import 'package:muevete/features/profile/domain/entities/personal_info.dart';
import 'package:muevete/features/profile/domain/entities/user_model.dart';
import 'package:muevete/features/profile/domain/entities/user_notifications.dart';
import 'package:muevete/features/profile/domain/entities/user_schedule.dart';
import 'package:muevete/features/profile/domain/entities/user_stats.dart';
import 'package:muevete/features/profile/domain/entities/user_streak.dart';
import 'package:muevete/features/profile/domain/entities/user_training.dart';
import 'package:muevete/features/profile/domain/repositories/profile_repository.dart';
import 'package:muevete/features/profile/domain/services/personal_info_validator.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';
import 'package:muevete/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:muevete/l10n/app_localizations.dart';

void main() {
  group('PersonalInfoValidator', () {
    test('accepts the sign-up ranges', () {
      expect(PersonalInfoValidator.isValidAge(30), isTrue);
      expect(PersonalInfoValidator.isValidAge(120), isTrue);
      expect(PersonalInfoValidator.isValidWeightKg(70.5), isTrue);
      expect(PersonalInfoValidator.isValidHeightCm(175), isTrue);
    });

    test('rejects missing and out-of-range values', () {
      for (final age in [null, 0, -1, 121]) {
        expect(PersonalInfoValidator.isValidAge(age), isFalse, reason: '$age');
      }
      for (final weight in [null, 0.0, 401.0, double.nan, double.infinity]) {
        expect(
          PersonalInfoValidator.isValidWeightKg(weight),
          isFalse,
          reason: '$weight',
        );
      }
      for (final height in [null, 0.0, 301.0, double.nan]) {
        expect(
          PersonalInfoValidator.isValidHeightCm(height),
          isFalse,
          reason: '$height',
        );
      }
    });
  });

  group('BiologicalSex', () {
    test('stores only "Male" or "Female"', () {
      expect(BiologicalSex.male.storedValue, 'Male');
      expect(BiologicalSex.female.storedValue, 'Female');
    });

    test('reads the legacy "M" as male and unknown values as unset', () {
      expect(BiologicalSex.fromStored('Male'), BiologicalSex.male);
      expect(BiologicalSex.fromStored('M'), BiologicalSex.male);
      expect(BiologicalSex.fromStored('Female'), BiologicalSex.female);
      expect(BiologicalSex.fromStored(null), isNull);
      expect(BiologicalSex.fromStored('other'), isNull);
    });
  });

  test('withPersonalInfo replaces only the edited fields', () {
    final updated = _user.withPersonalInfo(_info);

    expect(updated.username, 'New Name');
    expect(updated.age, 31);
    expect(updated.height, 180);
    expect(updated.weight, 72.5);
    expect(updated.sex, 'Female');
    expect(updated.medicalConditions, isNull);

    expect(updated.id, _user.id);
    expect(updated.email, _user.email);
    expect(updated.createdAt, _user.createdAt);
    expect(updated.stats, same(_user.stats));
    expect(updated.training, same(_user.training));
    expect(updated.notifications, same(_user.notifications));
    expect(updated.completedWorkouts, _user.completedWorkouts);
    expect(updated.completedActiveBreaks, _user.completedActiveBreaks);
    expect(updated.streak, same(_user.streak));
    expect(updated.consistencyTrackedSince, _user.consistencyTrackedSince);
  });

  group('FirestoreProfileRepository.updatePersonalInfo', () {
    test('updates only the edited keys of the signed-in user', () async {
      final firestore = _FakeFirestore();
      final repository = FirestoreProfileRepository(
        firestore: firestore,
        auth: _FakeAuth(_FakeUser('uid-1')),
      );

      await repository.updatePersonalInfo(_info);

      expect(firestore.collectionPath, 'users');
      expect(firestore.docId, 'uid-1');
      expect(firestore.updates, [
        {
          'username': 'New Name',
          'age': 31,
          'height': 180.0,
          'weight': 72.5,
          'sex': 'Female',
          'medicalConditions': null,
        },
      ]);
    });

    test('refuses to write when nobody is signed in', () async {
      final firestore = _FakeFirestore();
      final repository = FirestoreProfileRepository(
        firestore: firestore,
        auth: _FakeAuth(null),
      );

      await expectLater(repository.updatePersonalInfo(_info), throwsException);
      expect(firestore.updates, isEmpty);
    });
  });

  group('Profile.updatePersonalInfo', () {
    test('publishes the updated profile after saving', () async {
      final repository = _ControlledRepository();
      final container = _container(repository);
      await container.read(profileProvider.future);

      await container.read(profileProvider.notifier).updatePersonalInfo(_info);

      expect(repository.saved, [_info]);
      final user = container.read(profileProvider).value!;
      expect(user.username, 'New Name');
      expect(user.sex, 'Female');
      expect(user.stats, same(_user.stats));
    });

    test('keeps the previous profile when saving fails', () async {
      final repository = _ControlledRepository()..fail = true;
      final container = _container(repository);
      await container.read(profileProvider.future);

      await expectLater(
        container.read(profileProvider.notifier).updatePersonalInfo(_info),
        throwsA(isA<StateError>()),
      );

      expect(container.read(profileProvider).value!.username, 'Old Name');
    });
  });

  group('EditProfileScreen', () {
    testWidgets('prefills the form and reads "M" as Male', (tester) async {
      await _pump(tester, _ControlledRepository());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Old Name'), findsOneWidget);
      expect(find.text('30 years'), findsOneWidget);
      expect(find.text('70.5 kg'), findsOneWidget);
      expect(find.text('175 cm'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Asthma'), findsOneWidget);
      expect(find.text('old@example.com'), findsOneWidget);
      expect(_selectedSex(tester), {BiologicalSex.male});
    });

    testWidgets('requires a sex before saving', (tester) async {
      final repository = _ControlledRepository(user: _userWithoutSex);
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await _tapSave(tester);

      expect(find.text('Please select your biological sex.'), findsOneWidget);
      expect(repository.saved, isEmpty);
    });

    testWidgets('a missing age is reported in Spanish', (tester) async {
      final repository = _ControlledRepository(user: _userWithoutAge);
      await _pump(tester, repository, locale: const Locale('es'));
      await tester.pumpAndSettle();

      await _tapSave(tester);

      expect(
        find.text('Todos los campos obligatorios deben completarse.'),
        findsOneWidget,
      );
      expect(repository.saved, isEmpty);
    });

    testWidgets('age, weight and height are picked on wheels', (tester) async {
      final repository = _ControlledRepository();
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      // Age: tapping a row scrolls it into the middle.
      await tester.tap(find.byKey(const ValueKey('edit-profile-age')));
      await tester.pumpAndSettle();
      expect(find.text('How old are you?'), findsOneWidget);
      await tester.tap(find.text('31'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('wheel-sheet-done')));
      await tester.pumpAndSettle();
      expect(find.text('31 years'), findsOneWidget);

      // Weight in pounds is saved in kilograms.
      await tester.tap(find.byKey(const ValueKey('edit-profile-weight')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('lbs'));
      await tester.pumpAndSettle();
      expect(find.text('155'), findsOneWidget);
      await tester.tap(find.text('156'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('wheel-sheet-done')));
      await tester.pumpAndSettle();
      expect(find.text('70.8 kg'), findsOneWidget);

      // Dismissing the sheet keeps the value.
      await tester.tap(find.byKey(const ValueKey('edit-profile-height')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('176'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('175 cm'), findsOneWidget);

      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(repository.saved.single.age, 31);
      expect(repository.saved.single.weight, 70.8);
      expect(repository.saved.single.height, 175);
    });

    testWidgets('saves once, even when Save is pressed again meanwhile', (
      tester,
    ) async {
      final repository = _ControlledRepository()..hold = Completer<void>();
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Old Name'),
        ' New Name ',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Asthma'), '');
      await tester.tap(find.text('Female'));
      await tester.pump();

      await _tapSave(tester);
      await _tapSave(tester);
      expect(repository.calls, 1);

      repository.hold!.complete();
      await tester.pumpAndSettle();

      expect(repository.saved.single.username, 'New Name');
      expect(repository.saved.single.sex, BiologicalSex.female);
      expect(repository.saved.single.medicalConditions, isNull);
      expect(find.text('Profile updated.'), findsOneWidget);
      // Back on the page that opened it.
      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('settings'), findsOneWidget);
    });

    testWidgets('keeps the form and explains when saving fails', (
      tester,
    ) async {
      final repository = _ControlledRepository()..fail = true;
      await _pump(tester, repository);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Old Name'),
        'Typed Name',
      );
      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Could not save your profile. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Typed Name'), findsOneWidget);
    });
  });
}

Set<BiologicalSex> _selectedSex(WidgetTester tester) => tester
    .widget<SegmentedButton<BiologicalSex>>(
      find.byType(SegmentedButton<BiologicalSex>),
    )
    .selected;

Future<void> _tapSave(WidgetTester tester) async {
  final save = find.byKey(const ValueKey('edit-profile-save'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pump();
}

const _info = PersonalInfo(
  username: 'New Name',
  age: 31,
  height: 180,
  weight: 72.5,
  sex: BiologicalSex.female,
);

final _user = UserModel(
  id: 'uid-1',
  email: 'old@example.com',
  username: 'Old Name',
  sex: 'M',
  age: 30,
  height: 175,
  weight: 70.5,
  createdAt: DateTime(2026, 10, 1),
  medicalConditions: const ['Asthma'],
  stats: const UserStats(knee: 2, hip: 2, ankle: 2, shoulder: 2),
  training: UserTraining(
    activePlanId: 'plan-1',
    planStartDate: DateTime(2026, 10, 1),
    schedule: const UserSchedule(days: {1: 1}),
  ),
  notifications: UserNotifications.fromJson(const {'enabled': true}),
  completedWorkouts: [DateTime(2026, 10, 5, 18)],
  completedActiveBreaks: [DateTime(2026, 10, 6, 9)],
  streak: UserStreak.empty,
  consistencyTrackedSince: DateTime(2026, 10, 2),
);

final _userWithoutAge = UserModel(
  id: 'uid-1',
  email: 'old@example.com',
  username: 'Old Name',
  sex: 'Male',
  height: 175,
  weight: 70.5,
);

final _userWithoutSex = UserModel(
  id: 'uid-1',
  email: 'old@example.com',
  username: 'Old Name',
  age: 30,
  height: 175,
  weight: 70.5,
);

ProviderContainer _container(ProfileRepository repository) {
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      profileProvider.overrideWith(_RepositoryProfile.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// A phone-sized screen tall enough to show the whole form.
Future<void> _pump(
  WidgetTester tester,
  _ControlledRepository repository, {
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(390, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(repository, locale: locale));
  await tester.pumpAndSettle();
  // Opened from Settings, as in the app.
  await tester.tap(find.text('settings'));
}

Widget _app(_ControlledRepository repository, {Locale? locale}) {
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/edit-profile'),
            child: const Text('settings'),
          ),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  return UncontrolledProviderScope(
    container: _container(repository),
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale ?? const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

/// Loads from the repository without scheduling notifications.
class _RepositoryProfile extends Profile {
  @override
  Future<UserModel> build() => loadProfile();
}

class _ControlledRepository implements ProfileRepository {
  _ControlledRepository({UserModel? user}) : _profile = user ?? _user;

  final UserModel _profile;
  final List<PersonalInfo> saved = [];
  int calls = 0;
  bool fail = false;
  Completer<void>? hold;

  @override
  Future<UserModel> getProfile() async => _profile;

  @override
  Future<void> updatePersonalInfo(PersonalInfo info) async {
    calls++;
    await hold?.future;
    if (fail) throw StateError('offline');
    saved.add(info);
  }

  @override
  Future<void> saveProfile(UserModel user) =>
      throw UnimplementedError('Edit Profile must not save the whole profile');

  @override
  Future<void> createProfile(UserModel user, {String? privacyPolicyVersion}) => throw UnimplementedError();

  @override

  Future<void> unlockBadges(Set<String> badgeIds) async {}


  @override
  Future<void> recordCompletion({
    required ActivityKind kind,
    required DateTime completedAt,
    required UserStreak streak,
    RewardForHistory? reward,
  }) => throw UnimplementedError();
}

class _FakeUser extends Fake implements User {
  _FakeUser(this.uid);

  @override
  final String uid;
}

class _FakeAuth extends Fake implements FirebaseAuth {
  _FakeAuth(this.currentUser);

  @override
  final User? currentUser;
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  String? collectionPath;
  String? docId;
  final List<Map<Object, Object?>> updates = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    collectionPath = path;
    return _FakeCollection(this);
  }
}

// Firestore marks its references @sealed; a test fake is the exception.
// ignore: subtype_of_sealed_class
class _FakeCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollection(this._firestore);

  final _FakeFirestore _firestore;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    _firestore.docId = path;
    return _FakeDocument(_firestore);
  }
}

// ignore: subtype_of_sealed_class
class _FakeDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocument(this._firestore);

  final _FakeFirestore _firestore;

  @override
  Future<void> update(Map<Object, Object?> data) async {
    _firestore.updates.add(data);
  }
}
