import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/categories.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Screen for creating or editing an income or expense [Transaction].
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialTransaction,
  });

  final Transaction? initialTransaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late bool _isExpense;
  late String _category;
  late DateTime _selectedDate;

  bool get _isEditing => widget.initialTransaction != null;

  List<String> get _availableCategories {
    final base = _isExpense ? expenseCategories : incomeCategories;
    return <String>{...base, _category}.toList();
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTransaction;
    if (initial != null) {
      _isExpense = initial.isExpense;
      _category = initial.category;
      _selectedDate = initial.date;
      _amountController = TextEditingController(
        text: initial.amount.toStringAsFixed(2),
      );
      final initialDescription = initial.note ??
          (initial.title == initial.category ? '' : initial.title);
      _descriptionController = TextEditingController(text: initialDescription);
    } else {
      _isExpense = true;
      _category = expenseCategories.first;
      _selectedDate = DateTime.now();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTypeChanged(bool isExpense) {
    if (_isExpense == isExpense) return;
    setState(() {
      _isExpense = isExpense;
      final base = _isExpense ? expenseCategories : incomeCategories;
      _category = base.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _isEditing ? _selectedDate.hour : now.hour,
        _isEditing ? _selectedDate.minute : now.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim();

    final transaction = Transaction(
      title: description.isNotEmpty ? description : _category,
      amount: amount,
      isExpense: _isExpense,
      category: _category,
      date: _selectedDate,
      note: description.isNotEmpty ? description : null,
    );

    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              key: const Key('transaction_type_selector'),
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.arrow_upward),
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.arrow_downward),
                  label: Text('Income'),
                ),
              ],
              selected: {_isExpense},
              onSelectionChanged: (selection) => _onTypeChanged(selection.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('amount_field'),
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: '$activeCurrencySymbol ',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(text);
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('category_${_isExpense}_$_category'),
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _availableCategories
                  .map(
                    (cat) => DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              key: const Key('date_picker_field'),
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(formatFullDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('description_field'),
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional — defaults to category',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('save_transaction_button'),
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
