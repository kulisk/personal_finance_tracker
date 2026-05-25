import 'package:intl/intl.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  symbol: '€',
  decimalDigits: 2,
);

final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

String formatCurrency(double value) {
  return _currencyFormat.format(value);
}

String formatDate(DateTime date) {
  return _dateFormat.format(date);
}
