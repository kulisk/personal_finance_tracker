// Exchange rates screen with summary and chart.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/exchange_rate_point.dart';
import '../services/exchange_rate_service.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

// Shows EUR exchange rates against USD and GBP.
class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  // Service used to fetch exchange rates.
  final ExchangeRateService _service = ExchangeRateService();
  // Pending request for rate points.
  late Future<List<ExchangeRatePoint>> _futureRates;

  @override
  void initState() {
    super.initState();
    // Initial load.
    _futureRates = _service.fetchRates();
  }

  // Refreshes the data by reloading the future.
  void _reload() {
    setState(() {
      _futureRates = _service.fetchRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build based on future state.
    return FutureBuilder<List<ExchangeRatePoint>>(
      future: _futureRates,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show generic error UI.
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final points = snapshot.data ?? [];
        if (points.isEmpty) {
          return const EmptyState(
            icon: Icons.currency_exchange,
            title: 'No rate data',
            message: 'Try refreshing to load exchange rates.',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title and refresh control.
            _buildHeader(context),
            const SizedBox(height: 12),
            // Latest rate snapshot.
            _buildSummary(points),
            const SizedBox(height: 16),
            // Rate history chart.
            _buildChart(points),
            const SizedBox(height: 12),
            // Line legend.
            _buildLegend(),
          ],
        );
      },
    );
  }

  // Section header with refresh action.
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'EUR exchange rates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reload',
        ),
      ],
    );
  }

  // Summary card showing the rate snapshot.
  Widget _buildSummary(List<ExchangeRatePoint> points) {
    final latest = points.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate snapshot (${formatDate(latest.date)})',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RateTile(
                    label: 'EUR/USD',
                    value: formatRate(latest.usdRate),
                    color: const Color(0xFF1B8D5E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RateTile(
                    label: 'EUR/GBP',
                    value: formatRate(latest.gbpRate),
                    color: const Color(0xFF3949AB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Line chart for USD and GBP series.
  Widget _buildChart(List<ExchangeRatePoint> points) {
    final usdSpots = <FlSpot>[];
    final gbpSpots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < points.length; i++) {
      final usd = points[i].usdRate;
      final gbp = points[i].gbpRate;
      usdSpots.add(FlSpot(i.toDouble(), usd));
      gbpSpots.add(FlSpot(i.toDouble(), gbp));
      minY = [minY, usd, gbp].reduce((a, b) => a < b ? a : b);
      maxY = [maxY, usd, gbp].reduce((a, b) => a > b ? a : b);
    }

    final padding = (maxY - minY).abs() * 0.2 + 0.01;
    // Adjust label density based on dataset size.
    final labelStep =
        points.length <= 8
            ? 1
            : points.length <= 14
            ? 2
            : points.length <= 24
            ? 3
            : 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
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
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      if (index == 0 || index == points.length - 1) {
                        return const SizedBox.shrink();
                      }
                      if (index % labelStep != 0) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 10,
                        child: SizedBox(
                          width: 36,
                          child: Transform.rotate(
                            angle: -0.785398,
                            alignment: Alignment.topLeft,
                            child: Text(
                              formatShortDate(points[index].date),
                              style: const TextStyle(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget:
                        (value, meta) => SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            formatRate(value),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: usdSpots,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFF1B8D5E),
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: gbpSpots,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFF3949AB),
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Legend describing line colors.
  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: Color(0xFF1B8D5E), label: 'EUR/USD'),
        _LegendItem(color: Color(0xFF3949AB), label: 'EUR/GBP'),
      ],
    );
  }

  // Error view shown when the API call fails.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to load exchange rates.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check the connection and try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Small tile used in the summary card.
class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withAlpha(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Legend dot with label.
class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
