import 'package:finance_tracker/data/app_settings.dart';
import 'package:finance_tracker/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Displays Profile, Currency, Theme, and Preferences sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          settings: const AppSettings(),
          onSettingsChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('USD • US Dollar (\$)'), findsOneWidget);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Daily reminders'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Show decimals'), findsOneWidget);
    expect(find.text('Budget alerts'), findsOneWidget);
    expect(find.text('Daily reminders'), findsOneWidget);
  });

  testWidgets('Updates profile, currency, theme, and preferences',
      (WidgetTester tester) async {
    AppSettings latest = const AppSettings();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          settings: latest,
          onSettingsChanged: (updated) => latest = updated,
        ),
      ),
    );

    // Edit profile.
    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profile_name_field')),
      'Jamie Lee',
    );
    await tester.enterText(
      find.byKey(const Key('profile_email_field')),
      'jamie@finance.app',
    );
    await tester.tap(find.byKey(const Key('save_profile_button')));
    await tester.pumpAndSettle();

    expect(latest.profileName, 'Jamie Lee');
    expect(latest.profileEmail, 'jamie@finance.app');
    expect(find.text('Jamie Lee'), findsOneWidget);
    expect(find.text('JL'), findsOneWidget);

    // Change currency to Euro.
    await tester.tap(find.byKey(const Key('currency_setting_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();

    expect(latest.currency, AppCurrency.eur);
    expect(find.text('EUR • Euro (€)'), findsOneWidget);

    // Change theme to Dark.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(latest.themeMode, ThemeMode.dark);

    // Toggle preferences.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('show_decimals_switch')));
    await tester.pumpAndSettle();
    expect(latest.showDecimals, isFalse);

    await tester.tap(find.byKey(const Key('budget_alerts_switch')));
    await tester.pumpAndSettle();
    expect(latest.budgetAlerts, isFalse);

    await tester.tap(find.byKey(const Key('daily_reminders_switch')));
    await tester.pumpAndSettle();
    expect(latest.dailyReminders, isTrue);
  });

  testWidgets('Renders cleanly on narrow mobile screen without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          settings: const AppSettings(),
          onSettingsChanged: (_) {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
