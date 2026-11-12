import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Displays a single [Transaction] in a Material card list tile.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final sign = transaction.isExpense ? '-' : '+';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category} • ${formatShortDate(transaction.date)}',
        ),
        trailing: Text(
          '$sign${money(transaction.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
