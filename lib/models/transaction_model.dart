enum TransactionType { income, expense }

class CashTransaction {
  final double amount;
  final String category;
  final String savingsType;
  final DateTime date;
  final TransactionType type;

  CashTransaction({
    required this.amount,
    required this.category,
    required this.savingsType,
    required this.date,
    required this.type,
  });
}
