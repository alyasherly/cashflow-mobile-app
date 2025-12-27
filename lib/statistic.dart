import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'providers/cashflow_provider.dart';
import 'models/transaction_model.dart';

enum DateFilter { daily, monthly, yearly }
enum ChartType { income, expense }

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  DateFilter _dateFilter = DateFilter.monthly;
  ChartType _chartType = ChartType.expense;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  List<CashTransaction> _filtered(
      List<CashTransaction> transactions) {
    final now = DateTime.now();

    return transactions.where((t) {
      bool dateMatch = switch (_dateFilter) {
        DateFilter.daily => _sameDay(t.date, now),
        DateFilter.monthly => _sameMonth(t.date, now),
        DateFilter.yearly => t.date.year == now.year,
      };

      bool typeMatch = _chartType == ChartType.income
          ? t.type == TransactionType.income
          : t.type == TransactionType.expense;

      return dateMatch && typeMatch;
    }).toList();
  }

  Map<String, double> _groupByCategory(
      List<CashTransaction> list) {
    final Map<String, double> data = {};
    for (var t in list) {
      data[t.category] =
          (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();
    final filtered = _filtered(provider.transactions);
    final categoryData = _groupByCategory(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FILTER BAR
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DateFilter>(
                    value: _dateFilter,
                    items: const [
                      DropdownMenuItem(
                          value: DateFilter.daily,
                          child: Text('Daily')),
                      DropdownMenuItem(
                          value: DateFilter.monthly,
                          child: Text('Monthly')),
                      DropdownMenuItem(
                          value: DateFilter.yearly,
                          child: Text('Yearly')),
                    ],
                    onChanged: (v) =>
                        setState(() => _dateFilter = v!),
                    decoration:
                        const InputDecoration(labelText: 'Date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ChartType>(
                    value: _chartType,
                    items: const [
                      DropdownMenuItem(
                          value: ChartType.expense,
                          child: Text('Expense')),
                      DropdownMenuItem(
                          value: ChartType.income,
                          child: Text('Income')),
                    ],
                    onChanged: (v) =>
                        setState(() => _chartType = v!),
                    decoration:
                        const InputDecoration(labelText: 'Type'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// PIE CHART
            if (categoryData.isEmpty)
              const Expanded(
                child: Center(child: Text('No data')),
              )
            else
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: _buildSections(categoryData),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// LEGEND
            ...categoryData.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text('Rp ${e.value.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
      Map<String, double> data) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    int i = 0;
    return data.entries.map((e) {
      final color = colors[i++ % colors.length];
      return PieChartSectionData(
        value: e.value,
        title: '${e.value.toStringAsFixed(0)}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
