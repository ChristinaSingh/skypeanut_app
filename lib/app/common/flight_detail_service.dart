import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

// ── Models ────────────────────────────────────────────────────────────────────

class WeatherInfo {
  final String raw;
  final String flightRules;
  final int? temperatureC;
  final int? windDirectionDeg;
  final int? windSpeedKt;
  final int? windGustKt;
  final int? visibilityM;
  final double? altimeterHpa;
  final List<CloudLayer> clouds;
  final List<String> wxCodes;

  const WeatherInfo({
    required this.raw,
    required this.flightRules,
    this.temperatureC,
    this.windDirectionDeg,
    this.windSpeedKt,
    this.windGustKt,
    this.visibilityM,
    this.altimeterHpa,
    required this.clouds,
    required this.wxCodes,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> j) {
    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? _dbl(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final temp = j['temperature'] as Map<String, dynamic>?;
    final wind = j['wind_direction'] as Map<String, dynamic>?;
    final ws = j['wind_speed'] as Map<String, dynamic>?;
    final wg = j['wind_gust'] as Map<String, dynamic>?;
    final vis = j['visibility'] as Map<String, dynamic>?;
    final alt = j['altimeter'] as Map<String, dynamic>?;

    final cloudsRaw = j['clouds'] as List? ?? [];
    final wxRaw = j['wx_codes'] as List? ?? [];

    return WeatherInfo(
      raw: (j['raw'] ?? '') as String,
      flightRules: (j['flight_rules'] ?? '') as String,
      temperatureC: _int(temp?['value']),
      windDirectionDeg: _int(wind?['value']),
      windSpeedKt: _int(ws?['value']),
      windGustKt: _int(wg?['value']),
      visibilityM: _int(vis?['value']),
      altimeterHpa: _dbl(alt?['value']),
      clouds: cloudsRaw
          .whereType<Map<String, dynamic>>()
          .map(CloudLayer.fromJson)
          .toList(),
      wxCodes: wxRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => (e['value'] ?? e['repr'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  String get windFormatted {
    if (windDirectionDeg == null || windSpeedKt == null) return '—';
    final gust = windGustKt != null ? ' G${windGustKt}kt' : '';
    return '${windDirectionDeg}° / ${windSpeedKt}kt$gust';
  }

  String get tempFormatted => temperatureC != null ? '${temperatureC}°C' : '—';

  String get visFormatted {
    if (visibilityM == null) return '—';
    if (visibilityM! >= 9999) return '10km+';
    return '${(visibilityM! / 1000).toStringAsFixed(1)}km';
  }

  String get pressureFormatted =>
      altimeterHpa != null ? '${altimeterHpa!.toStringAsFixed(0)} hPa' : '—';
}

class CloudLayer {
  final int altitude;
  final String type;
  final String? modifier;

  const CloudLayer({
    required this.altitude,
    required this.type,
    this.modifier,
  });

  factory CloudLayer.fromJson(Map<String, dynamic> j) => CloudLayer(
        altitude: (j['altitude'] as num?)?.toInt() ?? 0,
        type: (j['type'] ?? '') as String,
        modifier: j['modifier'] as String?,
      );

  String get formatted {
    final mod = modifier != null ? ' ($modifier)' : '';
    return '$type ${altitude * 100}ft$mod';
  }
}

class AirportDetail {
  final bool success;
  final String airportCode;
  final String icaoCode;
  final String name;
  final String? city;
  final String country;
  final double latitude;
  final double longitude;
  final WeatherInfo? weather;

  const AirportDetail({
    required this.success,
    required this.airportCode,
    required this.icaoCode,
    required this.name,
    this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.weather,
  });

  factory AirportDetail.fromJson(Map<String, dynamic> j) {
    WeatherInfo? wx;
    if (j['weather'] != null) {
      try {
        wx = WeatherInfo.fromJson(j['weather'] as Map<String, dynamic>);
      } catch (_) {}
    }
    return AirportDetail(
      success: (j['success'] ?? false) as bool,
      airportCode: (j['airport_code'] ?? '') as String,
      icaoCode: (j['icao_code'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      city: j['city'] as String?,
      country: (j['country'] ?? '') as String,
      latitude: _d(j['latitude']),
      longitude: _d(j['longitude']),
      weather: wx,
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String get displayName {
    if (city != null && city!.isNotEmpty) return '$name, $city';
    return name;
  }
}

class RouteWaypoint {
  final double latitude;
  final double longitude;

  const RouteWaypoint(this.latitude, this.longitude);

  factory RouteWaypoint.fromJson(Map<String, dynamic> j) => RouteWaypoint(
        _d(j['latitude']),
        _d(j['longitude']),
      );

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class FlightRoute {
  final AirportDetail departure;
  final AirportDetail arrival;
  final double? distanceKm;
  final double? distanceNm;
  final List<RouteWaypoint> waypoints;

  const FlightRoute({
    required this.departure,
    required this.arrival,
    this.distanceKm,
    this.distanceNm,
    required this.waypoints,
  });

  factory FlightRoute.fromJson(Map<String, dynamic> j) {
    final wps = (j['waypoints'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RouteWaypoint.fromJson)
        .toList();

    return FlightRoute(
      departure:
          AirportDetail.fromJson(j['departure'] as Map<String, dynamic>? ?? {}),
      arrival:
          AirportDetail.fromJson(j['arrival'] as Map<String, dynamic>? ?? {}),
      distanceKm: _d(j['distance_km']),
      distanceNm: _d(j['distance_nm']),
      waypoints: wps,
    );
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class FlightPopup {
  final String callsign;
  final String flightStatus;
  final String airlineIata;
  final String airlineIcao;
  final String aircraftIata;
  final String icao24;
  final String registration;

  // Live
  final double? latitude;
  final double? longitude;
  final double? altitudeM;
  final double? altitudeFt;
  final double? speedKmh;
  final double? headingDeg;
  final String? headingCompass;
  final String? phase;

  // Route
  final AirportDetail? departure;
  final AirportDetail? arrival;
  final double? distanceKm;
  final double? distanceNm;
  final double? remainingKm;
  final double? progressPercent;
  final int? etaMinutes;

  // Weather at destination
  final WeatherInfo? destWeather;

  const FlightPopup({
    required this.callsign,
    required this.flightStatus,
    required this.airlineIata,
    required this.airlineIcao,
    required this.aircraftIata,
    required this.icao24,
    required this.registration,
    this.latitude,
    this.longitude,
    this.altitudeM,
    this.altitudeFt,
    this.speedKmh,
    this.headingDeg,
    this.headingCompass,
    this.phase,
    this.departure,
    this.arrival,
    this.distanceKm,
    this.distanceNm,
    this.remainingKm,
    this.progressPercent,
    this.etaMinutes,
    this.destWeather,
  });

  factory FlightPopup.fromJson(Map<String, dynamic> j) {
    final identity = j['identity'] as Map<String, dynamic>? ?? {};
    final airline = identity['airline'] as Map<String, dynamic>? ?? {};
    final aircraft = identity['aircraft'] as Map<String, dynamic>? ?? {};
    final live = j['live'] as Map<String, dynamic>? ?? {};
    final altMap = live['altitude'] as Map<String, dynamic>? ?? {};
    final route = j['route'] as Map<String, dynamic>? ?? {};
    final destWxRaw = j['destination_weather'];

    WeatherInfo? destWx;
    if (destWxRaw != null) {
      try {
        destWx = WeatherInfo.fromJson(destWxRaw as Map<String, dynamic>);
      } catch (_) {}
    }

    AirportDetail? dep, arr;
    if (route['departure'] != null) {
      try {
        dep =
            AirportDetail.fromJson(route['departure'] as Map<String, dynamic>);
      } catch (_) {}
    }
    if (route['arrival'] != null) {
      try {
        arr = AirportDetail.fromJson(route['arrival'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return FlightPopup(
      callsign: (identity['callsign'] ?? '') as String,
      flightStatus: (identity['flight_status'] ?? '') as String,
      airlineIata: (airline['iataCode'] ?? '') as String,
      airlineIcao: (airline['icaoCode'] ?? '') as String,
      aircraftIata: (aircraft['iataCode'] ?? '') as String,
      icao24: (aircraft['icao24'] ?? '') as String,
      registration: (aircraft['regNumber'] ?? '') as String,
      latitude: _d(live['latitude']),
      longitude: _d(live['longitude']),
      altitudeM: _d(altMap['meters']),
      altitudeFt: _d(altMap['feet']),
      speedKmh: _d(live['speed_kmh']),
      headingDeg: _d(live['heading_degrees']),
      headingCompass: live['heading_compass'] as String?,
      phase: live['phase'] as String?,
      departure: dep,
      arrival: arr,
      distanceKm: _d(route['total_distance_km']),
      distanceNm: _d(route['total_distance_nm']),
      remainingKm: _d(route['remaining_km']),
      progressPercent: _d(route['progress_percent']),
      etaMinutes: _int(route['eta_minutes']),
      destWeather: destWx,
    );
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  String get etaFormatted {
    if (etaMinutes == null) return '—';
    final h = etaMinutes! ~/ 60;
    final m = etaMinutes! % 60;
    if (h == 0) return '${m}min';
    return '${h}h ${m}m';
  }

  String get progressFormatted {
    if (progressPercent == null) return '—';
    return '${progressPercent!.toStringAsFixed(0)}%';
  }
}

// ── Service ───────────────────────────────────────────────────────────────────
class FlightDetailService {
  static const _base =
      'https://python.aitechnotech.in/skypeanut-api/api/v1/map';

  final http.Client _client;

  // Simple in-memory cache
  final Map<String, _CachedPopup> _popupCache = {};
  final Map<String, _CachedRoute> _routeCache = {};

  static const _popupCacheDuration = Duration(seconds: 30);
  static const _routeCacheDuration = Duration(minutes: 5);

  FlightDetailService({http.Client? client})
      : _client = client ?? http.Client();

  // ── Popup (fast, cached 30s) ──────────────────────────────────────────────
  Future<FlightPopup?> getPopup(String callsign) async {
    final cached = _popupCache[callsign];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _popupCacheDuration) {
      return cached.data;
    }

    try {
      final uri = Uri.parse('$_base/flight-popup').replace(
        queryParameters: {'callsign': callsign},
      );

      log('[FlightDetailService] popup GET $uri');

      final res = await _client.get(uri, headers: {
        'accept': 'application/json'
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['status'] != '1') return null;
        final popup =
            FlightPopup.fromJson(body['data'] as Map<String, dynamic>);
        _popupCache[callsign] = _CachedPopup(popup);
        return popup;
      }
      return null;
    } catch (e) {
      log('[FlightDetailService] popup error: $e');
      return null;
    }
  }

  // ── Route + waypoints (cached 5min) ──────────────────────────────────────
  Future<FlightRoute?> getRoute(String callsign) async {
    final cached = _routeCache[callsign];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _routeCacheDuration) {
      return cached.data;
    }

    try {
      final uri = Uri.parse('$_base/flight-route').replace(
        queryParameters: {'callsign': callsign},
      );

      log('[FlightDetailService] route GET $uri');

      final res = await _client.get(uri, headers: {
        'accept': 'application/json'
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['status'] != '1') return null;
        final route =
            FlightRoute.fromJson(body['route'] as Map<String, dynamic>);
        _routeCache[callsign] = _CachedRoute(route);
        return route;
      }
      return null;
    } catch (e) {
      log('[FlightDetailService] route error: $e');
      return null;
    }
  }

  void clearCache() {
    _popupCache.clear();
    _routeCache.clear();
  }

  void dispose() => _client.close();
}

class _CachedPopup {
  final FlightPopup data;
  final DateTime fetchedAt;
  _CachedPopup(this.data) : fetchedAt = DateTime.now();
}

class _CachedRoute {
  final FlightRoute data;
  final DateTime fetchedAt;
  _CachedRoute(this.data) : fetchedAt = DateTime.now();
}
