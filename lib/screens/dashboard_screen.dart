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