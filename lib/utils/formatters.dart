// Formatting helpers for currency, dates, and rates.
import 'package:intl/intl.dart';

// Currency formatter for Euro amounts.
final NumberFormat _currencyFormat = NumberFormat.currency(
  symbol: '€',
  decimalDigits: 2,
);

// Date and rate formatters used across the UI.
final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
final DateFormat _shortDateFormat = DateFormat('dd/MM');
final NumberFormat _rateFormat = NumberFormat('0.0000');

// Formats a currency value in EUR.
String formatCurrency(double value) {
  return _currencyFormat.format(value);
}

// Formats a full date for display.
String formatDate(DateTime date) {
  return _dateFormat.format(date);
}

// Formats a compact date for chart labels.
String formatShortDate(DateTime date) {
  return _shortDateFormat.format(date);
}

// Formats an exchange rate value.
String formatRate(double value) {
  return _rateFormat.format(value);
}
