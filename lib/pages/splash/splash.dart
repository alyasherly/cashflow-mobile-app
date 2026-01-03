import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cashflow_provider.dart';
import '../auth/pin_login.dart';
import '../auth/pin_setup.dart';
import '../home/home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize auth provider
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();

    // Small delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate based on auth state
    Widget nextPage;

    switch (authProvider.state) {
      case AuthState.needsSetup:
        nextPage = const PinSetupPage();
        break;
      case AuthState.authenticated:
        // Already authenticated (shouldn't happen normally)
        await context.read<CashflowProvider>().initialize();
        nextPage = const Home();
        break;
      case AuthState.unauthenticated:
      case AuthState.lockedOut:
      case AuthState.unknown:
        nextPage = const PinLoginPage();
        break;

    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cashizy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure Cashflow Manager',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
