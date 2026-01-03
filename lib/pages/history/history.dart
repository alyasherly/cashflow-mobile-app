import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cashflow_provider.dart';
import '../../models/transaction_model.dart';
import '../transaction/transaction_form.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  TransactionType? _filterType; // null = ALL

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();

    final transactions = provider.transactions
        .where((t) => _filterType == null || t.type == _filterType)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          /// ===== FILTER =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _filterChip(
                  label: 'All',
                  selected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Income',
                  selected: _filterType == TransactionType.income,
                  color: Colors.green,
                  onTap: () =>
                      setState(() => _filterType = TransactionType.income),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'Expense',
                  selected: _filterType == TransactionType.expense,
                  color: Colors.red,
                  onTap: () =>
                      setState(() => _filterType = TransactionType.expense),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// ===== LIST =====
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      final isIncome =
                          t.type == TransactionType.income;

                      return ListTile(
                        onTap: () {
                          /// TAP → EDIT TRANSACTION
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionForm(
                                transaction: t,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              isIncome ? Colors.green : Colors.red,
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          t.category,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${t.savingsType} • ${_formatDate(t.date)}',
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'} Rp ${t.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color:
                                isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// ===== FILTER CHIP =====
  Widget _filterChip({
    required String label,
    required bool selected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? Colors.blue)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
