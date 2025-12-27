import 'package:flutter/material.dart';
import 'savings.dart';
import 'transaction_form.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Balance: Rp 10.000.000'),
            ),
          ),

          const SizedBox(height: 16),
          ListTile(
            title: const Text('Cards'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Savings()),
            ),
          ),
          ListTile(
            title: const Text('Add Income / Expense'),
            trailing: const Icon(Icons.add),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionForm()),
            ),
          ),
        ],
      ),
    );
  }
}
