import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/cashflow_provider.dart';
import 'dashboard.dart';
import '../transaction/savings.dart';
import '../history/history.dart';
import '../profile/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Dashboard(),
    Savings(),
    Statistic(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data provider (load from database)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CashflowProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: GNav(
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          tabBorderRadius: 16,
          activeColor: Theme.of(context).colorScheme.primary,
          color: Colors.grey,

          tabs: const [
            GButton(
              icon: Icons.dashboard_outlined,
              text: 'Dashboard',
            ),
            GButton(
              icon: Icons.savings_outlined,
              text: 'Savings',
            ),
            GButton(
              icon: Icons.bar_chart_outlined,
              text: 'Stats',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
