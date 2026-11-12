import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard + opens Add Transaction and adds item across tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total Balance'), findsOneWidget);

    // Open Add Transaction from Dashboard FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);

    // Enter amount and description, then save.
    await tester.enterText(find.byKey(const Key('amount_field')), '18.50');
    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Morning coffee',
    );
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    // Navigate to Transactions via the bottom NavigationBar.
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('10 transactions'), findsOneWidget);
    expect(find.text('Morning coffee'), findsOneWidget);
    expect(find.text('-\$18.50'), findsOneWidget);
  });

  testWidgets('See all button on Dashboard switches to Transactions page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    final seeAllFinder = find.text('See all');
    await tester.scrollUntilVisible(
      seeAllFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(seeAllFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transaction_search_field')), findsOneWidget);
    expect(find.text('9 transactions'), findsOneWidget);
  });

  testWidgets('Budgets tab updates spending progress when new expense is added',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    // Open Add Transaction and add a $100 Food expense.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amount_field')), '100');
    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Dinner',
    );
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    // Switch to Budgets tab.
    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();

    // Sample monthly spending is $530 + $100 = $630 of $2000.
    expect(find.text('\$630.00 / \$2000.00'), findsOneWidget);
    // Sample Food spending is $200 + $100 = $300 of $300.
    expect(find.text('\$300.00 / \$300.00'), findsOneWidget);
  });

  testWidgets('Reports tab displays income vs expenses summary',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Income vs Expenses'), findsOneWidget);
    final breakdownFinder = find.text('Category Breakdown');
    await tester.scrollUntilVisible(
      breakdownFinder,
      200,
      scrollable: find.descendant(
        of: find.byType(IndexedStack),
        matching: find.byType(Scrollable),
      ).last,
    );
    expect(breakdownFinder, findsOneWidget);
  });

  testWidgets('Editing and deleting a transaction from Transactions updates list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('9 transactions'), findsOneWidget);

    // Open Restaurant details (near top of newest-first list) and edit it.
    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();

    final editButton = find.byKey(const Key('edit_transaction_button'));
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Bistro dinner',
    );
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    // Now delete the edited transaction.
    final deleteButton = find.byKey(const Key('delete_transaction_button'));
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm_delete_button')));
    await tester.pumpAndSettle();

    expect(find.text('8 transactions'), findsOneWidget);
    expect(find.text('Bistro dinner'), findsNothing);
    expect(find.text('Restaurant'), findsNothing);
  });

  testWidgets('Settings changes currency, decimals, and theme across the app',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    // Open Settings from Dashboard AppBar.
    await tester.tap(find.byTooltip('Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    // Switch Currency to Euro.
    await tester.tap(find.byKey(const Key('currency_setting_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();

    // Switch Theme to Dark.
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Turn off decimals.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show_decimals_switch')));
    await tester.pumpAndSettle();

    // Return to Dashboard and verify dark theme + Euro formatting without decimals.
    await tester.pageBack();
    await tester.pumpAndSettle();

    final materialApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(find.textContaining('€'), findsWidgets);
    expect(find.textContaining('.00'), findsNothing);
  });
}
