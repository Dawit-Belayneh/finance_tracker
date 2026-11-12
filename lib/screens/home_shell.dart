import 'package:flutter/material.dart';
import '../data/sample_budgets.dart';
import '../data/sample_transactions.dart';
import '../models/transaction.dart';
import '../utils/transaction_actions.dart';
import 'budgets_screen.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'transactions_screen.dart';

/// Top-level navigation shell hosting Dashboard, Transactions, and Budgets.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.initialTransactions,
    this.initialMonthlyBudget = defaultMonthlyBudget,
    this.initialCategoryBudgets,
  });

  final List<Transaction>? initialTransactions;
  final double initialMonthlyBudget;
  final Map<String, double>? initialCategoryBudgets;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final List<Transaction> _transactions;
  late double _monthlyBudget;
  late final Map<String, double> _categoryBudgets;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _transactions = List.of(widget.initialTransactions ?? sampleTransactions);
    _monthlyBudget = widget.initialMonthlyBudget;
    _categoryBudgets = Map.of(
      widget.initialCategoryBudgets ?? sampleCategoryBudgets,
    );
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.add(transaction);
    });
  }

  void _updateTransaction(Transaction original, Transaction updated) {
    setState(() {
      replaceTransactionInList(_transactions, original, updated);
    });
  }

  void _deleteTransaction(Transaction target) {
    setState(() {
      removeTransactionFromList(_transactions, target);
    });
  }

  void _updateMonthlyBudget(double amount) {
    setState(() {
      _monthlyBudget = amount;
    });
  }

  void _saveCategoryBudget(String category, double amount) {
    setState(() {
      _categoryBudgets[category] = amount;
    });
  }

  void _removeCategoryBudget(String category) {
    setState(() {
      _categoryBudgets.remove(category);
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
            onTransactionAdded: _addTransaction,
            onTransactionUpdated: _updateTransaction,
            onTransactionDeleted: _deleteTransaction,
            onSeeAllTransactions: () => setState(() => _selectedIndex = 1),
          ),
          TransactionsScreen(
            transactions: _transactions,
            onTransactionAdded: _addTransaction,
            onTransactionUpdated: _updateTransaction,
            onTransactionDeleted: _deleteTransaction,
          ),
          BudgetsScreen(
            transactions: _transactions,
            monthlyBudget: _monthlyBudget,
            categoryBudgets: _categoryBudgets,
            onMonthlyBudgetChanged: _updateMonthlyBudget,
            onCategoryBudgetSaved: _saveCategoryBudget,
            onCategoryBudgetRemoved: _removeCategoryBudget,
          ),
          ReportsScreen(transactions: _transactions),
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
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
