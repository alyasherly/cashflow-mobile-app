import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/cashflow_provider.dart';
import '../../models/transaction_model.dart';

enum DateFilter { all, daily, weekly, monthly, yearly }

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  DateFilter _dateFilter = DateFilter.all;

  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// ===== WEEK HELPER =====
  bool _isSameWeek(DateTime a, DateTime b) {
    final aWeek = a.difference(DateTime(a.year)).inDays ~/ 7;
    final bWeek = b.difference(DateTime(b.year)).inDays ~/ 7;
    return a.year == b.year && aWeek == bWeek;
  }

  /// ===== FILTER =====
  List<CashTransaction> _filtered(
    List<CashTransaction> tx,
    TransactionType type,
  ) {
    return tx.where((t) {
      final dateMatch = switch (_dateFilter) {
        DateFilter.all => true,
        DateFilter.daily =>
          t.date.year == _selectedDate.year &&
          t.date.month == _selectedDate.month &&
          t.date.day == _selectedDate.day,
        DateFilter.weekly => _isSameWeek(t.date, _selectedDate),
        DateFilter.monthly =>
          t.date.year == _selectedYear &&
          t.date.month == _selectedMonth,
        DateFilter.yearly => t.date.year == _selectedYear,
      };

      return dateMatch && t.type == type;
    }).toList();
  }

  Map<String, double> _groupByCategory(List<CashTransaction> list) {
    final map = <String, double>{};
    for (var t in list) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double _total(List<CashTransaction> list) =>
      list.fold(0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();

    final expense =
        _filtered(provider.transactions, TransactionType.expense);
    final income =
        _filtered(provider.transactions, TransactionType.income);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// ===== FILTER =====
              DropdownButtonFormField<DateFilter>(
                initialValue: _dateFilter,
                items: const [
                  DropdownMenuItem(
                      value: DateFilter.all, child: Text('All')),
                  DropdownMenuItem(
                      value: DateFilter.daily, child: Text('Daily')),
                  DropdownMenuItem(
                      value: DateFilter.weekly, child: Text('Weekly')),
                  DropdownMenuItem(
                      value: DateFilter.monthly, child: Text('Monthly')),
                  DropdownMenuItem(
                      value: DateFilter.yearly, child: Text('Yearly')),
                ],
                onChanged: (v) => setState(() => _dateFilter = v!),
                decoration:
                    const InputDecoration(labelText: 'Date Filter'),
              ),

              const SizedBox(height: 12),

              /// ===== DATE PICKER =====
              if (_dateFilter == DateFilter.daily ||
                  _dateFilter == DateFilter.weekly)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${_selectedDate.toString().split(' ')[0]}',
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

              if (_dateFilter == DateFilter.monthly)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedMonth,
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (v) =>
                            setState(() => _selectedMonth = v!),
                        decoration:
                            const InputDecoration(labelText: 'Month'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(
                            value: 2020 + i,
                            child: Text('${2020 + i}'),
                          ),
                        ),
                        onChanged: (v) =>
                            setState(() => _selectedYear = v!),
                        decoration:
                            const InputDecoration(labelText: 'Year'),
                      ),
                    ),
                  ],
                ),

              if (_dateFilter == DateFilter.yearly)
                DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  items: List.generate(
                    10,
                    (i) => DropdownMenuItem(
                      value: 2020 + i,
                      child: Text('${2020 + i}'),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _selectedYear = v!),
                  decoration:
                      const InputDecoration(labelText: 'Year'),
                ),

              const SizedBox(height: 24),

              /// ===== TOTAL BAR (NO OVERFLOW) =====
              SizedBox(
                height: 110,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  children: [
                    _totalBar('Expense', _total(expense), Colors.red),
                    _totalBar('Income', _total(income), Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// ===== INDICATOR =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == i ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? Colors.blue
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              /// ===== PIE CHART (SAFE) =====
              AspectRatio(
                aspectRatio: 1.2,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  children: [
                    _pieChart(expense),
                    _pieChart(income),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== TOTAL BAR =====
  Widget _totalBar(String label, double value, Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rp ${value.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== PIE CHART =====
  Widget _pieChart(List<CashTransaction> list) {
    final data = _groupByCategory(list);
    if (data.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 4,
          sections: _sections(data),
        ),
      ),
    );
  }

  List<PieChartSectionData> _sections(Map<String, double> data) {
    final colors = [
      Colors.red,
      Colors.blue,
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
        color: color,
        title: e.value.toStringAsFixed(0),
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }
}
