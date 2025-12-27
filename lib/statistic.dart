import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cashflow_provider.dart';

class Statistic extends StatelessWidget {
  const Statistic({super.key});

  @override
  Widget build(BuildContext context) {
    final cashflow = context.watch<CashflowProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics', style: TextStyle(fontSize: 22)),

            const SizedBox(height: 24),
            Text('Total Income: Rp ${cashflow.totalIncome.toStringAsFixed(0)}'),
            Text('Total Expense: Rp ${cashflow.totalExpense.toStringAsFixed(0)}'),

            const SizedBox(height: 24),
            Text('Balance: Rp ${cashflow.balance.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
