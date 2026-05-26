import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/exchange_rate_point.dart';

class ExchangeRateService {
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  Future<List<ExchangeRatePoint>> fetchRates({int days = 30}) async {
    final normalizedDays = days < 1 ? 1 : days;

    try {
      final points = await _fetchTimeSeries(normalizedDays);
      if (points.isNotEmpty) {
        return points;
      }
    } catch (_) {}

    return _fetchLatest();
  }

  Future<List<ExchangeRatePoint>> _fetchTimeSeries(int days) async {
    final endDate = _dateOnly(DateTime.now());
    final startDate = endDate.subtract(Duration(days: days));

    final rangePath =
        '/${_apiDateFormat.format(startDate)}..${_apiDateFormat.format(endDate)}';
    final uri = Uri.https('api.frankfurter.app', rangePath, {
      'from': 'EUR',
      'to': 'USD,GBP',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exchange rates.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map) {
      throw Exception('Exchange rate service error.');
    }

    final rates = body['rates'];
    if (rates is! Map) {
      return [];
    }

    final points = <ExchangeRatePoint>[];
    for (final entry in rates.entries) {
      final date = DateTime.tryParse(entry.key);
      final values = entry.value;
      if (date == null || values is! Map) {
        continue;
      }

      final usd = values['USD'];
      final gbp = values['GBP'];
      if (usd is! num || gbp is! num) {
        continue;
      }

      points.add(
        ExchangeRatePoint(
          date: _dateOnly(date),
          usdRate: usd.toDouble(),
          gbpRate: gbp.toDouble(),
        ),
      );
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  Future<List<ExchangeRatePoint>> _fetchLatest() async {
    final uri = Uri.https('api.frankfurter.app', '/latest', {
      'from': 'EUR',
      'to': 'USD,GBP',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch exchange rates.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map) {
      throw Exception('Exchange rate service error.');
    }

    final rates = body['rates'];
    if (rates is! Map) {
      return [];
    }

    final date = DateTime.tryParse(body['date']?.toString() ?? '');
    final usd = rates['USD'];
    final gbp = rates['GBP'];
    if (date == null || usd is! num || gbp is! num) {
      return [];
    }

    return [
      ExchangeRatePoint(
        date: _dateOnly(date),
        usdRate: usd.toDouble(),
        gbpRate: gbp.toDouble(),
      ),
    ];
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
