import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cashflow_provider.dart';
import '../../models/transaction_model.dart';
import '../transaction/transaction_form.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cashflow = context.watch<CashflowProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BALANCE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Balance'),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${cashflow.balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Latest Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: cashflow.transactions.isEmpty
                  ? const Center(
                      child: Text('No transactions yet'),
                    )
                  : ListView.builder(
                      itemCount: cashflow.transactions.length,
                      itemBuilder: (context, index) {
                        final t = cashflow.transactions[index];
                        return ListTile(
                          title: Text(t.category),
                          subtitle: Text(
                            '${t.savingsType} • ${t.date.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${t.type == TransactionType.income ? '+' : '-'}Rp ${t.amount}',
                                style: TextStyle(
                                  color: t.type ==
                                          TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context
                                      .read<CashflowProvider>()
                                      .deleteTransaction(index);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionForm(
                                  transaction: t,
                                  index: index,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      /// ADD
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
