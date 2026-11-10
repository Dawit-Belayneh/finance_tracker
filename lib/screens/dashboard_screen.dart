import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

String money(double value) => '\$${value.toStringAsFixed(2)}';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Fake data for now. Later this comes from storage or your API.
  final List<Transaction> transactions = [
    Transaction(
      title: 'Salary',
      amount: 5000,
      isExpense: false,
      category: 'Salary',
      date: DateTime(2026, 11, 1),
    ),
    Transaction(
      title: 'Groceries',
      amount: 120,
      isExpense: true,
      category: 'Food',
      date: DateTime(2026, 11, 3),
    ),
    Transaction(
      title: 'Taxi',
      amount: 30,
      isExpense: true,
      category: 'Transport',
      date: DateTime(2026, 11, 5),
    ),
    Transaction(
      title: 'Electricity bill',
      amount: 200,
      isExpense: true,
      category: 'Bills',
      date: DateTime(2026, 11, 7),
    ),
    Transaction(
      title: 'Restaurant',
      amount: 80,
      isExpense: true,
      category: 'Food',
      date: DateTime(2026, 11, 8),
    ),
  ];

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
  void addSampleExpense() {
    setState(() {
      transactions.add(
        Transaction(
          title: 'Coffee',
          amount: 15,
          isExpense: true,
          category: 'Food',
          date: DateTime.now(),
        ),
      );
    });
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
          const Text(
            'Recent transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...recent.map(_transactionTile),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSampleExpense,
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

  // ---------- 4. One recent transaction ----------
  Widget _transactionTile(Transaction t) {
    final color = t.isExpense ? Colors.red : Colors.green;
    final sign = t.isExpense ? '-' : '+';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(t.title),
        subtitle: Text('${t.category} • ${t.date.day}/${t.date.month}/${t.date.year}'),
        trailing: Text(
          '$sign${money(t.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}