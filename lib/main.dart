import 'package:flutter/material.dart';
import 'splash.dart';

void main() {
  runApp(const CashizyApp());
}

class CashizyApp extends StatelessWidget {
  const CashizyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashizy',
      theme: ThemeData(useMaterial3: true),
      home: const Splash(),
    );
  }
}
