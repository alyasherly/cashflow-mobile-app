import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 0)
class CashTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String savingsType;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final TransactionType type;

  @HiveField(6)
  final String? attachmentPath;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  CashTransaction({
    String? id,
    required this.amount,
    required this.category,
    required this.savingsType,
    required this.date,
    required this.type,
    this.attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with updated fields
  CashTransaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? savingsType,
    DateTime? date,
    TransactionType? type,
    String? attachmentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      savingsType: savingsType ?? this.savingsType,
      date: date ?? this.date,
      type: type ?? this.type,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to Map for export/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'savings_type': savingsType,
      'date': date.toIso8601String(),
      'type': type.name,
      'attachment_path': attachmentPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory CashTransaction.fromMap(Map<String, dynamic> map) {
    return CashTransaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      savingsType: map['savings_type'] as String,
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      attachmentPath: map['attachment_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to JSON for API/export
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  factory CashTransaction.fromJson(Map<String, dynamic> json) =>
      CashTransaction.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CashTransaction(id: $id, amount: $amount, category: $category, '
        'type: $type, date: $date)';
  }
}
