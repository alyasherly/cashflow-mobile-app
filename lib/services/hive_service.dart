import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

/// Hive database service for persistent storage of transactions
/// Lightweight NoSQL storage with type adapters
class HiveService {
  static const String _transactionsBox = 'transactions';
  static const String _savingsTypesBox = 'savings_types';
  static const String _settingsBox = 'settings';

  static bool _isInitialized = false;

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CashTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }

    // Open boxes
    await Hive.openBox<CashTransaction>(_transactionsBox);
    await Hive.openBox<String>(_savingsTypesBox);
    await Hive.openBox(_settingsBox);

    // Initialize default savings types if empty
    final savingsBox = Hive.box<String>(_savingsTypesBox);
    if (savingsBox.isEmpty) {
      await savingsBox.addAll(['Cash', 'Bank', 'E-Wallet']);
    }

    _isInitialized = true;
  }

  // ==========================================
  // TRANSACTION OPERATIONS
  // ==========================================

  /// Get transactions box
  static Box<CashTransaction> get _transactions =>
      Hive.box<CashTransaction>(_transactionsBox);

  /// Insert a new transaction
  static Future<void> insertTransaction(CashTransaction transaction) async {
    await _transactions.put(transaction.id, transaction);
  }

  /// Get all transactions
  static List<CashTransaction> getAllTransactions() {
    final transactions = _transactions.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Get transactions by type
  static List<CashTransaction> getTransactionsByType(TransactionType type) {
    return _transactions.values
        .where((t) => t.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions by date range
  static List<CashTransaction> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactions.values
        .where((t) =>
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Update a transaction
  static Future<void> updateTransaction(CashTransaction transaction) async {
    await _transactions.put(transaction.id, transaction);
  }

  /// Delete a transaction
  static Future<void> deleteTransaction(String id) async {
    await _transactions.delete(id);
  }

  /// Delete all transactions
  static Future<void> deleteAllTransactions() async {
    await _transactions.clear();
  }

  // ==========================================
  // SAVINGS TYPE OPERATIONS
  // ==========================================

  /// Get savings types box
  static Box<String> get _savingsTypes => Hive.box<String>(_savingsTypesBox);

  /// Get all savings types
  static List<String> getAllSavingsTypes() {
    return _savingsTypes.values.toList();
  }

  /// Add a savings type
  static Future<void> addSavingsType(String name) async {
    if (!_savingsTypes.values.contains(name)) {
      await _savingsTypes.add(name);
    }
  }

  /// Update a savings type (also updates related transactions)
  static Future<void> updateSavingsType(String oldName, String newName) async {
    // Find and update the savings type
    final keys = _savingsTypes.keys.toList();
    for (final key in keys) {
      if (_savingsTypes.get(key) == oldName) {
        await _savingsTypes.put(key, newName);
        break;
      }
    }

    // Update related transactions
    final transactionsToUpdate = _transactions.values
        .where((t) => t.savingsType == oldName)
        .toList();

    for (final t in transactionsToUpdate) {
      final updated = t.copyWith(savingsType: newName);
      await _transactions.put(t.id, updated);
    }
  }

  /// Delete a savings type (and related transactions)
  static Future<void> deleteSavingsType(String name) async {
    // Delete related transactions
    final transactionsToDelete =
        _transactions.values.where((t) => t.savingsType == name).toList();

    for (final t in transactionsToDelete) {
      await _transactions.delete(t.id);
    }

    // Delete savings type
    final keys = _savingsTypes.keys.toList();
    for (final key in keys) {
      if (_savingsTypes.get(key) == name) {
        await _savingsTypes.delete(key);
        break;
      }
    }
  }

  // ==========================================
  // DATABASE UTILITIES
  // ==========================================

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Reset database (delete all data)
  static Future<void> resetDatabase() async {
    await _transactions.clear();
    await _savingsTypes.clear();

    // Re-add default savings types
    await _savingsTypes.addAll(['Cash', 'Bank', 'E-Wallet']);
  }
}
