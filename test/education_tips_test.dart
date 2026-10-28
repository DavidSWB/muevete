import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/education/data/firebase_educational_message_repository.dart';
import 'package:muevete/features/education/domain/educational_message.dart';
import 'package:muevete/features/education/domain/educational_message_repository.dart';
import 'package:muevete/features/education/domain/tip_preferences.dart';
import 'package:muevete/features/education/domain/tip_selector.dart';
import 'package:muevete/features/education/presentation/providers/education_providers.dart';
import 'package:muevete/features/education/presentation/widgets/daily_tip_card.dart';
import 'package:muevete/features/education/presentation/widgets/tip_frequency_tile.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_store.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';
import 'package:muevete/l10n/app_localizations.dart';

EducationalMessage _message(
  String id, {
  int order = 0,
  EducationalMessageType type = EducationalMessageType.tip,
}) {
  return EducationalMessage(
    messageId: id,
    type: type,
    order: order,
    text: {'es': 'Texto $id', 'en': 'Text $id'},
    sourceLabel: {'es': 'OMS', 'en': 'WHO'},
    sourceUrl: {
      'es': 'https://www.who.int/es/$id',
      'en': 'https://www.who.int/$id',
    },
  );
}

final _messages = [
  _message('c', order: 30),
  _message('a', order: 10, type: EducationalMessageType.evidence),
  _message('b', order: 20),
];

final _now = DateTime(2026, 10, 28, 9, 30);
final _today = DateTime(2026, 10, 28);
final _yesterday = DateTime(2026, 10, 27);

