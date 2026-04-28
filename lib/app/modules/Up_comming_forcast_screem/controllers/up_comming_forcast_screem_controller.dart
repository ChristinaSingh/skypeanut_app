import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_upcomming_weather_hourly.dart';
import '../../../data/apis/api_models/get_weekly_upcomming_forecast_model.dart';
import '../views/up_comming_forcast_screem_view.dart';

// Search Mode Enum
enum SearchMode { airport, location }

// Airport Model
class AirportResult {
  final String airportCode;
  final String icaoCode;
  final String name;
  final String city;
  final String country;
  final String countryCode;
  final String state;
  final double latitude;
  final double longitude;
  final String type;
  final int relevanceScore;
  final String source;

  AirportResult({
    required this.airportCode,
    required this.icaoCode,
    required this.name,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.relevanceScore,
    required this.source,
  });

  factory AirportResult.fromJson(Map<String, dynamic> json) {
    return AirportResult(
      airportCode: json['airport_code']?.toString() ?? '',
      icaoCode: json['icao_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      type: json['type']?.toString() ?? '',
      relevanceScore: json['relevance_score'] ?? 0,
      source: json['source']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String get displayName => "$name ($icaoCode)";

  String get fullAddress => "$name, $city, $country";
}

// Location Result Model (for Google Places)
class LocationResult {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  LocationResult({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return LocationResult(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mainText: structuredFormatting['main_text']?.toString() ?? '',
      secondaryText: structuredFormatting['secondary_text']?.toString() ?? '',
    );
  }
}

class UpCommingForcastScreemController extends GetxController {
  // ─── Sort / Label ─────────────────────────────────────────────────────────
  var sortType = SortType.hourly.obs;
  var selectedLabel = "hourly".obs;

  // ─── Location ─────────────────────────────────────────────────────────────
  var address = "".obs;
  var latString = "".obs;
  var longString = "".obs;

  // ─── State ────────────────────────────────────────────────────────────────
  final RxBool inAsyncCall = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isDataLoaded = false.obs;

  // ─── Search State ─────────────────────────────────────────────────────────
  final RxBool isSearchLoading = false.obs;
  final Rx<SearchMode> searchMode = SearchMode.airport.obs;

  // ─── Data lists ───────────────────────────────────────────────────────────
  RxList<HourlyForecast> forecastListNeww = <HourlyForecast>[].obs;
  RxList<WeeklyForecast> forecastListWeekly = <WeeklyForecast>[].obs;

  // ─── Search Results ───────────────────────────────────────────────────────
  RxList<AirportResult> airportSuggestions = <AirportResult>[].obs;
  RxList<LocationResult> locationSuggestions = <LocationResult>[].obs;

  // ─── Navigation params ────────────────────────────────────────────────────
  Map<String, String?> parameters = Get.parameters;

  // ─── Focus / Search ───────────────────────────────────────────────────────
  FocusNode focusNodeLocation = FocusNode();
  final TextEditingController searchController = TextEditingController();
  var isSearchVisible = false.obs;

  // ─── API Keys & URLs ──────────────────────────────────────────────────────
  final String _placesApiKey = "AIzaSyDT62NXFvZu9qKdh96SkstdkV43cXadFyc";
  final String _airportSearchBaseUrl =
      "https://python.aitechnotech.in/skypeanut-api/api/v1/airport-search";

  // ─── Units ────────────────────────────────────────────────────────────────
  var windUnit = "Knots".obs;
  var visibilityUnit = "KM".obs;
  var temperatureUnit = "°C".obs;
  var dewPointUnit = "°C".obs;
  var pressureUnit = "hPA".obs;

  // ─── UI rebuild counter ───────────────────────────────────────────────────
  final count = 0.obs;

  void increment() => count.value++;

  // ─── Sort items ───────────────────────────────────────────────────────────
  final items = [
    {"value": SortType.hourly, "label": "hourly"},
    {"value": SortType.weekly, "label": "weekly"},
    {"value": SortType.monthly, "label": "monthly"},
  ];

  // ═════════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ═════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();

    latString.value = parameters[ApiKeyConstants.lat] ?? '';
    longString.value = parameters[ApiKeyConstants.lon] ?? '';

    final cityParam = parameters['city'];
    if (cityParam != null && cityParam.isNotEmpty) {
      address.value = Uri.decodeComponent(cityParam);
    }

    // ✅ Validate lat/lon before calling API
    if (_isValidCoordinate(latString.value) &&
        _isValidCoordinate(longString.value)) {
      _loadUnitsAndFetch(
        selectedLabel.value,
        latString.value,
        longString.value,
      );

      if (address.value.isEmpty) {
        getFullAddress(
          double.tryParse(latString.value) ?? 0,
          double.tryParse(longString.value) ?? 0,
        );
      }
    } else {
      // ✅ Show error instead of sending empty coords to API
      _setError("Location not available. Please search for a location.");
      log("ERROR: Invalid coordinates - "
          "lat='${latString.value}', lon='${longString.value}'");
      log("Available parameters: $parameters");
    }

    searchController.addListener(_onSearchTextChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchTextChanged);
    focusNodeLocation.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Coordinate Validator
  // ═════════════════════════════════════════════════════════════════════════

  /// ✅ Returns true only if the string is a valid, parseable number
  bool _isValidCoordinate(String value) {
    if (value.trim().isEmpty) return false;
    final parsed = double.tryParse(value.trim());
    return parsed != null;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Search Text Change Handler (Debounced)
  // ═════════════════════════════════════════════════════════════════════════

  DateTime? _lastSearchTime;

  void _onSearchTextChanged() {
    final text = searchController.text.trim();

    _lastSearchTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (DateTime.now().difference(_lastSearchTime!).inMilliseconds >= 300) {
        _performSearch(text);
      }
    });

    increment();
  }

  void _performSearch(String text) {
    if (text.isEmpty) {
      airportSuggestions.clear();
      locationSuggestions.clear();
      return;
    }

    if (searchMode.value == SearchMode.airport) {
      searchAirports(text);
    } else {
      searchLocations(text);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Search Mode Toggle
  // ═════════════════════════════════════════════════════════════════════════

  void toggleSearchMode(SearchMode mode) {
    searchMode.value = mode;
    airportSuggestions.clear();
    locationSuggestions.clear();

    final text = searchController.text.trim();
    if (text.isNotEmpty) {
      _performSearch(text);
    }

    increment();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Airport Search API
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> searchAirports(String keyword) async {
    if (keyword.trim().isEmpty) {
      airportSuggestions.clear();
      return;
    }

    isSearchLoading.value = true;

    try {
      final url = Uri.parse(
        "$_airportSearchBaseUrl?keyword=${Uri.encodeComponent(keyword)}",
      );
      log("Airport Search URL: $url");

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == '1' && data['data'] != null) {
          final List<dynamic> results = data['data'] as List<dynamic>;
          airportSuggestions.assignAll(
            results
                .map((e) => AirportResult.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
          log("Found ${airportSuggestions.length} airports");
        } else {
          airportSuggestions.clear();
          log("No airports found: ${data['message']}");
        }
      } else {
        airportSuggestions.clear();
        log("Airport search failed: ${response.statusCode}");
      }
    } catch (e) {
      airportSuggestions.clear();
      log("Airport search error: $e");
    } finally {
      isSearchLoading.value = false;
      increment();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Google Places Search
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> searchLocations(String input) async {
    if (input.trim().isEmpty) {
      locationSuggestions.clear();
      return;
    }

    isSearchLoading.value = true;

    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
            "?input=${Uri.encodeComponent(input.trim())}"
            "&key=$_placesApiKey",
      );

      log("Location Search URL: $url");

      final response =
      await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK' && data['predictions'] != null) {
          final predictions = data['predictions'] as List<dynamic>;
          locationSuggestions.assignAll(
            predictions
                .map((e) =>
                LocationResult.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
          log("Found ${locationSuggestions.length} results");
        } else {
          locationSuggestions.clear();
          log("No results: ${data['status']}");
        }
      } else {
        locationSuggestions.clear();
        log("Search failed: ${response.statusCode}");
      }
    } catch (e) {
      locationSuggestions.clear();
      log("Search error: $e");
    } finally {
      isSearchLoading.value = false;
      increment();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Get Place Details
  // ═════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=$placeId"
            "&fields=geometry,formatted_address,name,address_components"
            "&key=$_placesApiKey",
      );

      log("Place Details URL: $url");

      final response =
      await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          return data['result'] as Map<String, dynamic>?;
        }
        log("Place details status: ${data['status']}");
      }
    } catch (e) {
      log("Place details error: $e");
    }
    return null;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Select Airport
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> selectAirport(AirportResult airport) async {
    final lat = airport.latitude.toString();
    final lng = airport.longitude.toString();
    final selectedAddress = airport.fullAddress;

    log("Selected Airport: ${airport.name} | Lat: $lat | Lng: $lng");

    // ✅ Validate airport coords before proceeding
    if (!_isValidCoordinate(lat) || !_isValidCoordinate(lng)) {
      _showError("Invalid airport coordinates. Please try another airport.");
      return;
    }

    latString.value = lat;
    longString.value = lng;
    address.value = selectedAddress;

    closeSearch();
    await _fetchWeatherForLocation(lat, lng);
    increment();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Select Location (Google Places)
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> selectLocation(LocationResult location) async {
    isSearchLoading.value = true;

    try {
      final details = await getPlaceDetails(location.placeId);

      if (details == null) {
        _showError("Failed to get location details. Please try again.");
        return;
      }

      final geometry = details['geometry'] as Map<String, dynamic>?;
      final loc = geometry?['location'] as Map<String, dynamic>?;

      if (loc == null) {
        _showError("Location coordinates not available.");
        return;
      }

      final lat = loc['lat']?.toString() ?? '';
      final lng = loc['lng']?.toString() ?? '';
      final formattedAddress =
          details['formatted_address']?.toString() ?? location.description;

      log("Selected: ${location.description} | Lat: $lat | Lng: $lng");

      // ✅ Validate coordinates from Places API
      if (!_isValidCoordinate(lat) || !_isValidCoordinate(lng)) {
        _showError("Invalid coordinates received. Please try again.");
        return;
      }

      latString.value = lat;
      longString.value = lng;
      address.value = formattedAddress;

      closeSearch();
      await _fetchWeatherForLocation(lat, lng);
    } catch (e) {
      log("Select location error: $e");
      _showError("Failed to select location. Please try again.");
    } finally {
      isSearchLoading.value = false;
      increment();
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Fetch Weather for Location
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _fetchWeatherForLocation(String lat, String lng) async {
    // ✅ Final safety guard before any API call
    if (!_isValidCoordinate(lat) || !_isValidCoordinate(lng)) {
      _setError("Invalid location coordinates. Please search for a location.");
      return;
    }

    await _loadUnits();

    if (selectedLabel.value == "hourly") {
      await _fetchHourly(lat, lng);
    } else {
      await _fetchWeeklyOrMonthly(selectedLabel.value, lat, lng);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Search UI Controls
  // ═════════════════════════════════════════════════════════════════════════

  void openSearch() {
    isSearchVisible.value = true;
    searchController.clear();
    airportSuggestions.clear();
    locationSuggestions.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      focusNodeLocation.requestFocus();
    });

    increment();
  }

  void closeSearch() {
    isSearchVisible.value = false;
    searchController.clear();
    airportSuggestions.clear();
    locationSuggestions.clear();
    focusNodeLocation.unfocus();
    increment();
  }

  void closeSearchBack() {
    isSearchVisible.value = false;
    searchController.clear();
    airportSuggestions.clear();
    locationSuggestions.clear();
    focusNodeLocation.unfocus();
    increment();
    Get.back();
  }

  void toggleSearch() {
    if (isSearchVisible.value) {
      closeSearch();
    } else {
      openSearch();
    }
  }

  void clearSearch() {
    searchController.clear();
    airportSuggestions.clear();
    locationSuggestions.clear();
    increment();
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Units
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _loadUnits() async {
    final prefs = await SharedPreferences.getInstance();
    windUnit.value = prefs.getString("windUnit") ?? "Knots";
    temperatureUnit.value = prefs.getString("temperatureUnit") ?? "°C";
    pressureUnit.value = prefs.getString("pressureUnit") ?? "hPA";
    visibilityUnit.value = prefs.getString("visibilityUnit") ?? "KM";
    dewPointUnit.value = prefs.getString("dewPointUnit") ?? "°C";
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Address
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> getFullAddress(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if ((place.name ?? '').isNotEmpty && place.name != place.street)
            place.name!,
          if ((place.locality ?? '').isNotEmpty) place.locality!,
          if ((place.administrativeArea ?? '').isNotEmpty)
            place.administrativeArea!,
          if ((place.country ?? '').isNotEmpty) place.country!,
        ];
        address.value = parts.join(', ');
      }
    } catch (e) {
      log("Geocoding error: $e");
      if (address.value.isEmpty) {
        address.value =
        'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lon.toStringAsFixed(4)}';
      }
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Sort / Type Change
  // ═════════════════════════════════════════════════════════════════════════

  void changeSort(SortType value) {
    sortType.value = value;
    selectedLabel.value =
        items.firstWhere((e) => e["value"] == value)["label"].toString();

    // ✅ Only fetch if we have valid coordinates
    if (_isValidCoordinate(latString.value) &&
        _isValidCoordinate(longString.value)) {
      _loadUnitsAndFetch(
        selectedLabel.value,
        latString.value,
        longString.value,
      );
    } else {
      _setError("No location selected. Please search for a location first.");
    }
  }

  Future<void> _loadUnitsAndFetch(
      String label,
      String lat,
      String lon,
      ) async {
    await _loadUnits();
    if (label == "hourly") {
      await _fetchHourly(lat, lon);
    } else {
      await _fetchWeeklyOrMonthly(label, lat, lon);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // API – Hourly
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _fetchHourly(String lat, String lon) async {
    // ✅ Guard: never send empty/invalid coords to API
    if (!_isValidCoordinate(lat) || !_isValidCoordinate(lon)) {
      _setError("Invalid location coordinates. Please search for a location.");
      log("ERROR: _fetchHourly - invalid coords lat='$lat' lon='$lon'");
      return;
    }

    _clearError();
    inAsyncCall.value = true;

    try {
      final body = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: lon,
        ApiKeyConstants.type: "hourly",
      };

      log("Fetching HOURLY forecast → lat=$lat, lon=$lon");

      final result =
      await ApiMethods.upcomingForecastHourlyApi(bodyParams: body);

      if (result == null ||
          result.forecast == null ||
          result.forecast!.isEmpty) {
        forecastListNeww.clear();
        _setError("No hourly data available for this location.");
        return;
      }

      forecastListNeww.assignAll(
        result.forecast!.map((f) => _applyHourlyUnits(f)).toList(),
      );
      isDataLoaded.value = true;
    } catch (e) {
      forecastListNeww.clear();
      _setError("Failed to load hourly forecast. Please check your connection.");
      log("Hourly fetch error: $e");
    } finally {
      inAsyncCall.value = false;
    }
  }

  HourlyForecast _applyHourlyUnits(HourlyForecast f) {
    // Temperature
    if (temperatureUnit.value == "°F") {
      f.temperature = f.temperatureF ?? f.temperature;
      f.feelsLike = f.feelsLikeF ?? f.feelsLike;
    } else {
      f.temperature = f.temperatureC ?? f.temperature;
    }

    // Wind
    final double windKnots = _toDouble(f.windSpeedKnots);
    final double windMs = _toDouble(f.windSpeedMs);
    final String windKmh = f.windSpeed?.toString() ?? '0';

    if (windUnit.value == "KMH") {
      f.windSpeed = windKmh;
    } else if (windUnit.value == "m/s") {
      f.windSpeed = windMs.toStringAsFixed(1);
    } else {
      // Default: Knots
      f.windSpeed = windKnots.toStringAsFixed(1);
    }

    // Pressure
    if (pressureUnit.value == "inHg") {
      f.pressure = f.pressureInhg;
    } else {
      f.pressure = f.pressureHpa;
    }

    return f;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // API – Weekly / Monthly
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> _fetchWeeklyOrMonthly(
      String label,
      String lat,
      String lon,
      ) async {
    // ✅ Guard: never send empty/invalid coords to API
    if (!_isValidCoordinate(lat) || !_isValidCoordinate(lon)) {
      _setError("Invalid location coordinates. Please search for a location.");
      log("ERROR: _fetchWeeklyOrMonthly - invalid coords lat='$lat' lon='$lon'");
      return;
    }

    _clearError();
    inAsyncCall.value = true;

    try {
      final body = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: lon,
        ApiKeyConstants.type: label,
      };

      log("Fetching ${label.toUpperCase()} forecast → lat=$lat, lon=$lon");

      final result =
      await ApiMethods.upcomingForecastWeeklyApi(bodyParams: body);

      if (result == null ||
          result.forecast == null ||
          result.forecast!.isEmpty) {
        forecastListWeekly.clear();
        _setError("No $label data available for this location.");
        return;
      }

      forecastListWeekly.assignAll(
        result.forecast!.map((f) => _applyWeeklyUnits(f)).toList(),
      );
      isDataLoaded.value = true;
    } catch (e) {
      forecastListWeekly.clear();
      _setError("Failed to load $label forecast. Please check your connection.");
      log("$label fetch error: $e");
    } finally {
      inAsyncCall.value = false;
    }
  }

  // ✅ FIXED: Added missing wind/pressure logic AND the required `return f`
  WeeklyForecast _applyWeeklyUnits(WeeklyForecast f) {
    // Temperature
    if (temperatureUnit.value == "°F") {
      if (f.temperatureF != null) {
        f.temperature = f.temperatureF;
      }
      if (f.feelsLike?.day != null) {
        f.feelsLike = FeelsLike(
          day: _celsiusToFahrenheit(_toDouble(f.feelsLike!.day)),
        );
      }
    }

    // ✅ Wind (was completely missing before)
    final double windKnots = _toDouble(f.windSpeedKnots);
    final double windMs = _toDouble(f.windSpeedMs);
    final String windKmh = f.windSpeed?.toString() ?? '0';

    if (windUnit.value == "KMH") {
      f.windSpeed = windKmh;
    } else if (windUnit.value == "m/s") {
      f.windSpeed = windMs.toStringAsFixed(1);
    } else {
      // Default: Knots
      f.windSpeed = windKnots.toStringAsFixed(1);
    }

    // ✅ Pressure (was completely missing before)
    if (pressureUnit.value == "inHg") {
      f.pressure = f.pressureInhg;
    } else {
      f.pressure = f.pressureHpa;
    }

    // ✅ CRITICAL FIX: return statement was missing entirely
    return f;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════════════════════════════════

  void _setError(String msg) {
    errorMessage.value = msg;
    hasError.value = true;
  }

  void _clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _celsiusToFahrenheit(double c) => (c * 9 / 5) + 32;

  String fmt(dynamic value) {
    if (value == null) return '--';
    final d = double.tryParse(value.toString());
    if (d == null) return value.toString();
    return d.toStringAsFixed(1);
  }

  String extractCondition(String? text) {
    if (text == null || text.isEmpty) return 'Unknown';
    try {
      final fixed = utf8.decode(text.codeUnits, allowMalformed: true);
      final noEmoji = fixed.replaceAll(
        RegExp(
          r'[\u{2190}-\u{21FF}\u{2300}-\u{23FF}\u{2460}-\u{24FF}'
          r'\u{2600}-\u{27BF}\u{1F300}-\u{1FAFF}\u{FE0F}]',
          unicode: true,
        ),
        '',
      );
      final lettersOnly =
      noEmoji.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s-]'), '');
      return lettersOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      return text.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s-]'), '').trim();
    }
  }

  String extractEmoji(String? text) {
    if (text == null || text.isEmpty) return '🌡️';
    try {
      final fixed = utf8.decode(text.runes.toList());
      return fixed.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '').trim();
    } catch (_) {
      return '';
    }
  }

  String fixUtf8(String text) {
    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }
}