import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../utils/transaction_actions.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

/// Filter options for the transactions list.
enum TransactionFilter { all, income, expense }

/// Displays all transactions with search, income/expense filters, and details.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    required this.transactions,
    this.onTransactionAdded,
    this.onTransactionUpdated,
    this.onTransactionDeleted,
  });

  final List<Transaction> transactions;
  final ValueChanged<Transaction>? onTransactionAdded;
  final void Function(Transaction original, Transaction updated)?
      onTransactionUpdated;
  final ValueChanged<Transaction>? onTransactionDeleted;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionFilter _filter = TransactionFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = widget.transactions.where((t) {
      final matchesFilter = switch (_filter) {
        TransactionFilter.all => true,
        TransactionFilter.income => !t.isExpense,
        TransactionFilter.expense => t.isExpense,
      };
      if (!matchesFilter) return false;

      if (query.isEmpty) return true;
      return t.title.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query) ||
          (t.note?.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  double _filteredNet(List<Transaction> items) {
    return items.fold<double>(
      0,
      (sum, t) => sum + (t.isExpense ? -t.amount : t.amount),
    );
  }

  void _clearFilters() {
    setState(() {
      _filter = TransactionFilter.all;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _openDetails(Transaction transaction) {
    var current = transaction;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(
          transaction: transaction,
          onTransactionUpdated: (updated) {
            final previous = current;
            current = updated;
            if (widget.onTransactionUpdated != null) {
              widget.onTransactionUpdated!(previous, updated);
            } else {
              setState(
                () => replaceTransactionInList(
                  widget.transactions,
                  previous,
                  updated,
                ),
              );
            }
          },
          onTransactionDeleted: () {
            if (widget.onTransactionDeleted != null) {
              widget.onTransactionDeleted!(current);
            } else {
              setState(
                () => removeTransactionFromList(widget.transactions, current),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _openAddTransaction() async {
    final created = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute<Transaction>(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
    if (created == null) return;

    if (widget.onTransactionAdded != null) {
      widget.onTransactionAdded!(created);
    } else {
      setState(() => widget.transactions.add(created));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredTransactions;
    final net = _filteredNet(items);
    final hasActiveFilters =
        _filter != TransactionFilter.all || _searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('transaction_search_field'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by title, category, or note',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<TransactionFilter>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionFilter.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: TransactionFilter.income,
                      label: Text('Income'),
                    ),
                    ButtonSegment(
                      value: TransactionFilter.expense,
                      label: Text('Expenses'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (selection) {
                    setState(() => _filter = selection.first);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} ${items.length == 1 ? 'transaction' : 'transactions'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${net >= 0 ? '+' : '-'}${money(net.abs())}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: net >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matching transactions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your search or filter.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          if (hasActiveFilters) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final transaction = items[index];
                      return TransactionTile(
                        transaction: transaction,
                        onTap: () => _openDetails(transaction),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_add_fab',
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
