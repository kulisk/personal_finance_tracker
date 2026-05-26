import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'stores/finance_store.dart';
import 'stores/theme_store.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceStore()),
        ChangeNotifierProvider(create: (_) => ThemeStore()),
      ],
      child: Consumer<ThemeStore>(
        builder: (context, themeStore, _) {
          return MaterialApp(
            title: 'Personal Finance Tracker',
            theme: ThemeData(
              colorSchemeSeed: themeStore.seedColor,
              useMaterial3: true,
              cardTheme: const CardTheme(
                elevation: 1,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
