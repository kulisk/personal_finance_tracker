import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  symbol: '€',
  decimalDigits: 2,
);

final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
final DateFormat _shortDateFormat = DateFormat('dd/MM');
final NumberFormat _rateFormat = NumberFormat('0.0000');

String formatCurrency(double value) {
  return _currencyFormat.format(value);
}

String formatDate(DateTime date) {
  return _dateFormat.format(date);
}

String formatShortDate(DateTime date) {
  return _shortDateFormat.format(date);
}

String formatRate(double value) {
  return _rateFormat.format(value);
}
