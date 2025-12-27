import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cashflow_provider.dart';
import 'models/transaction_model.dart';

class TransactionForm extends StatefulWidget {
  final CashTransaction? transaction;
  final int? index;

  const TransactionForm({
    super.key,
    this.transaction,
    this.index,
  });

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
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _amountCtrl.text = widget.transaction!.amount.toString();
      _categoryCtrl.text = widget.transaction!.category;
      _savingsType = widget.transaction!.savingsType;
      _selectedDate = widget.transaction!.date;
      _type = widget.transaction!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Add Transaction'
              : 'Edit Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// DATE
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

            /// NOMINAL
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal'),
            ),

            /// CATEGORY
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            /// SAVINGS TYPE
            DropdownButtonFormField<String>(
              value: _savingsType,
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
              ],
              onChanged: (v) => setState(() => _savingsType = v!),
              decoration: const InputDecoration(labelText: 'Savings Type'),
            ),

            /// TYPE
            DropdownButtonFormField<TransactionType>(
              value: _type,
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
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),

            const SizedBox(height: 24),

            /// SAVE
            ElevatedButton(
              onPressed: () {
                final transaction = CashTransaction(
                  amount: double.parse(_amountCtrl.text),
                  category: _categoryCtrl.text,
                  savingsType: _savingsType,
                  date: _selectedDate,
                  type: _type,
                );

                final provider =
                    context.read<CashflowProvider>();

                if (widget.transaction == null) {
                  provider.addTransaction(transaction);
                } else {
                  provider.updateTransaction(
                    widget.index!,
                    transaction,
                  );
                }

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
