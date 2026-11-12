import 'package:flutter/material.dart';
import '../data/sample_transactions.dart';
import '../models/transaction.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';

/// Top-level navigation shell hosting the Dashboard and Transactions pages.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.initialTransactions,
  });

  final List<Transaction>? initialTransactions;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final List<Transaction> _transactions;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _transactions = List.of(widget.initialTransactions ?? sampleTransactions);
  }

  void _addSampleExpense() {
    setState(() {
      _transactions.add(
        Transaction(
          title: 'Coffee',
          amount: 15,
          isExpense: true,
          category: 'Food',
          date: DateTime.now(),
          note: 'Quick coffee break',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(
            transactions: _transactions,
            onAddSampleExpense: _addSampleExpense,
            onSeeAllTransactions: () => setState(() => _selectedIndex = 1),
          ),
          TransactionsScreen(transactions: _transactions),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}
