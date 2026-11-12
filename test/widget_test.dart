import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard navigates to Transactions and reflects new items',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total Balance'), findsOneWidget);

    // Add a sample expense from Dashboard FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Navigate to Transactions via the bottom NavigationBar.
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('10 transactions'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
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
}
