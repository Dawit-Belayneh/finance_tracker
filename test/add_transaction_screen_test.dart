import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Validates amount and creates an expense transaction',
      (WidgetTester tester) async {
    Transaction? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Transaction>(
                  MaterialPageRoute<Transaction>(
                    builder: (_) => const AddTransactionScreen(),
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

    // Submitting with empty amount shows validation error.
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pump();
    expect(find.text('Please enter an amount'), findsOneWidget);

    // Fill amount, pick a different expense category, and add description.
    await tester.enterText(find.byKey(const Key('amount_field')), '42.75');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Airport shuttle',
    );

    // Open date picker and confirm date.
    await tester.tap(find.byKey(const Key('date_picker_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isExpense, isTrue);
    expect(result!.amount, 42.75);
    expect(result!.category, 'Transport');
    expect(result!.title, 'Airport shuttle');
    expect(result!.note, 'Airport shuttle');
  });

  testWidgets('Switching to Income updates categories and saves income',
      (WidgetTester tester) async {
    Transaction? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Transaction>(
                  MaterialPageRoute<Transaction>(
                    builder: (_) => const AddTransactionScreen(),
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

    // Switch to Income.
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    // Default category should now be Salary.
    expect(find.text('Salary'), findsOneWidget);

    // Select Freelance category.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Freelance').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amount_field')), '350');
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isExpense, isFalse);
    expect(result!.amount, 350);
    expect(result!.category, 'Freelance');
    expect(result!.title, 'Freelance');
    expect(result!.note, isNull);
  });
}
