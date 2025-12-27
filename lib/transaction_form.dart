import 'package:flutter/material.dart';

class TransactionForm extends StatelessWidget {
  const TransactionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            TextField(decoration: InputDecoration(labelText: 'Nominal')),
            TextField(decoration: InputDecoration(labelText: 'Category')),
            TextField(decoration: InputDecoration(labelText: 'Date')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: null, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
