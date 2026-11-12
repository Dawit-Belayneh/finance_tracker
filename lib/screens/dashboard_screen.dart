import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/sample_transactions.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.transactions,
    this.onAddSampleExpense,
    this.onSeeAllTransactions,
  });

  final List<Transaction>? transactions;
  final VoidCallback? onAddSampleExpense;
  final VoidCallback? onSeeAllTransactions;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final List<Transaction> _localTransactions = List.of(sampleTransactions);

  List<Transaction> get transactions =>
      widget.transactions ?? _localTransactions;

  // ---------- Calculations ----------
  double get totalIncome => transactions
      .where((t) => !t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactions
      .where((t) => t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final t in transactions.where((t) => t.isExpense)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  List<Transaction> get recent {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // ---------- Demo action: proves the screen refreshes ----------
  void _handleAddSampleExpense() {
    if (widget.onAddSampleExpense != null) {
      widget.onAddSampleExpense!();
      return;
    }
    setState(() {
      _localTransactions.add(
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

  void _handleSeeAll() {
    if (widget.onSeeAllTransactions != null) {
      widget.onSeeAllTransactions!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionsScreen(transactions: transactions),
      ),
    );
  }

  void _openDetails(Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _balanceCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Income',
                  totalIncome,
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Expenses',
                  totalExpenses,
                  Colors.red,
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _chartCard(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _handleSeeAll,
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recent.map(
            (t) => TransactionTile(
              transaction: t,
              onTap: () => _openDetails(t),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddSampleExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- 1. Balance card ----------
  Widget _balanceCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Balance'),
            const SizedBox(height: 8),
            Text(
              money(balance),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 2. Income / Expenses card ----------
  Widget _summaryCard(String label, double value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              money(value),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- 3. Expense chart ----------
  Widget _chartCard() {
    final data = expensesByCategory;
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses by category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              const Center(child: Text('No expenses yet'))
            else ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      for (var i = 0; i < data.length; i++)
                        PieChartSectionData(
                          value: data.values.elementAt(i),
                          color: colors[i % colors.length],
                          title:
                              '${(data.values.elementAt(i) / totalExpenses * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < data.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[i % colors.length],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data.keys.elementAt(i)} (${money(data.values.elementAt(i))})',
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
