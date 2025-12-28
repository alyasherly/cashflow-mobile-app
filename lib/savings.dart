import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cashflow_provider.dart';

class Savings extends StatelessWidget {
  const Savings({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.savingsTypes.length,
        itemBuilder: (context, index) {
          final s = provider.savingsTypes[index];
          final balance = provider.balanceBySavings(s);

          return Card(
            child: ListTile(
              title: Text(s),
              subtitle: Text(
                'Balance: Rp ${balance.toStringAsFixed(0)}',
                style: TextStyle(
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, s);
                  } else if (value == 'delete') {
                    provider.deleteSavingsType(s);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Savings Type'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'e.g. Investment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<CashflowProvider>()
                    .addSavingsType(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Savings Type'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<CashflowProvider>()
                    .updateSavingsType(
                      oldName,
                      controller.text,
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
