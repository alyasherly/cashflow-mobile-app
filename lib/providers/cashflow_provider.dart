import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class CashflowProvider extends ChangeNotifier {
  final List<CashTransaction> _transactions = [];

  final List<String> _savingsTypes = [
    'Cash',
    'Bank',
    'E-Wallet',
  ];

  List<CashTransaction> get transactions => _transactions;
  List<String> get savingsTypes => _savingsTypes;

  // ===== BALANCE GLOBAL =====
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  // ===== BALANCE PER SAVINGS =====
  double balanceBySavings(String savings) {
    final income = _transactions
        .where((t) =>
            t.savingsType == savings &&
            t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expense = _transactions
        .where((t) =>
            t.savingsType == savings &&
            t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return income - expense;
  }

  // ===== TRANSACTION CRUD =====
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

  // ===== SAVINGS TYPE CRUD =====
  void addSavingsType(String name) {
    if (!_savingsTypes.contains(name)) {
      _savingsTypes.add(name);
      notifyListeners();
    }
  }

  void updateSavingsType(String oldName, String newName) {
    final index = _savingsTypes.indexOf(oldName);
    if (index == -1) return;

    _savingsTypes[index] = newName;

    // update transaksi yang pakai savings lama
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].savingsType == oldName) {
        _transactions[i] = CashTransaction(
          amount: _transactions[i].amount,
          category: _transactions[i].category,
          savingsType: newName,
          date: _transactions[i].date,
          type: _transactions[i].type,
        );
      }
    }

    notifyListeners();
  }

  void deleteSavingsType(String name) {
    _savingsTypes.remove(name);
    _transactions.removeWhere((t) => t.savingsType == name);
    notifyListeners();
  }
}
