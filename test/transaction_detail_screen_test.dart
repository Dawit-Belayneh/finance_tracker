import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/screens/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = Transaction(
    title: 'Groceries',
    amount: 120,
    isExpense: true,
    category: 'Food',
    date: DateTime(2026, 11, 3, 18, 15),
    note: 'Weekly groceries',
  );

  testWidgets('Displays transaction information, Edit, and Delete buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailScreen(transaction: sample),
      ),
    );

    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Transaction Information'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('-\$120.00'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Nov 3, 2026'), findsOneWidget);
    expect(find.text('6:15 PM'), findsOneWidget);
    expect(find.text('Weekly groceries'), findsOneWidget);
    expect(find.byKey(const Key('edit_transaction_button')), findsOneWidget);
    expect(find.byKey(const Key('delete_transaction_button')), findsOneWidget);
  });

  testWidgets('Editing transaction updates details and invokes callback',
      (WidgetTester tester) async {
    Transaction? updatedTransaction;

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionDetailScreen(
          transaction: sample,
          onTransactionUpdated: (tx) => updatedTransaction = tx,
        ),
      ),
    );

    final editButton = find.byKey(const Key('edit_transaction_button'));
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.text('120.00'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('amount_field')), '145.50');
    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Organic groceries',
    );
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    expect(updatedTransaction, isNotNull);
    expect(updatedTransaction!.amount, 145.50);
    expect(updatedTransaction!.title, 'Organic groceries');
    expect(find.text('-\$145.50'), findsOneWidget);
    expect(find.text('Organic groceries'), findsNWidgets(2));
  });

  testWidgets('Deleting transaction confirms and pops screen',
      (WidgetTester tester) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TransactionDetailScreen(
                      transaction: sample,
                      onTransactionDeleted: () => deleted = true,
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(const Key('delete_transaction_button'));
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete Transaction?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_delete_button')));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(find.text('Open'), findsOneWidget);
  });
}