void main() {
  group('selectTip', () {
    EducationalMessage? select(TipPreferences preferences, {List? messages}) =>
        selectTip(
          messages: (messages ?? _messages).cast<EducationalMessage>(),
          preferences: preferences,
          now: _now,
        );

    test('starts with the lowest order when nothing was dismissed', () {
      expect(select(TipPreferences.defaults)?.messageId, 'a');
    });

    test('continues after the last dismissed tip and wraps around', () {
      const everyOpen = TipPreferences(frequency: TipFrequency.everyOpen);
      expect(select(everyOpen.copyWith(lastDismissedId: 'a'))?.messageId, 'b');
      expect(select(everyOpen.copyWith(lastDismissedId: 'c'))?.messageId, 'a');
    });

    test('a dismissed id that no longer exists restarts the rotation', () {
      expect(
        select(
          TipPreferences.defaults.copyWith(lastDismissedId: 'gone'),
        )?.messageId,
        'a',
      );
    });

    test('once a day: nothing more after a dismissal today', () {
      final dismissedToday = TipPreferences.defaults.copyWith(
        lastDismissedId: 'a',
        lastDismissedOn: _today,
      );
      expect(select(dismissedToday), isNull);

      final dismissedYesterday = dismissedToday.copyWith(
        lastDismissedOn: _yesterday,
      );
      expect(select(dismissedYesterday)?.messageId, 'b');
    });

    test('every open: a tip dismissed today does not block the next', () {
      final preferences = TipPreferences(
        frequency: TipFrequency.everyOpen,
        lastDismissedId: 'a',
        lastDismissedOn: _today,
      );
      expect(select(preferences)?.messageId, 'b');
    });

    test('off or no messages shows nothing', () {
      expect(select(const TipPreferences(frequency: TipFrequency.off)), isNull);
      expect(select(TipPreferences.defaults, messages: const []), isNull);
    });
  });

  group('TipPreferences', () {
    test('round-trips through JSON', () {
      final preferences = TipPreferences(
        frequency: TipFrequency.everyOpen,
        lastDismissedId: 'b',
        lastDismissedOn: _today,
      );
      expect(TipPreferences.fromJson(preferences.toJson()), preferences);
    });

    test('unreadable values fall back to the defaults', () {
      expect(TipPreferences.fromJson(null), TipPreferences.defaults);
      expect(TipPreferences.fromJson('x'), TipPreferences.defaults);
      expect(
        TipPreferences.fromJson({
          'frequency': 'weekly',
          'lastDismissedOn': 'yesterday',
        }),
        TipPreferences.defaults,
      );
    });
  });

  group('parsing a Firestore message', () {
    Map<String, dynamic> valid() => {
      'messageId': 'evidence-150-minutes',
      'type': 'evidence',
      'active': true,
      'order': 50,
      'text': {'es': 'Texto', 'en': 'Text'},
      'source': {
        'label': {'es': 'OMS', 'en': 'WHO'},
        'url': {
          'es': 'https://www.who.int/es/page',
          'en': 'https://www.who.int/page',
        },
      },
    };

    test('reads every field', () {
      final message = FirebaseEducationalMessageRepository.parse(valid());
      expect(message.messageId, 'evidence-150-minutes');
      expect(message.type, EducationalMessageType.evidence);
      expect(message.order, 50);
      expect(message.text['es'], 'Texto');
      expect(message.sourceLabel['en'], 'WHO');
      expect(message.sourceUrl['es'], 'https://www.who.int/es/page');
    });

    test('rejects a message without both languages or a safe link', () {
      final missingEnglish = valid()..['text'] = {'es': 'Texto'};
      final insecure = valid()
        ..['source'] = {
          'label': {'es': 'OMS', 'en': 'WHO'},
          'url': {'es': 'http://who.int', 'en': 'https://who.int'},
        };
      final noSource = valid()..remove('source');
      for (final data in [missingEnglish, insecure, noSource]) {
        expect(
          () => FirebaseEducationalMessageRepository.parse(data),
          throwsFormatException,
        );
      }
    });
  });

  group('daily tip on Home', () {
    late _MemoryTipStore tipStore;
    late List<Uri> opened;

    setUp(() {
      tipStore = _MemoryTipStore();
      opened = [];
    });

    Future<ProviderContainer> pump(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
      EducationalMessageRepository? repository,
      bool tourActive = false,
      bool linkOpens = true,
    }) async {
      final container = ProviderContainer(
        overrides: [
          tipUserIdProvider.overrideWithValue('u'),
          tipClockProvider.overrideWithValue(() => _now),
          tipPreferencesStoreProvider.overrideWithValue(tipStore),
          educationalMessageRepositoryProvider.overrideWithValue(
            repository ?? _FixedRepository(_messages),
          ),
          tipLinkOpenerProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return linkOpens;
          }),
          walkthroughUserIdProvider.overrideWithValue('u'),
          walkthroughStoreProvider.overrideWithValue(_TourStore()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(walkthroughControllerProvider.notifier).loaded;
      if (tourActive) {
        container.read(walkthroughControllerProvider.notifier).start();
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Column(children: [DailyTipSlot(), Text('below')]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('shows the tip with its label and short source', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Text a'), findsOneWidget);
      expect(find.text('WHAT THE EVIDENCE SAYS'), findsOneWidget);
      expect(find.text('Source: WHO'), findsOneWidget);
      expect(find.bySemanticsLabel('Open the source: WHO'), findsOneWidget);
    });

    testWidgets('is in Spanish with the Spanish link', (tester) async {
      await pump(tester, locale: const Locale('es'));

      expect(find.text('Texto a'), findsOneWidget);
      expect(find.text('LO QUE DICE LA EVIDENCIA'), findsOneWidget);
      expect(find.text('Fuente: OMS'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('daily-tip-source')));
      await tester.pumpAndSettle();
      expect(opened, [Uri.parse('https://www.who.int/es/a')]);
    });

    testWidgets('stays until dismissed, then records the dismissal', (
      tester,
    ) async {
      final container = await pump(tester);

      await tester.pump(const Duration(minutes: 5));
      expect(find.text('Text a'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('daily-tip-dismiss')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('daily-tip-a')), findsNothing);
      expect(find.text('below'), findsOneWidget);
      expect(
        tipStore.saved['u'],
        TipPreferences(
          frequency: TipFrequency.daily,
          lastDismissedId: 'a',
          lastDismissedOn: _today,
        ),
      );
      // Changing the frequency in the same session keeps it closed.
      await container
          .read(tipPreferencesProvider.notifier)
          .setFrequency(TipFrequency.everyOpen);
      await tester.pumpAndSettle();
      expect(find.textContaining('Text '), findsNothing);
    });

    testWidgets('the next launch continues the rotation', (tester) async {
      tipStore.saved['u'] = TipPreferences(
        frequency: TipFrequency.daily,
        lastDismissedId: 'a',
        lastDismissedOn: _yesterday,
      );
      await pump(tester);

      expect(find.text('Text b'), findsOneWidget);
    });

    testWidgets('a broken link shows a message instead of failing', (
      tester,
    ) async {
      await pump(tester, linkOpens: false);

      await tester.tap(find.byKey(const ValueKey('daily-tip-source')));
      await tester.pumpAndSettle();
      expect(
        find.text("We couldn't open the link. Please try again later."),
        findsOneWidget,
      );
    });

    testWidgets('takes no room while the tour runs', (tester) async {
      await pump(tester, tourActive: true);

      expect(find.byType(DailyTipCard), findsNothing);
      expect(find.text('below'), findsOneWidget);
    });

    testWidgets('takes no room when messages cannot load', (tester) async {
      await pump(tester, repository: _FailingRepository());

      expect(find.byType(DailyTipCard), findsNothing);
      expect(find.text('below'), findsOneWidget);
    });

    testWidgets('takes no room when tips are off', (tester) async {
      tipStore.saved['u'] = const TipPreferences(frequency: TipFrequency.off);
      await pump(tester);

      expect(find.byType(DailyTipCard), findsNothing);
    });
  });

  group('Settings tile', () {
    testWidgets('shows the frequency and saves a new choice', (tester) async {
      final tipStore = _MemoryTipStore();
      final container = ProviderContainer(
        overrides: [
          tipUserIdProvider.overrideWithValue('u'),
          tipPreferencesStoreProvider.overrideWithValue(tipStore),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: TipFrequencyTile()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Consejos de salud'), findsOneWidget);
      expect(find.text('Uno al día'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('settings-tips')));
      await tester.pumpAndSettle();
      expect(find.text('Cada vez que abro la app'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tip-frequency-off')));
      await tester.pumpAndSettle();

      expect(find.text('Desactivados'), findsOneWidget);
      expect(tipStore.saved['u']?.frequency, TipFrequency.off);
    });
  });

  test('every tip string exists in Spanish and English', () async {
    for (final locale in const [Locale('es'), Locale('en')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      for (final text in [
        l10n.tourHomeMissionTitle,
        l10n.tourHomeMissionBody,
        l10n.tourHomeHabitsTitle,
        l10n.tourHomeHabitsBody,
        l10n.tipTypeTip,
        l10n.tipTypeEvidence,
        l10n.tipDismiss,
        l10n.tipSource('x'),
        l10n.tipOpenSource('x'),
        l10n.tipSourceFailed,
        l10n.settingsTips,
        l10n.settingsTipsDaily,
        l10n.settingsTipsEveryOpen,
        l10n.settingsTipsOff,
      ]) {
        expect(text.trim(), isNotEmpty, reason: locale.languageCode);
      }
    }
  });
}

class _FixedRepository implements EducationalMessageRepository {
  _FixedRepository(this.messages);

  final List<EducationalMessage> messages;

  @override
  Future<List<EducationalMessage>> getActiveMessages() async => messages;
}

class _FailingRepository implements EducationalMessageRepository {
  @override
  Future<List<EducationalMessage>> getActiveMessages() async =>
      throw StateError('permission-denied');
}

class _MemoryTipStore implements TipPreferencesStore {
  final Map<String, TipPreferences> saved = {};

  @override
  Future<TipPreferences> load(String uid) async =>
      saved[uid] ?? TipPreferences.defaults;

  @override
  Future<void> save(String uid, TipPreferences preferences) async {
    saved[uid] = preferences;
  }
}

class _TourStore implements WalkthroughStore {
  @override
  Future<WalkthroughProgress?> load(String uid) async => null;

  @override
  Future<void> save(String uid, WalkthroughProgress progress) async {}

  @override
  Future<void> clear(String uid) async {}
}
