// Charting and UI dependencies.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App domain models, state, and helpers.
import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

// Screen that visualizes monthly and yearly statistics.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Tracks the year selected in the dropdown.
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    // Listen to the finance store for reactive updates.
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        // Show an empty state when there are no transactions.
        if (store.transactions.isEmpty) {
          return const EmptyState(
            icon: Icons.bar_chart,
            title: 'No statistics yet',
            message: 'Add transactions to see monthly and yearly charts.',
          );
        }

        // Derive available years from transactions.
        final years = _availableYears(store.transactions);
        // Default to the largest year value.
        _selectedYear ??= years.last;
        // Keep the selection valid when data changes.
        if (!years.contains(_selectedYear)) {
          _selectedYear = years.last;
        }

        // Compute totals for charts.
        final monthly = _monthlyTotals(store.transactions, _selectedYear!);
        final yearly = _yearlyTotals(store.transactions, years);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top summary cards.
            _buildSummary(store),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Section title for monthly chart.
                Text(
                  'Monthly overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // Year selector to filter monthly chart.
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
                    // Update selection when user changes year.
                    if (value != null) {
                      setState(() => _selectedYear = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Monthly income/expense bars.
            _buildMonthlyChart(monthly),
            const SizedBox(height: 16),
            // Section title for yearly chart.
            Text(
              'Yearly overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Yearly income/expense bars.
            _buildYearlyChart(years, yearly),
          ],
        );
      },
    );
  }

  // Builds the income/expense summary cards.
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

  // Extracts all unique years from transactions.
  List<int> _availableYears(List<FinanceTransaction> transactions) {
    // Use a set to ensure uniqueness.
    final years =
        transactions.map((transaction) => transaction.date.year).toSet();
    // Sort ascending for consistent ordering.
    final sorted = years.toList()..sort();
    return sorted;
  }

  // Aggregates income and expense totals per month for a given year.
  List<_MonthlyTotals> _monthlyTotals(
    List<FinanceTransaction> transactions,
    int year,
  ) {
    // Initialize 12 months with zero totals.
    final totals = List.generate(
      12,
      (index) => _MonthlyTotals(month: index + 1, income: 0, expense: 0),
    );

    for (final transaction in transactions) {
      // Skip transactions outside the selected year.
      if (transaction.date.year != year) {
        continue;
      }
      // Map the transaction to its month bucket.
      final monthIndex = transaction.date.month - 1;
      // Accumulate by transaction type.
      if (transaction.type == TransactionType.income) {
        totals[monthIndex].income += transaction.amount;
      } else {
        totals[monthIndex].expense += transaction.amount;
      }
    }

    return totals;
  }

  // Aggregates income and expense totals per year for all available years.
  List<_YearlyTotals> _yearlyTotals(
    List<FinanceTransaction> transactions,
    List<int> years,
  ) {
    // Seed a map so missing years are still represented.
    final totals = {
      for (final year in years)
        year: _YearlyTotals(year: year, income: 0, expense: 0),
    };

    for (final transaction in transactions) {
      // Ignore transactions for years outside the requested list.
      final totalsForYear = totals[transaction.date.year];
      if (totalsForYear == null) {
        continue;
      }
      // Accumulate by transaction type.
      if (transaction.type == TransactionType.income) {
        totalsForYear.income += transaction.amount;
      } else {
        totalsForYear.expense += transaction.amount;
      }
    }

    // Preserve the original year ordering.
    return years.map((year) => totals[year]!).toList();
  }

  // Builds the monthly bar chart.
  Widget _buildMonthlyChart(List<_MonthlyTotals> monthly) {
    // Compute the max value to scale the chart.
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
              // Add headroom above the tallest bar.
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
                    // Format Y-axis labels as integers.
                    getTitlesWidget:
                        (value, _) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    // Use short month labels on the X-axis.
                    getTitlesWidget: (value, _) => Text(_monthLabel(value)),
                  ),
                ),
              ),
              barGroups:
                  monthly.map((item) {
                    // Pair income and expense bars for each month.
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

  // Builds the yearly bar chart.
  Widget _buildYearlyChart(List<int> years, List<_YearlyTotals> yearly) {
    // Compute the max value to scale the chart.
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
              // Add headroom above the tallest bar.
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
                    // Format Y-axis labels as integers.
                    getTitlesWidget:
                        (value, _) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      // Convert the bar index back to the year label.
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
                    // Each entry maps to a year and its totals.
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

  // Short label for months used on the chart X-axis.
  String _monthLabel(double value) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final index = value.toInt() - 1;
    if (index < 0 || index >= labels.length) {
      return '';
    }
    return labels[index];
  }
}

// Card widget used in the summary row.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  // Label shown above the value.
  final String label;
  // Formatted currency value.
  final String value;
  // Accent color for the value text.
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Use a Card for consistent elevation and padding.
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary label.
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            // Highlighted numeric value.
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

// Monthly totals for charting.
class _MonthlyTotals {
  _MonthlyTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  // Month number (1-12).
  final int month;
  // Accumulated income for the month.
  double income;
  // Accumulated expense for the month.
  double expense;
}

// Yearly totals for charting.
class _YearlyTotals {
  _YearlyTotals({
    required this.year,
    required this.income,
    required this.expense,
  });

  // Calendar year.
  final int year;
  // Accumulated income for the year.
  double income;
  // Accumulated expense for the year.
  double expense;
}
