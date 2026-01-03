import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash/splash.dart';
import 'providers/cashflow_provider.dart';
import 'providers/auth_provider.dart';
import 'services/hive_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CashflowProvider()),
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const Splash(),
    );
  }
}
