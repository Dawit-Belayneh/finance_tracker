import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';

/// Displays full details for a single [Transaction] with Edit and Delete actions.
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.onTransactionUpdated,
    this.onTransactionDeleted,
  });

  final Transaction transaction;
  final ValueChanged<Transaction>? onTransactionUpdated;
  final VoidCallback? onTransactionDeleted;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _editTransaction() async {
    final updated = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute<Transaction>(
        builder: (_) => AddTransactionScreen(initialTransaction: _transaction),
      ),
    );
    if (updated == null || !mounted) return;

    setState(() => _transaction = updated);
    widget.onTransactionUpdated?.call(updated);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction?'),
          content: Text(
            'Are you sure you want to delete "${_transaction.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm_delete_button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    widget.onTransactionDeleted?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _transaction.isExpense;
    final color = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? '-' : '+';
    final typeLabel = isExpense ? 'Expense' : 'Income';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                          _transaction.title,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$sign${money(_transaction.amount)}',
                          style:
                              Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Transaction Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
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
                        value: _transaction.category,
                      ),
                      const Divider(height: 1),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: formatFullDate(_transaction.date),
                      ),
                      const Divider(height: 1),
                      _DetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'Time',
                        value: formatTime(_transaction.date),
                      ),
                      const Divider(height: 1),
                      _DetailRow(
                        icon: Icons.attach_money,
                        label: 'Amount',
                        value: money(_transaction.amount),
                      ),
                      const Divider(height: 1),
                      _DetailRow(
                        icon: Icons.notes_outlined,
                        label: 'Note',
                        value: (_transaction.note != null &&
                                _transaction.note!.trim().isNotEmpty)
                            ? _transaction.note!
                            : 'No notes added',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('edit_transaction_button'),
                      onPressed: _editTransaction,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('delete_transaction_button'),
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
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
