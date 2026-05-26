class ExchangeRatePoint {
  ExchangeRatePoint({
    required this.date,
    required this.usdRate,
    required this.gbpRate,
  });

  final DateTime date;
  final double usdRate;
  final double gbpRate;
}
