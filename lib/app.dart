import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'stores/finance_store.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceStore(),
      child: MaterialApp(
        title: 'Personal Finance Tracker',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1B7F7A),
          useMaterial3: true,
          cardTheme: const CardTheme(
            elevation: 1,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
