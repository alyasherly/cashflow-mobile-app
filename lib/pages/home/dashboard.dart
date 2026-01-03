import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/cashflow_provider.dart';
import '../../models/transaction_model.dart';
import '../transaction/transaction_form.dart';
import '../profile/profile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// ===== GROUP BY CATEGORY =====
  Map<String, double> _groupByCategory(
    List<CashTransaction> list,
  ) {
    final Map<String, double> result = {};
    for (final t in list) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  /// ===== PIE SECTIONS =====
  List<PieChartSectionData> _buildSections(
    Map<String, double> data,
  ) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: 'No Data',
        ),
      ];
    }

    int i = 0;
    return data.entries.map((e) {
      final color = _colors[i++ % _colors.length];
      return PieChartSectionData(
        value: e.value,
        color: color,
        radius: 70,
        title: e.key,
        titleStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();

    final incomeTx = provider.transactions
        .where((t) => t.type == TransactionType.income)
        .toList();

    final expenseTx = provider.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final latest = provider.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: const TextStyle(fontSize: 14)),
            const Text('Welcome 👋', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Profile()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===== TOTAL BALANCE =====
            _balanceCard(provider),

            const SizedBox(height: 24),

            /// ===== QUICK ACTION =====
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Income'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionForm(
                            initialType: TransactionType.income,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove),
                    label: const Text('Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionForm(
                            initialType: TransactionType.expense,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// ===== PIE CHART =====
            const Text(
              'Cashflow Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 320,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _piePage(
                    title: 'Income',
                    sections: _buildSections(
                      _groupByCategory(incomeTx),
                    ),
                  ),
                  _piePage(
                    title: 'Expense',
                    sections: _buildSections(
                      _groupByCategory(expenseTx),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// ===== INDICATOR =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.blue : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            /// ===== LATEST TRANSACTIONS =====
            const Text(
              'Latest Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            if (latest.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No transactions')),
              )
            else
              ...latest.take(5).map((t) {
                final isIncome = t.type == TransactionType.income;
                return ListTile(
                  leading: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(t.category),
                  subtitle: Text(t.savingsType),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} Rp ${t.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// ===== PIE PAGE =====
  Widget _piePage({
    required String title,
    required List<PieChartSectionData> sections,
  }) {
    return Column(
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 45,
              sectionsSpace: 3,
              sections: sections,
            ),
          ),
        ),
      ],
    );
  }

  /// ===== BALANCE CARD =====
  Widget _balanceCard(CashflowProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'Rp ${provider.balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
