import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class CashflowProvider extends ChangeNotifier {
  final List<CashTransaction> _transactions = [];

  List<CashTransaction> get transactions => _transactions;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  void addTransaction(CashTransaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(int index, CashTransaction transaction) {
    _transactions[index] = transaction;
    notifyListeners();
  }

  void deleteTransaction(int index) {
    _transactions.removeAt(index);
    notifyListeners();
  }
}
