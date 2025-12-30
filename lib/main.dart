import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash/splash.dart';
import 'providers/cashflow_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CashflowProvider(),
        ),
      ],
      child: const CashizyApp(),
    ),
  );
}

class CashizyApp extends StatelessWidget {
  const CashizyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashizy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const Splash(),
    );
  }
}
