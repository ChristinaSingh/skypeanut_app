// lib/data/apis/api_models/flight_model.dart

class Flight {
  final String callsign;
  final String icao;
  final String airlineIata;
  final String airlineIcao;
  final String aircraftIata;
  final String aircraftIcao;
  final String registration;
  final String departure;
  final String arrival;
  final double latitude;
  final double longitude;
  final double altitudeM;
  final double altitudeFt;
  final double heading;
  final double speedKmh;
  final double speedKnots;
  final double verticalSpeed;
  final String status;
  final String estimatedArrivalInfo; // ← NEW

  const Flight({
    required this.callsign,
    required this.icao,
    required this.airlineIata,
    required this.airlineIcao,
    required this.aircraftIata,
    required this.aircraftIcao,
    required this.registration,
    required this.departure,
    required this.arrival,
    required this.latitude,
    required this.longitude,
    required this.altitudeM,
    required this.altitudeFt,
    required this.heading,
    required this.speedKmh,
    required this.speedKnots,
    required this.verticalSpeed,
    required this.status,
    required this.estimatedArrivalInfo, // ← NEW
  });

  factory Flight.fromJson(Map<String, dynamic> j) {
    final pos = j['position'] as Map<String, dynamic>? ?? {};
    final airline = j['airline'] as Map<String, dynamic>? ?? {};
    final aircraft = j['aircraft'] as Map<String, dynamic>? ?? {};

    return Flight(
      callsign: (j['callsign'] ?? '') as String,
      icao: (j['icao'] ?? '') as String,
      airlineIata: (airline['iata'] ?? '') as String,
      airlineIcao: (airline['icao'] ?? '') as String,
      aircraftIata: (aircraft['iata'] ?? '') as String,
      aircraftIcao: (aircraft['icao'] ?? '') as String,
      registration: (aircraft['registration'] ?? '') as String,
      departure: (j['departure'] ?? '') as String,
      arrival: (j['arrival'] ?? '') as String,
      latitude: _toDouble(pos['latitude']),
      longitude: _toDouble(pos['longitude']),
      altitudeM: _toDouble(j['altitude_m']),
      altitudeFt: _toDouble(j['altitude_ft']),
      heading: _toDouble(j['heading']),
      speedKmh: _toDouble(j['speed_kmh']),
      speedKnots: _toDouble(j['speed_knots']),
      verticalSpeed: _toDouble(j['vertical_speed']),
      status: (j['status'] ?? '') as String,
      estimatedArrivalInfo:
          (j['estimated_arrival_info'] ?? '') as String, // ← NEW
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // ── Existing getters ────────────────────────────────────────────────────────
  bool get onGround => altitudeFt < 100 && speedKnots < 30;

  bool get hasRoute => departure.isNotEmpty && arrival.isNotEmpty;

  String get displayCallsign => callsign.isNotEmpty ? callsign : icao;

  String get altitudeFormatted => '${altitudeFt.toStringAsFixed(0)} ft';

  String get speedFormatted => '${speedKnots.toStringAsFixed(0)} kts';

  String get headingFormatted => '${heading.toStringAsFixed(0)}°';

  // ── ETA getters ─────────────────────────────────────────────────────────────

  /// Extracts "1442H" → "14:42"
  String get etaTimeFormatted {
    if (estimatedArrivalInfo.isEmpty) return '—';
    final match = RegExp(r'(\d{2})(\d{2})H').firstMatch(estimatedArrivalInfo);
    if (match == null) return '—';
    return '${match.group(1)}:${match.group(2)}';
  }

  /// Extracts "65MIN" → 65
  int? get etaMinutes {
    if (estimatedArrivalInfo.isEmpty) return null;
    final match = RegExp(r'(\d+)MIN').firstMatch(estimatedArrivalInfo);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  /// "1h 5m" or "45m"
  String get etaDurationFormatted {
    final mins = etaMinutes;
    if (mins == null) return '—';
    if (mins < 60) return '${mins}m';
    return '${mins ~/ 60}h ${mins % 60}m';
  }
}
