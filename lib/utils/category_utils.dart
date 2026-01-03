import 'package:flutter/material.dart';

/// Category icons and colors for visual enhancement
class CategoryUtils {
  static const Map<String, IconData> _categoryIcons = {
    // Income categories
    'salary': Icons.work,
    'gaji': Icons.work,
    'bonus': Icons.card_giftcard,
    'freelance': Icons.laptop,
    'investment': Icons.trending_up,
    'investasi': Icons.trending_up,
    'gift': Icons.card_giftcard,
    'refund': Icons.replay,
    
    // Expense categories
    'food': Icons.restaurant,
    'makan': Icons.restaurant,
    'makanan': Icons.restaurant,
    'transport': Icons.directions_car,
    'transportasi': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'belanja': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'hiburan': Icons.movie,
    'bills': Icons.receipt_long,
    'tagihan': Icons.receipt_long,
    'health': Icons.local_hospital,
    'kesehatan': Icons.local_hospital,
    'education': Icons.school,
    'pendidikan': Icons.school,
    'groceries': Icons.local_grocery_store,
    'utilities': Icons.electrical_services,
    'phone': Icons.phone_android,
    'internet': Icons.wifi,
    'rent': Icons.home,
    'sewa': Icons.home,
    'insurance': Icons.security,
    'asuransi': Icons.security,
    'travel': Icons.flight,
    'liburan': Icons.flight,
    'fitness': Icons.fitness_center,
    'olahraga': Icons.fitness_center,
    'clothing': Icons.checkroom,
    'pakaian': Icons.checkroom,
    'coffee': Icons.coffee,
    'kopi': Icons.coffee,
    'subscription': Icons.subscriptions,
    'langganan': Icons.subscriptions,
    'other': Icons.category,
    'lainnya': Icons.category,
  };

  static const Map<String, Color> _categoryColors = {
    'salary': Colors.green,
    'gaji': Colors.green,
    'bonus': Colors.teal,
    'freelance': Colors.blue,
    'investment': Colors.indigo,
    'investasi': Colors.indigo,
    'food': Colors.orange,
    'makan': Colors.orange,
    'makanan': Colors.orange,
    'transport': Colors.blue,
    'transportasi': Colors.blue,
    'shopping': Colors.pink,
    'belanja': Colors.pink,
    'entertainment': Colors.purple,
    'hiburan': Colors.purple,
    'bills': Colors.red,
    'tagihan': Colors.red,
    'health': Colors.red,
    'kesehatan': Colors.red,
    'education': Colors.amber,
    'pendidikan': Colors.amber,
  };

  /// Get icon for category (case-insensitive)
  static IconData getIcon(String category) {
    final key = category.toLowerCase().trim();
    return _categoryIcons[key] ?? Icons.category;
  }

  /// Get color for category (case-insensitive)
  static Color getColor(String category) {
    final key = category.toLowerCase().trim();
    return _categoryColors[key] ?? Colors.grey;
  }

  /// Get icon for savings type
  static IconData getSavingsIcon(String savingsType) {
    final key = savingsType.toLowerCase().trim();
    switch (key) {
      case 'cash':
      case 'tunai':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'e-wallet':
      case 'ewallet':
      case 'digital':
        return Icons.account_balance_wallet;
      case 'investment':
      case 'investasi':
        return Icons.trending_up;
      case 'savings':
      case 'tabungan':
        return Icons.savings;
      case 'credit':
      case 'kredit':
        return Icons.credit_card;
      default:
        return Icons.wallet;
    }
  }

  /// Get color for savings type
  static Color getSavingsColor(String savingsType) {
    final key = savingsType.toLowerCase().trim();
    switch (key) {
      case 'cash':
      case 'tunai':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'e-wallet':
      case 'ewallet':
      case 'digital':
        return Colors.purple;
      case 'investment':
      case 'investasi':
        return Colors.orange;
      default:
        return Colors.indigo;
    }
  }
}
