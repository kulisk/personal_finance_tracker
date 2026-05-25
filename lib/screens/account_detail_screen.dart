import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/formatters.dart';
import 'accounts_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        final account = store.accountById(accountId);
        if (account == null) {
          return const Scaffold(
            body: Center(child: Text('Account not found.')),
          );
        }

        final accountTransactions =
            store.transactions
                .where((transaction) => transaction.accountId == accountId)
                .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => showAccountFormDialog(context, account: account),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, store, account),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummary(account),
              const SizedBox(height: 16),
              _buildChart(account, accountTransactions),
              const SizedBox(height: 16),
              Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._buildRecent(accountTransactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(Account account) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current balance', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              formatCurrency(account.balance),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Initial balance: ${formatCurrency(account.initialBalance)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Account account, List<FinanceTransaction> transactions) {
    final series = _buildBalanceSeries(account, transactions);

    if (series.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No activity in the last two months.'),
        ),
      );
    }

    final minY = series.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = series.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.2 + 10;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: series.last.x,
              minY: minY - padding,
              maxY: maxY + padding,
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 15,
                    getTitlesWidget: (value, _) {
                      return Text('${value.toInt()}d');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, _) {
                      return Text(formatCurrency(value));
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: series,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFF1B7F7A),
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecent(List<FinanceTransaction> transactions) {
    if (transactions.isEmpty) {
      return [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No transactions for this account yet.'),
          ),
        ),
      ];
    }

    final items = [...transactions];
    items.sort((a, b) => b.date.compareTo(a.date));

    return items.take(5).map((transaction) {
      final sign = transaction.type == TransactionType.income ? '+' : '-';
      return Card(
        child: ListTile(
          title: Text(transaction.title),
          subtitle: Text(formatDate(transaction.date)),
          trailing: Text('$sign${formatCurrency(transaction.amount)}'),
        ),
      );
    }).toList();
  }

  List<FlSpot> _buildBalanceSeries(
    Account account,
    List<FinanceTransaction> transactions,
  ) {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 60));

    double balanceAtStart = account.initialBalance;
    final Map<int, double> dailyDelta = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (date.isBefore(startDate)) {
        balanceAtStart += _signedAmount(transaction);
      } else {
        final dayIndex = date.difference(startDate).inDays;
        dailyDelta[dayIndex] =
            (dailyDelta[dayIndex] ?? 0) + _signedAmount(transaction);
      }
    }

    final List<FlSpot> series = [];
    double runningBalance = balanceAtStart;
    for (int day = 0; day <= 60; day++) {
      runningBalance += dailyDelta[day] ?? 0;
      series.add(FlSpot(day.toDouble(), runningBalance));
    }

    return series;
  }

  double _signedAmount(FinanceTransaction transaction) {
    return transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FinanceStore store,
    Account account,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete account'),
            content: const Text(
              'Transactions linked to this account will keep their values but will not be linked to any account. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await store.deleteAccount(account);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
