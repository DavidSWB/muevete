import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/progress/presentation/widgets/progress_calendar.dart';
import 'package:muevete/l10n/app_localizations.dart';

/// The calendar header must fit every month in both languages on a narrow
/// screen, and the calendar must follow the app language.
void main() {
  Future<void> pumpCalendar(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            // The width the calendar gets on a 400 dp screen in the Progress
            // tab, where "November" used to overflow by 13 px.
            child: SizedBox(
              width: 320,
              child: ProgressCalendar(completedWorkouts: []),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in const [Locale('es'), Locale('en')]) {
    testWidgets('every month fits 320 px in ${locale.languageCode}', (
      tester,
    ) async {
      await pumpCalendar(tester, locale);
      final next = MaterialLocalizations.of(
        tester.element(find.byType(ProgressCalendar)),
      ).nextMonthTooltip;

      // A year from today covers every month name, whatever month it is now.
      for (var month = 0; month < 12; month++) {
        expect(tester.takeException(), isNull, reason: 'month $month');
        await tester.tap(find.byTooltip(next));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the calendar is in Spanish when the app is', (tester) async {
    await pumpCalendar(tester, const Locale('es'));
    final month = DateTime.now();

    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('Dom'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Completado'), findsOneWidget);
    expect(find.byTooltip('Mes anterior'), findsOneWidget);
    expect(find.textContaining('${month.year}'), findsOneWidget);
    expect(find.text('Mon'), findsNothing);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('the calendar is in English when the app is', (tester) async {
    await pumpCalendar(tester, const Locale('en'));

    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byTooltip('Previous month'), findsOneWidget);
  });
}
