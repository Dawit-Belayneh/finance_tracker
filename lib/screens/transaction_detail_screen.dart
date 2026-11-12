import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Displays full details for a single [Transaction].
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final color = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? '-' : '+';
    final typeLabel = isExpense ? 'Expense' : 'Income';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$sign${money(transaction.amount)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.swap_vert,
                  label: 'Type',
                  value: typeLabel,
                ),
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: transaction.category,
                ),
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: formatFullDate(transaction.date),
                ),
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Time',
                  value: formatTime(transaction.date),
                ),
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.attach_money,
                  label: 'Amount',
                  value: money(transaction.amount),
                ),
                const Divider(height: 1),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Note',
                  value: (transaction.note != null &&
                          transaction.note!.trim().isNotEmpty)
                      ? transaction.note!
                      : 'No notes added',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
