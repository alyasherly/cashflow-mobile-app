import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cashflow_provider.dart';
import 'models/transaction_model.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _savingsType = 'Cash';
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // DATE
            ListTile(
              title: Text(
                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),

            // NOMINAL
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal'),
            ),

            // CATEGORY
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            // SAVINGS TYPE
            DropdownButtonFormField<String>(
              initialValue: _savingsType,
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
              ],
              onChanged: (value) => setState(() => _savingsType = value!),
              decoration: const InputDecoration(labelText: 'Savings Type'),
            ),

            // INCOME / EXPENSE
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(
                  value: TransactionType.income,
                  child: Text('Income'),
                ),
                DropdownMenuItem(
                  value: TransactionType.expense,
                  child: Text('Expense'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                context.read<CashflowProvider>().addTransaction(
                  CashTransaction(
                    amount: double.parse(_amountCtrl.text),
                    category: _categoryCtrl.text,
                    savingsType: _savingsType,
                    date: _selectedDate,
                    type: _type,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
