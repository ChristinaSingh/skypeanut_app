// lib/data/services/flight_api_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../apis/api_models/flight_model.dart';

class FlightApiException implements Exception {
  final String message;
  const FlightApiException(this.message);
  @override
  String toString() => 'FlightApiException: $message';
}

class FlightApiService {
  static const _base =
      'https://python.aitechnotech.in/skypeanut-api/api/v1/map';

  http.Client _client;

  FlightApiService({http.Client? client}) : _client = client ?? http.Client();

  void cancelActiveRequests() {
    _client.close();
    _client = http.Client();
  }

  // ── Fetch flights in bounding box ─────────────────────────────────────────
  Future<List<Flight>> fetchFlights({
    required double lamin,
    required double lamax,
    required double lomin,
    required double lomax,
    int limit = 300,
  }) async {
    final uri = Uri.parse('$_base/flights').replace(
      queryParameters: {
        'lamin': lamin.toStringAsFixed(6),
        'lamax': lamax.toStringAsFixed(6),
        'lomin': lomin.toStringAsFixed(6),
        'lomax': lomax.toStringAsFixed(6),
        'limit': limit.toString(),
      },
    );

    log('[FlightApiService] GET $uri');

    try {
      final res = await _client.get(uri, headers: {
        'accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is! List) return [];
        return data
            .whereType<Map<String, dynamic>>()
            .map(Flight.fromJson)
            .where((f) => f.latitude != 0 && f.longitude != 0)
            .toList();
      }

      throw FlightApiException('HTTP ${res.statusCode}');
    } catch (e) {
      if (e is FlightApiException) rethrow;
      throw FlightApiException('Network error: $e');
    }
  }

  // ── Fetch airports in bounding box ────────────────────────────────────────
  Future<List<AirportInfo>> fetchAirports({
    required double lamin,
    required double lamax,
    required double lomin,
    required double lomax,
  }) async {
    final uri = Uri.parse('$_base/airports').replace(
      queryParameters: {
        'lamin': lamin.toStringAsFixed(6),
        'lamax': lamax.toStringAsFixed(6),
        'lomin': lomin.toStringAsFixed(6),
        'lomax': lomax.toStringAsFixed(6),
      },
    );

    try {
      final res = await _client.get(uri, headers: {
        'accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'];
        if (data is! List) return [];
        return data
            .whereType<Map<String, dynamic>>()
            .map(AirportInfo.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      log('[FlightApiService] airports error: $e');
      return [];
    }
  }

  void dispose() => _client.close();
}

// ── Airport model ─────────────────────────────────────────────────────────────
class AirportInfo {
  final String iataCode;
  final String icaoCode;
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  const AirportInfo({
    required this.iataCode,
    required this.icaoCode,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> j) => AirportInfo(
        iataCode: (j['iata_code'] ?? '') as String,
        icaoCode: (j['icao_code'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        country: (j['country'] ?? '') as String,
        latitude: _d(j['latitude']),
        longitude: _d(j['longitude']),
        timezone: (j['timezone'] ?? '') as String,
      );

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
