import 'dart:convert';

import 'package:http/http.dart' as http;

class Holiday {
  Holiday({
    required this.date,
    required this.name,
    required this.locale,
  });

  final DateTime date;
  final String name;
  final String locale;
}

class HolidaySyncResult {
  HolidaySyncResult({
    required this.holidays,
    required this.fetchedAt,
    required this.source,
  });

  final List<Holiday> holidays;
  final DateTime fetchedAt;
  final Uri source;
}

class HolidaySyncService {
  HolidaySyncService({
    http.Client? client,
    this.endpoint = 'https://date.nager.at/api/v3/PublicHolidays',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String endpoint;
  HolidaySyncResult? _cache;

  Future<HolidaySyncResult> fetch({
    required int year,
    required String countryCode,
  }) async {
    final now = DateTime.now().toUtc();
    final previous = _cache;
    if (previous != null && previous.fetchedAt.isAfter(now.subtract(const Duration(hours: 6)))) {
      return previous;
    }

    final uri = Uri.parse('$endpoint/$year/$countryCode');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw HolidaySyncException('Failed to fetch holidays: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    final holidays = decoded
        .map((dynamic item) => Holiday(
              date: DateTime.parse(item['date'] as String),
              name: item['localName'] as String,
              locale: item['countryCode'] as String,
            ),)
        .toList();
    final result = HolidaySyncResult(holidays: holidays, fetchedAt: now, source: uri);
    _cache = result;
    return result;
  }

  void dispose() {
    _client.close();
  }
}

class HolidaySyncException implements Exception {
  HolidaySyncException(this.message);
  final String message;

  @override
  String toString() => 'HolidaySyncException: $message';
}
