import 'package:flutter/material.dart';

class Statistic extends StatelessWidget {
  const Statistic({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Chip(label: Text('Daily')),
              Chip(label: Text('Weekly')),
              Chip(label: Text('Monthly')),
              Chip(label: Text('Yearly')),
            ],
          ),

          const SizedBox(height: 24),

          // Placeholder chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Pie / Bar Chart Here'),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const ListTile(
            title: Text('Income'),
            trailing: Text('Rp 8.000.000'),
          ),
          const ListTile(
            title: Text('Expense'),
            trailing: Text('Rp 5.000.000'),
          ),
        ],
      ),
    );
  }
}
