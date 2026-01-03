import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

/// Cashflow provider with Hive persistence
/// Manages transactions and savings types with local storage
class CashflowProvider extends ChangeNotifier {
  /// =========================
  /// STATE
  /// =========================
  List<CashTransaction> _transactions = [];
  List<String> _savingsTypes = ['Cash', 'Bank', 'E-Wallet'];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  /// =========================
  /// GETTERS (SAFE)
  /// =========================
  List<CashTransaction> get transactions => List.unmodifiable(_transactions);
  List<String> get savingsTypes => List.unmodifiable(_savingsTypes);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  /// =========================
  /// INITIALIZATION
  /// =========================
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load transactions from Hive
      _transactions = HiveService.getAllTransactions();

      // Load savings types from Hive
      _savingsTypes = HiveService.getAllSavingsTypes();

      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to load data: $e';
      debugPrint('CashflowProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
            t.savingsType == savings && t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expense = _transactions
        .where((t) =>
            t.savingsType == savings && t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return income - expense;
  }

  /// =========================
  /// BALANCE MAP PER SAVINGS
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
  Future<bool> addTransaction(CashTransaction transaction) async {
    _error = null;

    try {
      // Validate before saving
      final validationError = _validateTransaction(transaction);
      if (validationError != null) {
        _error = validationError;
        notifyListeners();
        return false;
      }

      // Save to Hive
      await HiveService.insertTransaction(transaction);

      // Update local state
      _transactions.add(transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(String id, CashTransaction transaction) async {
    _error = null;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      _error = 'Transaction not found';
      notifyListeners();
      return false;
    }

    try {
      final validationError = _validateTransaction(transaction);
      if (validationError != null) {
        _error = validationError;
        notifyListeners();
        return false;
      }

      // Update in Hive
      await HiveService.updateTransaction(transaction);

      // Update local state
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _error = null;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      _error = 'Transaction not found';
      notifyListeners();
      return false;
    }

    try {
      // Delete from Hive
      await HiveService.deleteTransaction(id);

      // Update local state
      _transactions.removeAt(index);
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    }
  }

  /// Find transaction by ID
  CashTransaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// =========================
  /// SAVINGS TYPE CRUD
  /// =========================
  Future<bool> addSavingsType(String name) async {
    _error = null;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      _error = 'Savings type name cannot be empty';
      notifyListeners();
      return false;
    }

    if (_savingsTypes.contains(trimmedName)) {
      _error = 'Savings type already exists';
      notifyListeners();
      return false;
    }

    try {
      await HiveService.addSavingsType(trimmedName);
      _savingsTypes.add(trimmedName);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add savings type: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSavingsType(String oldName, String newName) async {
    _error = null;

    final trimmedNewName = newName.trim();
    if (trimmedNewName.isEmpty) {
      _error = 'Savings type name cannot be empty';
      notifyListeners();
      return false;
    }

    final index = _savingsTypes.indexOf(oldName);
    if (index == -1) {
      _error = 'Savings type not found';
      notifyListeners();
      return false;
    }

    try {
      await HiveService.updateSavingsType(oldName, trimmedNewName);

      // Update local state
      _savingsTypes[index] = trimmedNewName;

      // Update transactions with old savings type
      for (var i = 0; i < _transactions.length; i++) {
        if (_transactions[i].savingsType == oldName) {
          _transactions[i] = _transactions[i].copyWith(
            savingsType: trimmedNewName,
          );
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update savings type: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSavingsType(String name) async {
    _error = null;

    if (!_savingsTypes.contains(name)) {
      _error = 'Savings type not found';
      notifyListeners();
      return false;
    }

    try {
      await HiveService.deleteSavingsType(name);

      // Update local state
      _savingsTypes.remove(name);
      _transactions.removeWhere((t) => t.savingsType == name);

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete savings type: $e';
      notifyListeners();
      return false;
    }
  }

  /// =========================
  /// VALIDATION
  /// =========================
  String? _validateTransaction(CashTransaction transaction) {
    if (transaction.amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (transaction.amount > 999999999999) {
      return 'Amount exceeds maximum limit';
    }

    if (transaction.category.trim().isEmpty) {
      return 'Category is required';
    }

    if (transaction.category.length > 100) {
      return 'Category name is too long';
    }

    if (!_savingsTypes.contains(transaction.savingsType)) {
      return 'Invalid savings type';
    }

    if (transaction.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Date cannot be in the future';
    }

    return null;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset all data (for logout/reset)
  Future<void> reset() async {
    _transactions = [];
    _savingsTypes = ['Cash', 'Bank', 'E-Wallet'];
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }
}
