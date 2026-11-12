import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testTransactions = [
    Transaction(
      title: 'Salary',
      amount: 5000,
      isExpense: false,
      category: 'Salary',
      date: DateTime(2026, 11, 1, 9, 0),
      note: 'Monthly paycheck',
    ),
    Transaction(
      title: 'Groceries',
      amount: 120,
      isExpense: true,
      category: 'Food',
      date: DateTime(2026, 11, 3, 18, 15),
      note: 'Supermarket run',
    ),
    Transaction(
      title: 'Freelance',
      amount: 800,
      isExpense: false,
      category: 'Work',
      date: DateTime(2026, 11, 5, 14, 30),
    ),
    Transaction(
      title: 'Taxi',
      amount: 30,
      isExpense: true,
      category: 'Transport',
      date: DateTime(2026, 11, 4, 8, 45),
    ),
  ];

  Widget buildSubject() {
    return MaterialApp(
      home: TransactionsScreen(transactions: testTransactions),
    );
  }

  testWidgets('Displays all transactions and filters by income and expense',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());

    // All transactions shown initially.
    expect(find.text('4 transactions'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);

    // Filter to Income.
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('2 transactions'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('Taxi'), findsNothing);

    // Filter to Expenses.
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    expect(find.text('2 transactions'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Freelance'), findsNothing);

    // Back to All.
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('4 transactions'), findsOneWidget);
  });

  testWidgets('Searches by title, category, or note and handles empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());

    final searchField = find.byKey(const Key('transaction_search_field'));

    // Search by category.
    await tester.enterText(searchField, 'food');
    await tester.pumpAndSettle();

    expect(find.text('1 transaction'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    // Search by note.
    await tester.enterText(searchField, 'paycheck');
    await tester.pumpAndSettle();

    expect(find.text('1 transaction'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);

    // Search with no matches shows empty state and Clear filters button.
    await tester.enterText(searchField, 'nonexistent');
    await tester.pumpAndSettle();

    expect(find.text('No matching transactions'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('4 transactions'), findsOneWidget);
  });

  testWidgets('Tapping a transaction opens Transaction Details page',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Expense'), findsNWidgets(2));
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('-\$120.00'), findsOneWidget);
    expect(find.text('\$120.00'), findsOneWidget);
    expect(find.text('Nov 3, 2026'), findsOneWidget);
    expect(find.text('6:15 PM'), findsOneWidget);
    expect(find.text('Supermarket run'), findsOneWidget);
  });
}
