// Root application widget and dependency wiring.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'stores/finance_store.dart';
import 'stores/theme_store.dart';

// Top-level app widget with providers and theme.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide app-wide stores and theming.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceStore()),
        ChangeNotifierProvider(create: (_) => ThemeStore()),
      ],
      child: Consumer<ThemeStore>(
        builder: (context, themeStore, _) {
          // Material shell using the current theme seed.
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
