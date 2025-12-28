import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cashflow_provider.dart';
import 'models/transaction_model.dart';

import 'package:file_picker/file_picker.dart';
import 'widgets/attachment_preview.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  String? _attachmentPath;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _amountCtrl.text = widget.transaction!.amount.toString();
      _categoryCtrl.text = widget.transaction!.category;
      _savingsType = widget.transaction!.savingsType;
      _selectedDate = widget.transaction!.date;
      _type = widget.transaction!.type;
      _attachmentPath = widget.transaction!.attachmentPath;
    }
  }

  /// ===== SAVE FILE TO LOCAL STORAGE =====
  Future<String> _saveAttachmentToLocal(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final attachDir = Directory('${dir.path}/attachments');

    if (!attachDir.existsSync()) {
      attachDir.createSync(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';

    final savedFile =
        await file.copy('${attachDir.path}/$fileName');

    return savedFile.path;
  }

  /// ===== PICK FILE FUNCTION =====
  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final originalFile = File(result.files.single.path!);
      final savedPath = await _saveAttachmentToLocal(originalFile);

      setState(() {
        _attachmentPath = savedPath; // ✅ PATH AMAN
      });
    }
  }

  /// ===== SUBMIT =====
  void _submit() {
    final transaction = CashTransaction(
      amount: double.parse(_amountCtrl.text),
      category: _categoryCtrl.text,
      savingsType: _savingsType,
      date: _selectedDate,
      type: _type,
      attachmentPath: _attachmentPath,
    );

    final provider = context.read<CashflowProvider>();

    if (widget.transaction == null) {
      provider.addTransaction(transaction);
    } else {
      provider.updateTransaction(widget.index!, transaction);
    }

    Navigator.pop(context);
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
              initialValue: _savingsType,
              items: context
                  .watch<CashflowProvider>()
                  .savingsTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _savingsType = v!),
              decoration:
                  const InputDecoration(labelText: 'Savings Type'),
            ),

            /// TYPE
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
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),

            const SizedBox(height: 16),

            /// ATTACHMENT
            OutlinedButton.icon(
              onPressed: _pickAttachment,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),

            if (_attachmentPath != null) ...[
              const SizedBox(height: 12),
              AttachmentPreview(path: _attachmentPath!),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove attachment'),
                  onPressed: () {
                    setState(() => _attachmentPath = null);
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// SAVE
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
