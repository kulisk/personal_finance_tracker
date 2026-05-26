import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'accounts_screen.dart';
import 'rates_screen.dart';
import 'stats_screen.dart';
import 'transaction_form_screen.dart';
import 'transactions_screen.dart';
import '../stores/theme_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Color> _themeColors = [
    Color(0xFF1B7F7A),
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFF57C00),
    Color(0xFFD32F2F),
    Color(0xFF6A1B9A),
    Color(0xFF4E342E),
    Color(0xFF455A64),
  ];

  final List<Widget> _pages = const [
    TransactionsScreen(),
    AccountsScreen(),
    StatsScreen(),
    RatesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_index)),
        actions: [
          IconButton(
            tooltip: 'Theme color',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showThemeColorPicker(context),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () => _showThemeColorPicker(context),
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.primaryContainer,
        selectedItemColor: colorScheme.onPrimaryContainer,
        unselectedItemColor: colorScheme.onPrimaryContainer.withOpacity(0.7),
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Rates',
          ),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Transactions';
      case 1:
        return 'Accounts';
      case 2:
        return 'Statistics';
      case 3:
        return 'Exchange rates';
      default:
        return 'Personal Finance Tracker';
    }
  }

  Widget? _buildFab(BuildContext context) {
    if (_index == 0) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      );
    }

    if (_index == 1) {
      return FloatingActionButton(
        onPressed: () => showAccountFormDialog(context),
        child: const Icon(Icons.add),
      );
    }

    return null;
  }

  void _showThemeColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final selectedColor = sheetContext.watch<ThemeStore>().seedColor;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme color',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _themeColors
                      .map(
                        (color) => _buildColorSwatch(
                          sheetContext,
                          color,
                          selectedColor,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSwatch(
    BuildContext context,
    Color color,
    Color selectedColor,
  ) {
    final isSelected = color.value == selectedColor.value;
    final iconColor = _iconColorForSwatch(color);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        context.read<ThemeStore>().setSeedColor(color);
        Navigator.of(context).pop();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2,
          ),
        ),
        child:
            isSelected ? Icon(Icons.check, color: iconColor, size: 20) : null,
      ),
    );
  }

  Color _iconColorForSwatch(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
