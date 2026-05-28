// Data point for a single exchange rate snapshot.
class ExchangeRatePoint {
  ExchangeRatePoint({
    required this.date,
    required this.usdRate,
    required this.gbpRate,
  });

  // Date for the rate entry.
  final DateTime date;
  // EUR to USD rate.
  final double usdRate;
  // EUR to GBP rate.
  final double gbpRate;
}
