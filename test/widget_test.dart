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
}
