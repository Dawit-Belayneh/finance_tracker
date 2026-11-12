import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/categories.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Displays monthly and per-category budgets along with spending progress.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({
    super.key,
    required this.transactions,
    required this.monthlyBudget,
    required this.categoryBudgets,
    this.onMonthlyBudgetChanged,
    this.onCategoryBudgetSaved,
    this.onCategoryBudgetRemoved,
    this.initialMonth,
  });

  final List<Transaction> transactions;
  final double monthlyBudget;
  final Map<String, double> categoryBudgets;
  final ValueChanged<double>? onMonthlyBudgetChanged;
  final void Function(String category, double amount)? onCategoryBudgetSaved;
  final ValueChanged<String>? onCategoryBudgetRemoved;
  final DateTime? initialMonth;

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = _resolveInitialMonth();
  }

  DateTime _resolveInitialMonth() {
    if (widget.initialMonth != null) {
      return DateTime(widget.initialMonth!.year, widget.initialMonth!.month);
    }

    final now = DateTime.now();
    final hasCurrentMonth = widget.transactions.any(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );
    if (hasCurrentMonth || widget.transactions.isEmpty) {
      return DateTime(now.year, now.month);
    }

    final latest = widget.transactions.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
    return DateTime(latest.date.year, latest.date.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  List<Transaction> get _monthlyExpenses {
    return widget.transactions
        .where(
          (t) =>
              t.isExpense &&
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .toList();
  }

  double get _totalMonthlySpent =>
      _monthlyExpenses.fold<double>(0, (sum, t) => sum + t.amount);

  Map<String, double> get _spentByCategory {
    final Map<String, double> totals = {};
    for (final t in _monthlyExpenses) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  Future<void> _showMonthlyBudgetDialog() async {
    final result = await showDialog<_BudgetDialogResult>(
      context: context,
      builder: (_) => _BudgetDialog(
        title: 'Edit Monthly Budget',
        initialAmount: widget.monthlyBudget,
        autofocusAmount: true,
      ),
    );
    if (result != null && result.amount != null) {
      widget.onMonthlyBudgetChanged?.call(result.amount!);
    }
  }

  Future<void> _showCategoryBudgetDialog({String? existingCategory}) async {
    final categories = <String>{
      ...expenseCategories,
      ...widget.categoryBudgets.keys,
      ?existingCategory,
    }.toList();

    final initialCategory = existingCategory ??
        categories.firstWhere(
          (c) => !widget.categoryBudgets.containsKey(c),
          orElse: () => categories.first,
        );

    final result = await showDialog<_BudgetDialogResult>(
      context: context,
      builder: (_) => _BudgetDialog(
        title: existingCategory != null
            ? 'Edit $existingCategory Budget'
            : 'Set Category Budget',
        categories: existingCategory == null ? categories : null,
        initialCategory: initialCategory,
        existingBudgets: widget.categoryBudgets,
        initialAmount: widget.categoryBudgets[initialCategory],
        allowRemove: widget.onCategoryBudgetRemoved != null,
        autofocusAmount: existingCategory != null,
      ),
    );
    if (result == null) return;

    if (result.removed) {
      widget.onCategoryBudgetRemoved?.call(result.category);
    } else if (result.amount != null) {
      widget.onCategoryBudgetSaved?.call(result.category, result.amount!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spentByCategory = _spentByCategory;
    final categoryEntries = widget.categoryBudgets.entries.toList();
    final unbudgeted = spentByCategory.entries
        .where((e) => !widget.categoryBudgets.containsKey(e.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MonthSelector(
            month: _selectedMonth,
            onPrevious: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
          ),
          const SizedBox(height: 12),
          _BudgetProgressCard(
            title: 'Monthly Budget',
            subtitle: 'Total spending in ${formatMonthYear(_selectedMonth)}',
            spent: _totalMonthlySpent,
            limit: widget.monthlyBudget,
            isFeatured: true,
            onEdit: widget.onMonthlyBudgetChanged != null
                ? _showMonthlyBudgetDialog
                : null,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category Budgets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.onCategoryBudgetSaved != null)
                TextButton.icon(
                  key: const Key('add_category_budget_button'),
                  onPressed: () => _showCategoryBudgetDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Set budget'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (categoryEntries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    const Text('No category budgets set yet'),
                  ],
                ),
              ),
            )
          else
            ...categoryEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BudgetProgressCard(
                  title: entry.key,
                  spent: spentByCategory[entry.key] ?? 0,
                  limit: entry.value,
                  onEdit: widget.onCategoryBudgetSaved != null
                      ? () =>
                          _showCategoryBudgetDialog(existingCategory: entry.key)
                      : null,
                ),
              ),
            ),
          if (unbudgeted.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Unbudgeted Spending',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...unbudgeted.map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text('${money(entry.value)} spent this month'),
                  trailing: widget.onCategoryBudgetSaved != null
                      ? TextButton(
                          onPressed: () => _showCategoryBudgetDialog(
                            existingCategory: entry.key,
                          ),
                          child: const Text('Set budget'),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              formatMonthYear(month),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.title,
    required this.spent,
    required this.limit,
    this.subtitle,
    this.isFeatured = false,
    this.onEdit,
  });

  final String title;
  final String? subtitle;
  final double spent;
  final double limit;
  final bool isFeatured;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? spent / limit : 0.0;
    final clampedProgress = ratio.clamp(0.0, 1.0);
    final percent = (ratio * 100).round();
    final remaining = limit - spent;
    final isOver = remaining < 0;

    final Color statusColor;
    if (isOver) {
      statusColor = Colors.red;
    } else if (ratio >= 0.75) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    final statusText = isOver
        ? '${money(remaining.abs())} over budget'
        : '${money(remaining)} left';

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isFeatured ? colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percent%',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Edit $title',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: clampedProgress,
              minHeight: isFeatured ? 10 : 8,
              borderRadius: BorderRadius.circular(6),
              color: statusColor,
              backgroundColor: statusColor.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${money(spent)} / ${money(limit)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetDialogResult {
  const _BudgetDialogResult({
    required this.category,
    this.amount,
    this.removed = false,
  });

  final String category;
  final double? amount;
  final bool removed;
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.title,
    this.categories,
    this.initialCategory = '',
    this.existingBudgets = const {},
    this.initialAmount,
    this.allowRemove = false,
    this.autofocusAmount = false,
  });

  final String title;
  final List<String>? categories;
  final String initialCategory;
  final Map<String, double> existingBudgets;
  final double? initialAmount;
  final bool allowRemove;
  final bool autofocusAmount;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _controller = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter an amount';
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid amount greater than 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canRemove =
        widget.allowRemove && widget.existingBudgets.containsKey(_selectedCategory);

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.categories != null) ...[
              DropdownButtonFormField<String>(
                key: const Key('budget_category_dropdown'),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories!
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                    final existing = widget.existingBudgets[value];
                    _controller.text =
                        existing != null ? existing.toStringAsFixed(0) : '';
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: const Key('budget_amount_field'),
              controller: _controller,
              autofocus: widget.autofocusAmount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: _validateAmount,
            ),
          ],
        ),
      ),
      actions: [
        if (canRemove)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              _BudgetDialogResult(category: _selectedCategory, removed: true),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save_budget_button'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                _BudgetDialogResult(
                  category: _selectedCategory,
                  amount: double.parse(_controller.text.trim()),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
