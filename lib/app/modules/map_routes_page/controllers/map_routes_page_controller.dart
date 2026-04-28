import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/apis/api_models/get_routes_model.dart';

// ── Lightweight models for the extra API data ─────────────────────────────

class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeedKmh;
  final int visibilityKm;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeedKmh,
    required this.visibilityKm,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final w = json['data']?['weather'] ?? {};
    return WeatherData(
      location: json['data']?['location']?['city'] ?? '',
      temperature: (w['temperature'] ?? 0).toDouble(),
      feelsLike: (w['feels_like'] ?? 0).toDouble(),
      tempMin: (w['temp_min'] ?? 0).toDouble(),
      tempMax: (w['temp_max'] ?? 0).toDouble(),
      condition: w['condition'] ?? '',
      description: w['description'] ?? '',
      humidity: (w['humidity'] ?? 0).toInt(),
      windSpeedKmh: (w['wind_speed_kmh'] ?? 0).toDouble(),
      visibilityKm: (w['visibility_km'] ?? 0).toInt(),
    );
  }
}

class FlightSearchData {
  // Departure forecast
  final int punctualityPercentage;
  final int avgDelayMinutes;
  final int earlyPct;
  final int onTimePct;
  final int late30Pct;
  final int late60Pct;
  final int late90Pct;
  final int cancelledPct;

  // Arrival weather
  final WeatherData? arrivalWeather;

  FlightSearchData({
    required this.punctualityPercentage,
    required this.avgDelayMinutes,
    required this.earlyPct,
    required this.onTimePct,
    required this.late30Pct,
    required this.late60Pct,
    required this.late90Pct,
    required this.cancelledPct,
    this.arrivalWeather,
  });

  factory FlightSearchData.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? {};
    final df = d['departure_forecast'] ?? {};
    final dc = df['delay_categories'] ?? {};
    final aw = d['arrival_weather'];

    return FlightSearchData(
      punctualityPercentage: (df['punctuality_percentage'] ?? 0).toInt(),
      avgDelayMinutes: (df['avg_departure_delay_minutes'] ?? 0).toInt(),
      earlyPct: (dc['early'] ?? 0).toInt(),
      onTimePct: (dc['on_time'] ?? 0).toInt(),
      late30Pct: (dc['late_30_min'] ?? 0).toInt(),
      late60Pct: (dc['late_60_min'] ?? 0).toInt(),
      late90Pct: (dc['late_90_min'] ?? 0).toInt(),
      cancelledPct: (dc['cancelled'] ?? 0).toInt(),
      arrivalWeather: aw != null
          ? WeatherData(
        location: aw['location'] ?? '',
        temperature: (aw['temperature'] ?? 0).toDouble(),
        feelsLike: (aw['feels_like'] ?? 0).toDouble(),
        tempMin: (aw['temp_min'] ?? 0).toDouble(),
        tempMax: (aw['temp_max'] ?? 0).toDouble(),
        condition: aw['condition'] ?? '',
        description: aw['description'] ?? '',
        humidity: (aw['humidity'] ?? 0).toInt(),
        windSpeedKmh: (aw['wind_speed_kmh'] ?? 0).toDouble(),
        visibilityKm: (aw['visibility_km'] ?? 0).toInt(),
      )
          : null,
    );
  }
}

class MapRoutesPageController extends GetxController {
  Routes1? routesList;
  final data = Get.arguments;

  final count = 0.obs;
  final webCount = 0.obs;

  List<String> parts = [];
  String fromAirport = "";
  String toAirport = "";

  RxBool isLoading = true.obs;
  RxBool isLoadingExtra = true.obs;

  // ── Extra fetched data ────────────────────────────────────────────────────
  Rx<WeatherData?> destinationWeather = Rx<WeatherData?>(null);
  Rx<FlightSearchData?> flightSearchData = Rx<FlightSearchData?>(null);

  static const _baseUrl = "https://python.aitechnotech.in/skypeanut-api/api/v1";

  @override
  void onInit() {
    super.onInit();
    routesList = data;
    fromAirport = routesList?.fromAirport?.name?.trim() ?? "";
    toAirport = routesList?.toAirport?.name?.trim() ?? "";
    _fetchExtraData();
  }


  void increment() => count.value++;
  void webCountIncrement() => webCount.value++;

  // ── Fetch destination weather + flight-search forecast in parallel ────────
  Future<void> _fetchExtraData() async {
    isLoadingExtra.value = true;
    final toIcao = routesList?.toAirport?.icao ?? "";
    final fromIcao = routesList?.fromAirport?.icao ?? "";
    final today = _todayString();

    await Future.wait([
      _fetchWeather(toIcao),
      _fetchFlightSearch(fromIcao, toIcao, today),
    ]);

    isLoadingExtra.value = false;
    increment();
  }

  Future<void> _fetchWeather(String icao) async {
    if (icao.isEmpty) return;
    try {
      final uri = Uri.parse("$_baseUrl/weather-forecast?location=$icao");
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == '1') {
          destinationWeather.value = WeatherData.fromJson(json);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchFlightSearch(
      String from, String to, String date) async {
    if (from.isEmpty || to.isEmpty) return;
    try {
      final uri = Uri.parse(
          "$_baseUrl/flight-search?from_location=$from&to_location=$to&departure_date=$date");
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == '1') {
          flightSearchData.value = FlightSearchData.fromJson(json);
        }
      }
    } catch (_) {}
  }

  String _todayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Weather icon based on condition string
  String weatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sunny')) return '☀️';
    if (c.contains('cloud')) return '⛅';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) return '🌫️';
    if (c.contains('wind')) return '💨';
    return '🌤️';
  }
}