import 'package:flutter/material.dart';

class Savings extends StatelessWidget {
  const Savings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Cash'),
              subtitle: const Text('Rp 2.500.000'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Bank BCA'),
              subtitle: const Text('Rp 7.500.000'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // add new savings
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
