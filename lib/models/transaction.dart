class Transaction {
  final String title;
  final double amount;
  final bool isExpense;
  final String category;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
    this.note,
  });
}
