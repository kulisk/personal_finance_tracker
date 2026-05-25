import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        if (store.transactions.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart,
            title: 'No statistics yet',
            message: 'Add transactions to see monthly and yearly charts.',
          );
        }

        final years = _availableYears(store.transactions);
        _selectedYear ??= years.last;
        if (!years.contains(_selectedYear)) {
          _selectedYear = years.last;
        }

        final monthly = _monthlyTotals(store.transactions, _selectedYear!);
        final yearly = _yearlyTotals(store.transactions, years);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummary(store),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items:
                      years
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedYear = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMonthlyChart(monthly),
            const SizedBox(height: 16),
            Text(
              'Yearly overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildYearlyChart(years, yearly),
          ],
        );
      },
    );
  }

  Widget _buildSummary(FinanceStore store) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Income',
            value: formatCurrency(store.totalIncome),
            color: const Color(0xFF1B8D5E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Expense',
            value: formatCurrency(store.totalExpense),
            color: const Color(0xFFC62828),
          ),
        ),
      ],
    );
  }

  List<int> _availableYears(List<FinanceTransaction> transactions) {
    final years =
        transactions.map((transaction) => transaction.date.year).toSet();
    final sorted = years.toList()..sort();
    return sorted;
  }

  List<_MonthlyTotals> _monthlyTotals(
    List<FinanceTransaction> transactions,
    int year,
  ) {
    final totals = List.generate(
      12,
      (index) => _MonthlyTotals(month: index + 1, income: 0, expense: 0),
    );

    for (final transaction in transactions) {
      if (transaction.date.year != year) {
        continue;
      }
      final monthIndex = transaction.date.month - 1;
      if (transaction.type == TransactionType.income) {
        totals[monthIndex].income += transaction.amount;
      } else {
        totals[monthIndex].expense += transaction.amount;
      }
    }

    return totals;
  }

  List<_YearlyTotals> _yearlyTotals(
    List<FinanceTransaction> transactions,
    List<int> years,
  ) {
    final totals = {
      for (final year in years)
        year: _YearlyTotals(year: year, income: 0, expense: 0),
    };

    for (final transaction in transactions) {
      final totalsForYear = totals[transaction.date.year];
      if (totalsForYear == null) {
        continue;
      }
      if (transaction.type == TransactionType.income) {
        totalsForYear.income += transaction.amount;
      } else {
        totalsForYear.expense += transaction.amount;
      }
    }

    return years.map((year) => totals[year]!).toList();
  }

  Widget _buildMonthlyChart(List<_MonthlyTotals> monthly) {
    final maxValue = monthly
        .map((item) => item.income > item.expense ? item.income : item.expense)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxValue + 10,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget:
                        (value, _) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => Text(_monthLabel(value)),
                  ),
                ),
              ),
              barGroups:
                  monthly.map((item) {
                    return BarChartGroupData(
                      x: item.month,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: item.income,
                          width: 6,
                          color: const Color(0xFF1B8D5E),
                        ),
                        BarChartRodData(
                          toY: item.expense,
                          width: 6,
                          color: const Color(0xFFC62828),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyChart(List<int> years, List<_YearlyTotals> yearly) {
    final maxValue = yearly
        .map((item) => item.income > item.expense ? item.income : item.expense)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxValue + 10,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget:
                        (value, _) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= years.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(years[index].toString());
                    },
                  ),
                ),
              ),
              barGroups:
                  yearly.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: item.income,
                          width: 8,
                          color: const Color(0xFF1B8D5E),
                        ),
                        BarChartRodData(
                          toY: item.expense,
                          width: 8,
                          color: const Color(0xFFC62828),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _monthLabel(double value) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final index = value.toInt() - 1;
    if (index < 0 || index >= labels.length) {
      return '';
    }
    return labels[index];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTotals {
  _MonthlyTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  final int month;
  double income;
  double expense;
}

class _YearlyTotals {
  _YearlyTotals({
    required this.year,
    required this.income,
    required this.expense,
  });

  final int year;
  double income;
  double expense;
}
