import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // PACKAGE
import 'providers/cashflow_provider.dart'; // FILE KITA
import 'models/transaction_model.dart';
import 'transaction_form.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cashflow = context.watch<CashflowProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Balance', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Rp ${cashflow.balance.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Latest Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...cashflow.transactions.map(
              (t) => ListTile(
                title: Text(t.category),
                subtitle: Text(t.savingsType),
                trailing: Text(
                  '${t.type == TransactionType.income ? '+' : '-'}Rp ${t.amount}',
                  style: TextStyle(
                    color: t.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
