import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_weather_model.dart';

import '../../../common/colors.dart';
import '../../../routes/app_pages.dart';
import '../../../common/weather_convter.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_airport_near_by.dart';
import '../../../data/apis/api_models/get_alerts_model.dart';
import '../../../data/apis/api_models/get_notam_by_airport_code.dart';
import '../../../data/apis/api_models/get_profile_model.dart';
import '../../../data/apis/api_models/get_weekly_upcomming_forecast_model.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Weather_settings_screen/controllers/weather_settings_screen_controller.dart';
import '../../../data/services/connectivity_controller.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class HomeController extends GetxController {
  var temperature = "2.4".obs;
  var dewDew = "2.4".obs;
  RxString windSpeed = "4.63".obs;
  RxString visibility = "56".obs;
  RxString pressure = "1013".obs;
  RxString forecast = "null".obs;
  RxString lat = "".obs;
  RxString long = "".obs;
  RxString due = "56".obs;

  RxString windDirection = "".obs;
  RxInt aqiUs = 0.obs;
  RxString aqiCategory = "".obs;
  RxDouble aqiPm25 = 0.0.obs;

  RxString date = 'June 07'.obs;
  RxString rawDate = '6/7/2023 4:55 PM'.obs;
  RxString city = 'Paris'.obs;
  RxString name = 'Johan Wick'.obs;
  final RxBool inAsyncCall = true.obs;
  final RxBool inAsyncCallForForecast = true.obs;
  final RxBool inAsyncCallForAlert = true.obs;
  final RxBool isOffline = false.obs;

  /// ✅ NEW: Track whether it's day or night based on API timestamp
  RxBool isNightTime = false.obs;

  // Cache Keys
  static const String keyProfile = "cache_profile";
  static const String keyWeather = "cache_weather";
  static const String keyForecast = "cache_forecast";
  static const String keyNearbyAirports = "cache_nearby_airports";
  static const String keyNotams = "cache_notams";
  static const String keyAlerts = "cache_alerts";

  var windUnit = "Knots".obs;
  var visibilityUnit = "KM".obs;
  var temperatureUnit = "°C".obs;
  var dewPointUnit = "°C".obs;
  var pressureUnit = "hPA".obs;

  WeatherSettingsScreenController settings =
  Get.find<WeatherSettingsScreenController>();

  List<Alerts> alertsList = [];
  Weather? weather;

  final RxInt count = 0.obs;

  RxInt currentPage = 0.obs;

  String userId = '';
  GetProfileModel? getProfileModelData;
  List<WeeklyForecast> forecastList = [];
  List<AlertsAirport> alertsListNew = [];
  List<Airports>? nearByAirportsList;

  List<Data>? getNotamData;

  /// ✅ NEW: Store the API timestamp as DateTime (UTC)
  DateTime? _apiTimestampUtc;

  @override
  Future<void> onInit() async {
    super.onInit();

    tz_data.initializeTimeZones();

    // Global connectivity listener
    final connectivity = Get.find<ConnectivityController>();
    ever(connectivity.connectivityResults, (results) {
      bool offline =
          results.contains(ConnectivityResult.none) && results.length == 1;
      if (!offline && isOffline.value) {
        refetchData();
      }
      isOffline.value = offline;
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';

    _loadInitialCache();

    getProfileApi();
    setCurrentDate();
    getFullDate(); // fallback: use device time initially
    getCurrentLocation();
  }

  Future<void> refetchData() async {
    await getProfileApi();
    await getCurrentLocation();
  }

  Future<void> _loadInitialCache() async {
    await _loadProfileFromCache();
    await _loadWeatherFromCache();
    await _loadForecastFromCache();
    await _loadNearbyAirportsFromCache();
    await _loadNotamsFromCache();
    await _loadAlertsFromCache();
    increment();
  }

  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> _loadFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(key);
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }
    return null;
  }

  Future<void> _loadProfileFromCache() async {
    var cached = await _loadFromCache(keyProfile);
    if (cached != null) {
      getProfileModelData = GetProfileModel.fromJson(cached);
      userName.value = getProfileModelData?.fullName ?? '';
    }
  }

  Future<void> _loadWeatherFromCache() async {
    // ✅ Load cached lat/lon first
    final sp = await SharedPreferences.getInstance();
    final cachedLat = sp.getString("cached_lat") ?? "";
    final cachedLon = sp.getString("cached_lon") ?? "";

    var cached = await _loadFromCache(keyWeather);
    if (cached != null) {
      GetWeatherAppModel model = GetWeatherAppModel.fromJson(cached);
      _processWeatherData(
        model,
        latParam: cachedLat,  // ✅ use cached lat/lon
        lonParam: cachedLon,  // ✅ use cached lat/lon
      );
    }
  }

  Future<void> _loadForecastFromCache() async {
    var cached = await _loadFromCache(keyForecast);
    if (cached != null) {
      UpcomingForecastWeeklyModel model =
      UpcomingForecastWeeklyModel.fromJson(cached);
      _processForecastData(model);
    }
  }

  Future<void> _loadNearbyAirportsFromCache() async {
    var cached = await _loadFromCache(keyNearbyAirports);
    if (cached != null) {
      NearbyAirportModel model = NearbyAirportModel.fromJson(cached);
      _processNearbyAirportsData(model);
    }
  }

  Future<void> _loadNotamsFromCache() async {
    var cached = await _loadFromCache(keyNotams);
    if (cached != null) {
      NotamModel model = NotamModel.fromJson(cached);
      getNotamData = model.data;
    }
  }

  Future<void> _loadAlertsFromCache() async {
    var cached = await _loadFromCache(keyAlerts);
    if (cached != null) {
      AlertsModel model = AlertsModel.fromJson(cached);
      _processAlertsData(model);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ✅ NEW HELPER: Convert API timestamp → formatted date string
  //               AND determine day/night for background image
  // ─────────────────────────────────────────────────────────────────

  /// Converts a Unix timestamp (seconds) from the API to a human-readable
  /// date-time string using the device's local timezone, then updates
  /// [rawDate] and [isNightTime].
  ///
  /// Night   = 18:00 – 05:59  (local time)
  /// Day     = 06:00 – 17:59  (local time)
  /// ✅ FIXED: Convert timestamp using the LOCATION's timezone
  /// determined by calling a timezone API with lat/lon
  Future<void> _updateDateTimeFromTimestamp(
      dynamic rawTimestamp,
      String lat,
      String lon,
      ) async {
    if (rawTimestamp == null) return;

    // ── Parse timestamp ───────────────────────────────────────────────
    int? tsSeconds;
    if (rawTimestamp is int) {
      tsSeconds = rawTimestamp;
    } else if (rawTimestamp is String) {
      tsSeconds = int.tryParse(rawTimestamp);
    } else if (rawTimestamp is double) {
      tsSeconds = rawTimestamp.toInt();
    }
    if (tsSeconds == null) return;

    // ── UTC DateTime ──────────────────────────────────────────────────
    _apiTimestampUtc =
        DateTime.fromMillisecondsSinceEpoch(tsSeconds * 1000, isUtc: true);

    // ── Get timezone name for the given lat/lon ───────────────────────
    String timezoneName = await _getTimezoneForLocation(lat, lon);
    print("Timezone for ($lat, $lon): $timezoneName");

    // ── Convert UTC → location's local time ──────────────────────────
    final location = tz.getLocation(timezoneName);
    final locationDt = tz.TZDateTime.from(_apiTimestampUtc!, location);

    // ── Format for UI ─────────────────────────────────────────────────
    rawDate.value = DateFormat('M/d/yyyy h:mm a').format(locationDt);
    date.value = DateFormat('MMMM dd').format(locationDt);

    // ── Day / Night ───────────────────────────────────────────────────
    final hour = locationDt.hour;
    isNightTime.value = (hour < 6 || hour >= 18);

    print(
      "UTC:      $_apiTimestampUtc\n"
          "Location: $locationDt  (${timezoneName})\n"
          "Hour:     $hour  →  isNight: ${isNightTime.value}",
    );
  }

  /// Returns IANA timezone name for lat/lon
  /// Uses free timezone API (no key needed)
  Future<String> _getTimezoneForLocation(String lat, String lon) async {
    // ── Try cache first ───────────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "tz_${lat}_${lon}";
    final cached = prefs.getString(cacheKey);
    if (cached != null) return cached;

    // ── Fetch from API ────────────────────────────────────────────────
    try {
      final url =
          'https://timeapi.io/api/timezone/coordinate?latitude=$lat&longitude=$lon';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tzName = data['timeZone'] as String? ?? 'UTC';

        // Cache it — timezone for a location never changes
        await prefs.setString(cacheKey, tzName);
        return tzName;
      }
    } catch (e) {
      print("Timezone API error: $e");
    }

    // ── Fallback: rough offset from longitude ─────────────────────────
    return _guessTzFromLon(double.tryParse(lon) ?? 0);
  }

  /// Very rough fallback: guess UTC offset from longitude
  /// (±15° per hour, 0° = UTC)
  String _guessTzFromLon(double lon) {
    // Each 15 degrees = 1 hour offset
    int offsetHours = (lon / 15).round().clamp(-12, 14);
    if (offsetHours == 0) return 'UTC';
    // IANA names like "Etc/GMT+5" — note sign is INVERTED in Etc/GMT
    // Etc/GMT+N means UTC-N  ← confusing but correct
    return offsetHours > 0
        ? 'Etc/GMT-$offsetHours'   // e.g. UTC+5 → Etc/GMT-5
        : 'Etc/GMT+${offsetHours.abs()}'; // e.g. UTC-8 → Etc/GMT+8
  }

  // ─────────────────────────────────────────────────────────────────

  Future<void> getNotamBYAirportData(String airportCode) async {
    try {
      inAsyncCall.value = true;
      NotamModel? notamModel =
      await ApiMethods.getNotamBYAirport(bodyParams: airportCode);
      if (notamModel != null && notamModel.success == true) {
        getNotamData = notamModel.data;
        _saveToCache(keyNotams, notamModel.toJson());
        isOffline.value = false;
        increment();
      } else {
        throw Exception("Failed to fetch NOTAMs");
      }
    } catch (e) {
      print("NOTAM Data Error: $e");
      isOffline.value = true;
      await _loadNotamsFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

  Future<void> getNearbyByAirportApiCall(String lat, String long) async {
    try {
      inAsyncCall.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };
      NearbyAirportModel? nearbyAirportModel =
      await ApiMethods.getNearbyByAirport(bodyParams: bodyParameter);

      if (nearbyAirportModel != null && nearbyAirportModel.status != "0") {
        _processNearbyAirportsData(nearbyAirportModel);
        _saveToCache(keyNearbyAirports, nearbyAirportModel.toJson());
        isOffline.value = false;
      } else {
        throw Exception("Failed to fetch nearby airports");
      }
    } catch (e) {
      print("Nearby Airport Data Error: $e");
      isOffline.value = true;
      await _loadNearbyAirportsFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

  void _processNearbyAirportsData(NearbyAirportModel nearbyAirportModel) {
    nearByAirportsList = nearbyAirportModel.airports ?? [];
    if (nearByAirportsList!.isNotEmpty) {
      getUpcomingAlert(nearByAirportsList?.first.icaoCode ?? "");
      getNotamBYAirportData(
          "${nearByAirportsList?.first.icaoCode ?? ''},${nearByAirportsList?[1].icaoCode ?? ''},${nearByAirportsList?[2].icaoCode ?? ''}");
    }
    increment();
  }

  Future<void> getProfileApi() async {
    try {
      inAsyncCall.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.userId: userId,
      };
      GetProfileModel? getProfileModel =
      await ApiMethods.getProfile(bodyParams: bodyParameter);
      if (getProfileModel != null && getProfileModel.status == '1') {
        getProfileModelData = getProfileModel;
        userName.value = getProfileModel.fullName ?? '';
        _saveToCache(keyProfile, getProfileModel.toJson());
        isOffline.value = false;
      }
    } catch (e) {
      print("Get Profile Data Error: $e");
      isOffline.value = true;
      await _loadProfileFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

  void setCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd').format(now);
    date.value = formattedDate;
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('M/d/yyyy h:mm a').format(dateTime);
  }

  /// Fallback: use device clock when no API timestamp is available yet
  void getFullDate() {
    DateTime now = DateTime.now();
    rawDate.value = formatDateTime(now);

    // Also set initial day/night from device clock
    final hour = now.hour;
    isNightTime.value = (hour < 6 || hour >= 18);

    print(rawDate.value);
  }

  @override
  void onClose() {
    stopWeatherPolling();
    timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  Future<void> getUpcomingForecast(String lat, String long) async {
    try {
      inAsyncCallForForecast.value = true;

      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
        ApiKeyConstants.type: "weekly",
      };

      UpcomingForecastWeeklyModel? upcomingForecastWeeklyModel =
      await ApiMethods.upcomingForecastApi(bodyParams: bodyParameter);

      if (upcomingForecastWeeklyModel != null &&
          upcomingForecastWeeklyModel.forecast != null) {
        _processForecastData(upcomingForecastWeeklyModel);
        _saveToCache(keyForecast, upcomingForecastWeeklyModel.toJson());
        isOffline.value = false;
      } else {
        throw Exception("Failed to fetch forecast");
      }
    } catch (e) {
      print("Forecast Data Error: $e");
      isOffline.value = true;
      await _loadForecastFromCache();
    } finally {
      inAsyncCallForForecast.value = false;
    }
  }

  void _processForecastData(UpcomingForecastWeeklyModel model) {
    var updatedList = model.forecast!.map((f) {
      double tempC = f.temperature?.day ?? 0;
      double tempF = f.temperatureF?.day ?? 0;

      if (temperatureUnit.value == "°F") {
        f.temperature?.day = tempF;
      } else {
        f.temperature?.day = tempC;
      }

      if (temperatureUnit.value == "°F") {
        f.feelsLike?.day = tempF;
      } else {
        f.feelsLike?.day = tempC;
      }

      double windKnots = f.windSpeedKnots ?? 0.0;
      double windMs = f.windSpeedMs ?? 0.0;
      String windKmh = f.windSpeed ?? "0.0";

      if (windUnit.value == "KMH") {
        f.windSpeed = windKmh;
      } else if (windUnit.value == "m/s") {
        f.windSpeed = windMs.toStringAsFixed(1);
      } else {
        f.windSpeed = windKnots.toStringAsFixed(1);
      }

      if (pressureUnit.value == "inHg") {
        f.pressure = f.pressureInhg;
      } else {
        f.pressure = f.pressureHpa;
      }

      return f;
    }).toList();

    forecastList.assignAll(updatedList);
    increment();
  }

  late PageController pageController;
  Timer? timer;

  void startAutoScroll() {
    timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (alertsListNew.isNotEmpty) {
        if (currentPage.value < alertsListNew.length - 1) {
          currentPage.value++;
        } else {
          currentPage.value = 0;
        }
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> getUpcomingAlert(String icaoCode) async {
    try {
      inAsyncCallForAlert.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.airportCode2: icaoCode,
      };

      AlertsModel? alertsModel =
      await ApiMethods.upcomingAlertsApi(bodyParams: bodyParameter);

      if (alertsModel != null && alertsModel.status == '1') {
        _processAlertsData(alertsModel);
        _saveToCache(keyAlerts, alertsModel.toJson());
        isOffline.value = false;
      } else {
        throw Exception("No alerts found or error occurred");
      }
    } catch (e) {
      print("Alert Data Error: $e");
      isOffline.value = true;
      await _loadAlertsFromCache();
    } finally {
      inAsyncCallForAlert.value = false;
    }
  }

  void _processAlertsData(AlertsModel model) {
    alertsListNew = model.alerts ?? [];
    if (alertsListNew.isNotEmpty) {
      pageController = PageController(viewportFraction: 0.9);
      startAutoScroll();
      increment();
    }
  }

  String fixEncoding(String text) {
    try {
      return utf8.decode(text.runes.toList());
    } catch (_) {
      return text;
    }
  }

  String extractEmoji(String text) {
    try {
      String fixed = utf8.decode(text.runes.toList());
      String emojiOnly = fixed.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '');
      return emojiOnly.trim();
    } catch (_) {
      return text;
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Permission Denied.....');
      getCurrentLocation();
    } else {
      print('Permission Granted.....');
      Position currentPosition = await Geolocator.getCurrentPosition();

      lat.value = currentPosition.latitude.toString();
      long.value = currentPosition.longitude.toString();

      // ✅ Save lat/lon to cache so it's available on next app start
      final sp = await SharedPreferences.getInstance();
      await sp.setString("cached_lat", lat.value);
      await sp.setString("cached_lon", long.value);

      await fetchHomeData();
    }
  }

  Future<void> fetchHomeData() async {
    bool canLoad = await _checkAndDeductCredit();

    if (canLoad) {
      getWeatherApiCalling(lat.value, long.value);
      getUpcomingForecast(lat.value, long.value);
      getNearbyByAirportApiCall(lat.value, long.value);
      startWeatherPolling();
    } else {
      inAsyncCall.value = false;
      inAsyncCallForForecast.value = false;
      inAsyncCallForAlert.value = false;
    }
  }

  Future<bool> _checkAndDeductCredit() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://python.aitechnotech.in/skypeanut-api/credits/check-and-deduct'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? 30,
          "feature_key": "basic_alert"
        }),
      );

      print("Credit API Status: ${response.statusCode}");
      print("Credit API Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "0") {
          _showInsufficientCreditsDialog(
              data['message'] ?? "Insufficient credits.");
          return false;
        } else if (data['status'] == "1") {
          int remaining = data['remaining_credits'] ?? -1;
          if (remaining == 2) {
            _showWarningDialog();
          }
          return true;
        }
      }
      return true;
    } catch (e) {
      print("Credit Check Error: $e");
      return true;
    }
  }

  void _showWarningDialog() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primary3Color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: yellowColor, size: 50),
              SizedBox(height: 16),
              Text(
                "Low Credits",
                style: TextStyle(
                  color: textBlackColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "You have only 2 credits remaining.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorGrey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: liteGreenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 45),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showInsufficientCreditsDialog(String message) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary3Color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, color: redSecond, size: 50),
                SizedBox(height: 16),
                Text(
                  "Insufficient Credits",
                  style: TextStyle(
                    color: textBlackColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColorGrey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: liteGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.CREDITS_SCREEN)?.then((_) async {
                      refetchData();
                    });
                  },
                  child: Text(
                    "Buy Now",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Timer? _weatherTimer;
  bool _weatherPollingRunning = false;
  bool _isFetchingWeather = false;

  void startWeatherPolling() {
    if (_weatherPollingRunning) return;
    _weatherPollingRunning = true;

    _weatherTimer?.cancel();
    _weatherTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (lat.value.isEmpty || long.value.isEmpty) return;
      if (_isFetchingWeather) return;

      _isFetchingWeather = true;
      try {
        await getWeatherApiCalling2(lat.value, long.value);
      } catch (_) {
      } finally {
        _isFetchingWeather = false;
      }
    });
  }

  void stopWeatherPolling() {
    _weatherPollingRunning = false;
    _weatherTimer?.cancel();
    _weatherTimer = null;
  }

// ✅ getWeatherApiCalling - pass lat/lon
  Future<void> getWeatherApiCalling(String lat, String long) async {
    try {
      inAsyncCall.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };

      GetWeatherAppModel? getWeatherAppModel =
      await ApiMethods.getWeatherApi(bodyParams: bodyParameter);

      if (getWeatherAppModel != null && getWeatherAppModel.weather != null) {
        _processWeatherData(
          getWeatherAppModel,
          latParam: lat,   // ✅ pass directly
          lonParam: long,  // ✅ pass directly
        );
        _saveToCache(keyWeather, getWeatherAppModel.toJson());
        isOffline.value = false;
      } else {
        throw Exception("Failed to fetch weather");
      }
    } catch (e) {
      print("Weather Data Error: $e");
      isOffline.value = true;
      await _loadWeatherFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

// ✅ getWeatherApiCalling2 - pass lat/lon
  Future<void> getWeatherApiCalling2(String lat, String long) async {
    try {
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };

      GetWeatherAppModel? getWeatherAppModel =
      await ApiMethods.getWeatherApi(bodyParams: bodyParameter);

      if (getWeatherAppModel != null && getWeatherAppModel.weather != null) {
        _processWeatherData(
          getWeatherAppModel,
          latParam: lat,   // ✅ pass directly
          lonParam: long,  // ✅ pass directly
        );
        _saveToCache(keyWeather, getWeatherAppModel.toJson());
        isOffline.value = false;
      } else {
        throw Exception("Failed to fetch weather");
      }
    } catch (e) {
      print("Weather Data Error: $e");
      isOffline.value = true;
      await _loadWeatherFromCache();
    }
  }

  // ── Core weather processing ───────────────────────────────────────
// ✅ Accept lat/lon as parameters instead of using RxString
  void _processWeatherData(
      GetWeatherAppModel getWeatherAppModel, {
        String? latParam,
        String? lonParam,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    windUnit.value = prefs.getString("windUnit") ?? "Knots";
    visibilityUnit.value = prefs.getString("visibilityUnit") ?? "KM";
    temperatureUnit.value = prefs.getString("temperatureUnit") ?? "°C";
    dewPointUnit.value = prefs.getString("dewPointUnit") ?? "°C";
    pressureUnit.value = prefs.getString("pressureUnit") ?? "hPA";

    windDirection.value = getWeatherAppModel.weather!.windDirection ?? "";

    final aq = getWeatherAppModel.weather!.airQuality;
    if (aq != null) {
      aqiUs.value = aq.aqiUs ?? 0;
      aqiCategory.value = aq.category ?? "";
      aqiPm25.value = aq.pm25 ?? 0.0;
    }

    // ✅ Use passed lat/lon first, fallback to RxString, fallback to cache
    String resolvedLat = latParam ?? lat.value;
    String resolvedLon = lonParam ?? long.value;

    // ✅ If still empty, load from SharedPreferences cache
    if (resolvedLat.isEmpty || resolvedLon.isEmpty) {
      final sp = await SharedPreferences.getInstance();
      resolvedLat = sp.getString("cached_lat") ?? "";
      resolvedLon = sp.getString("cached_lon") ?? "";
    }

    print("Resolved lat: $resolvedLat, lon: $resolvedLon");

    // ✅ Update date/time with correct lat/lon
    await _updateDateTimeFromTimestamp(
      getWeatherAppModel.weather!.timestamp,
      resolvedLat,
      resolvedLon,
    );

    // ... rest of method unchanged ...
    if (temperatureUnit.value == "°F") {
      temperature.value = getWeatherAppModel.weather!.temperatureF.toString();
    } else {
      temperature.value = getWeatherAppModel.weather!.temperatureC.toString();
    }

    if (dewPointUnit.value == "°F") {
      due.value = getWeatherAppModel.weather!.dewPointF.toString();
    } else {
      due.value = getWeatherAppModel.weather!.dewPointC.toString();
    }

    if (pressureUnit.value == "inHg") {
      pressure.value = getWeatherAppModel.weather!.pressureInhg.toString();
    } else {
      pressure.value = getWeatherAppModel.weather!.pressureHpa.toString();
    }

    if (windUnit.value == "m/s") {
      windSpeed.value = getWeatherAppModel.weather!.windSpeedMs.toString();
    } else if (windUnit.value == "KM/h") {
      windSpeed.value = getWeatherAppModel.weather!.windSpeed.toString();
    } else {
      windSpeed.value = getWeatherAppModel.weather!.windSpeedKnots.toString();
    }

    if (visibilityUnit.value == "SM") {
      visibility.value = getWeatherAppModel.weather!.visibilitySm.toString();
    } else if (visibilityUnit.value == "NM") {
      visibility.value = getWeatherAppModel.weather!.visibilityNm.toString();
    } else {
      visibility.value = getWeatherAppModel.weather!.visibilityKm.toString();
    }

    alertsList = getWeatherAppModel.alerts!;
    weather = getWeatherAppModel.weather!;
    forecast.value = getWeatherAppModel.weather!.forecast ?? "";
    cityOne.value = getWeatherAppModel.weather!.location ?? '';

    increment();
  }

  static String formatTimestampToDayDate(int timestamp) {
    DateTime dateUtc =
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    DateTime istDate = dateUtc.add(const Duration(hours: 5, minutes: 30));
    return DateFormat('EEE d').format(istDate);
  }

  void increment() => count.value++;
}

class DateHelper {
  static String formatTimestampToDayDate(int timestamp) {
    DateTime date =
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        .toLocal();
    return DateFormat('EEE d').format(date);
  }
}