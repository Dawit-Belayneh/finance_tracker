import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/screens/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testTransactions = [
    Transaction(
      title: 'Salary',
      amount: 5000,
      isExpense: false,
      category: 'Salary',
      date: DateTime(2026, 11, 2),
    ),
    Transaction(
      title: 'Groceries',
      amount: 150,
      isExpense: true,
      category: 'Food',
      date: DateTime(2026, 11, 10),
    ),
    Transaction(
      title: 'Freelance',
      amount: 400,
      isExpense: false,
      category: 'Freelance',
      date: DateTime(2026, 11, 11),
    ),
    Transaction(
      title: 'Electric',
      amount: 50,
      isExpense: true,
      category: 'Bills',
      date: DateTime(2026, 11, 12),
    ),
    Transaction(
      title: 'Oct Rent',
      amount: 900,
      isExpense: true,
      category: 'Bills',
      date: DateTime(2026, 10, 15),
    ),
  ];

  testWidgets('Displays monthly income vs expenses and category breakdown',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsScreen(
          transactions: testTransactions,
          initialDate: DateTime(2026, 11, 12),
        ),
      ),
    );

    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Income vs Expenses'), findsOneWidget);
    expect(find.text('\$5400.00'), findsOneWidget);
    expect(find.text('\$200.00'), findsOneWidget);
    expect(find.text('+\$5200.00'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('75.0% • \$150.00'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('25.0% • \$50.00'), findsOneWidget);

    // Toggle Category Breakdown to Income.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
  });

  testWidgets('Switches between weekly and monthly reports and navigates periods',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsScreen(
          transactions: testTransactions,
          initialDate: DateTime(2026, 11, 12),
        ),
      ),
    );

    // Switch to Weekly (week containing Nov 12, 2026 is Nov 9 – Nov 15, 2026).
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();

    expect(find.text('Nov 9 – Nov 15, 2026'), findsOneWidget);
    // Week transactions: Freelance (+400), Groceries (-150), Electric (-50).
    expect(find.text('\$400.00'), findsOneWidget);
    expect(find.text('\$200.00'), findsOneWidget);
    expect(find.text('+\$200.00'), findsOneWidget);

    // Go back one week (Nov 2 – Nov 8, 2026: Salary +5000).
    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();

    expect(find.text('Nov 2 – Nov 8, 2026'), findsOneWidget);
    expect(find.text('\$5000.00'), findsOneWidget);
    expect(find.text('\$0.00'), findsOneWidget);

    // Switch back to Monthly and step to October 2026.
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('\$900.00'), findsOneWidget);
    expect(find.text('-\$900.00'), findsOneWidget);
  });

  testWidgets('Renders cleanly on narrow mobile screen without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ReportsScreen(
          transactions: testTransactions,
          initialDate: DateTime(2026, 11, 12),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
