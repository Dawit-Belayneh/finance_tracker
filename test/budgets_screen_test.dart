import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/screens/budgets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testTransactions = [
    Transaction(
      title: 'Salary',
      amount: 5000,
      isExpense: false,
      category: 'Salary',
      date: DateTime(2026, 11, 1),
    ),
    Transaction(
      title: 'Groceries',
      amount: 200,
      isExpense: true,
      category: 'Food',
      date: DateTime(2026, 11, 3),
    ),
    Transaction(
      title: 'Electricity',
      amount: 260,
      isExpense: true,
      category: 'Bills',
      date: DateTime(2026, 11, 7),
    ),
    Transaction(
      title: 'Movie',
      amount: 35,
      isExpense: true,
      category: 'Entertainment',
      date: DateTime(2026, 11, 8),
    ),
    Transaction(
      title: 'October Taxi',
      amount: 50,
      isExpense: true,
      category: 'Transport',
      date: DateTime(2026, 10, 20),
    ),
  ];

  testWidgets('Displays monthly budget, category budgets, and spending progress',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BudgetsScreen(
          transactions: testTransactions,
          monthlyBudget: 1000,
          categoryBudgets: const {'Food': 400, 'Bills': 240},
          initialMonth: DateTime(2026, 11),
        ),
      ),
    );

    expect(find.text('November 2026'), findsOneWidget);
    // Monthly spent: 200 + 260 + 35 = 495 (excludes income and October tx).
    expect(find.text('\$495.00 / \$1000.00'), findsOneWidget);
    expect(find.text('\$505.00 left'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(2)); // Monthly (49.5%->50%) & Food (200/400->50%)

    // Food category progress.
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('\$200.00 / \$400.00'), findsOneWidget);

    // Bills over-budget progress.
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('\$260.00 / \$240.00'), findsOneWidget);
    expect(find.text('\$20.00 over budget'), findsOneWidget);
    expect(find.text('108%'), findsOneWidget);

    // Unbudgeted spending section shows Entertainment.
    await tester.scrollUntilVisible(
      find.text('Entertainment'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Unbudgeted Spending'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
  });

  testWidgets('Switches months and edits monthly and category budgets',
      (WidgetTester tester) async {
    double monthlyBudget = 1000;
    final categoryBudgets = <String, double>{'Food': 400};

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return BudgetsScreen(
              transactions: testTransactions,
              monthlyBudget: monthlyBudget,
              categoryBudgets: categoryBudgets,
              initialMonth: DateTime(2026, 11),
              onMonthlyBudgetChanged: (value) {
                setState(() => monthlyBudget = value);
              },
              onCategoryBudgetSaved: (category, amount) {
                setState(() => categoryBudgets[category] = amount);
              },
              onCategoryBudgetRemoved: (category) {
                setState(() => categoryBudgets.remove(category));
              },
            );
          },
        ),
      ),
    );

    // Edit Monthly Budget to 1500.
    await tester.tap(find.byTooltip('Edit Monthly Budget'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget_amount_field')), '1500');
    await tester.tap(find.byKey(const Key('save_budget_button')));
    await tester.pumpAndSettle();

    expect(find.text('\$495.00 / \$1500.00'), findsOneWidget);

    // Add a category budget for Transport.
    await tester.tap(find.byKey(const Key('add_category_budget_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('budget_amount_field')), '100');
    await tester.tap(find.byKey(const Key('save_budget_button')));
    await tester.pumpAndSettle();

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('\$0.00 / \$100.00'), findsOneWidget);

    // Switch to October 2026 and see October Taxi ($50) progress.
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('\$50.00 / \$1500.00'), findsOneWidget);
    expect(find.text('\$50.00 / \$100.00'), findsOneWidget);
  });
}
