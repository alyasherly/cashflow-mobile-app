import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/cashflow_provider.dart';
import '../../models/transaction_model.dart';

import 'package:file_picker/file_picker.dart';
import '../../widgets/attachment_preview.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TransactionForm extends StatefulWidget {
  final CashTransaction? transaction;
  final TransactionType? initialType;

  const TransactionForm({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _savingsType = 'Cash';
  TransactionType _type = TransactionType.expense;

  String? _attachmentPath;
  bool _isSubmitting = false;

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
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
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

    final savedFile = await file.copy('${attachDir.path}/$fileName');

    return savedFile.path;
  }

  /// ===== PICK FILE FUNCTION =====
  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final originalFile = File(result.files.single.path!);
        
        // Validate file size (max 10MB)
        final fileSize = await originalFile.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 10MB limit'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final savedPath = await _saveAttachmentToLocal(originalFile);

        setState(() {
          _attachmentPath = savedPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to attach file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ===== VALIDATE FORM =====
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid number';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (amount > 999999999999) {
      return 'Amount exceeds maximum limit';
    }
    
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category is required';
    }
    
    if (value.length > 100) {
      return 'Category is too long';
    }
    
    // Basic sanitization check
    if (RegExp(r'[<>"\x27;]').hasMatch(value)) {
      return 'Invalid characters in category';
    }
    
    return null;
  }

  /// ===== SUBMIT =====
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<CashflowProvider>();

      if (widget.transaction == null) {
        // Create new transaction
        final transaction = CashTransaction(
          amount: double.parse(_amountCtrl.text),
          category: _categoryCtrl.text.trim(),
          savingsType: _savingsType,
          date: _selectedDate,
          type: _type,
          attachmentPath: _attachmentPath,
        );

        final success = await provider.addTransaction(transaction);
        
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to add transaction'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        // Update existing transaction
        final updatedTransaction = widget.transaction!.copyWith(
          amount: double.parse(_amountCtrl.text),
          category: _categoryCtrl.text.trim(),
          savingsType: _savingsType,
          date: _selectedDate,
          type: _type,
          attachmentPath: _attachmentPath,
        );

        final success = await provider.updateTransaction(
          widget.transaction!.id,
          updatedTransaction,
        );

        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to update transaction'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();

    // Ensure selected savings type is valid
    if (!provider.savingsTypes.contains(_savingsType) && 
        provider.savingsTypes.isNotEmpty) {
      _savingsType = provider.savingsTypes.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Add Transaction'
              : 'Edit Transaction',
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              /// DATE
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
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
              ),
              const SizedBox(height: 16),

              /// NOMINAL
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: _validateAmount,
              ),
              const SizedBox(height: 16),

              /// CATEGORY
              TextFormField(
                controller: _categoryCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  counterText: '',
                ),
                validator: _validateCategory,
              ),
              const SizedBox(height: 16),

              /// SAVINGS TYPE
              DropdownButtonFormField<String>(
                initialValue: provider.savingsTypes.contains(_savingsType) 
                    ? _savingsType 
                    : provider.savingsTypes.firstOrNull ?? 'Cash',
                items: provider.savingsTypes
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _savingsType = v);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Savings Type',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              const SizedBox(height: 16),

              /// TYPE
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Income'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Expense'),
                      ],
                    ),
                  ),
                ],
                onChanged: widget.initialType != null
                    ? null
                    : (v) {
                        if (v != null) {
                          setState(() => _type = v);
                        }
                      },
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.swap_vert),
                ),
              ),

              const SizedBox(height: 24),

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
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Remove', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      setState(() => _attachmentPath = null);
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),

              /// SAVE BUTTON
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TransactionType.income 
                        ? Colors.green 
                        : Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
