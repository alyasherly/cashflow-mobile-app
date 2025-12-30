import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class CashflowProvider extends ChangeNotifier {
  /// =========================
  /// DATA
  /// =========================
  final List<CashTransaction> _transactions = [];

  final List<String> _savingsTypes = [
    'Cash',
    'Bank',
    'E-Wallet',
  ];

  /// =========================
  /// GETTERS (SAFE)
  /// =========================
  List<CashTransaction> get transactions =>
      List.unmodifiable(_transactions);

  List<String> get savingsTypes =>
      List.unmodifiable(_savingsTypes);

  /// =========================
  /// GLOBAL BALANCE
  /// =========================
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// =========================
  /// BALANCE PER SAVINGS TYPE
  /// =========================
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

  /// =========================
  /// BALANCE MAP PER SAVINGS
  /// (dipakai dashboard)
  /// =========================
  Map<String, double> get balanceBySavingsType {
    final Map<String, double> result = {};

    for (final s in _savingsTypes) {
      result[s] = balanceBySavings(s);
    }

    return result;
  }

  /// =========================
  /// TRANSACTION CRUD
  /// =========================
  void addTransaction(CashTransaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(int index, CashTransaction transaction) {
    if (index < 0 || index >= _transactions.length) return;

    _transactions[index] = transaction;
    notifyListeners();
  }

  void deleteTransaction(int index) {
    if (index < 0 || index >= _transactions.length) return;

    _transactions.removeAt(index);
    notifyListeners();
  }

  /// =========================
  /// SAVINGS TYPE CRUD
  /// =========================
  void addSavingsType(String name) {
    if (name.trim().isEmpty) return;
    if (_savingsTypes.contains(name)) return;

    _savingsTypes.add(name);
    notifyListeners();
  }

  void updateSavingsType(String oldName, String newName) {
    final index = _savingsTypes.indexOf(oldName);
    if (index == -1 || newName.trim().isEmpty) return;

    _savingsTypes[index] = newName;

    /// update transaksi yg pakai savings lama
    for (var i = 0; i < _transactions.length; i++) {
      final t = _transactions[i];
      if (t.savingsType == oldName) {
        _transactions[i] = CashTransaction(
          amount: t.amount,
          category: t.category,
          savingsType: newName,
          date: t.date,
          type: t.type,
          attachmentPath: t.attachmentPath,
        );
      }
    }

    notifyListeners();
  }

  void deleteSavingsType(String name) {
    if (!_savingsTypes.contains(name)) return;

    _savingsTypes.remove(name);

    /// hapus transaksi yg pakai savings tsb
    _transactions.removeWhere((t) => t.savingsType == name);

    notifyListeners();
  }
}
