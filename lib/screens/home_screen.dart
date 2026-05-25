import 'package:flutter/material.dart';

import 'accounts_screen.dart';
import 'stats_screen.dart';
import 'transaction_form_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    TransactionsScreen(),
    AccountsScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleForIndex(_index))),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
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
}
