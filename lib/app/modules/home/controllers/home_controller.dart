import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_weather_model.dart';

// import '../../../common/common_widgets.dart';
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

  // Add these two observables near the top with the others:
  RxString windDirection = "".obs;
  RxInt aqiUs = 0.obs;
  RxString aqiCategory = "".obs;
  RxDouble aqiPm25 = 0.0.obs;

  // otherwise it might be RxDouble if it's a dew point temperature.
  // Your original code has "56".obs, making it RxString.
  RxString date = 'June 07'.obs;
  RxString rawDate = '6/7/2023 4:55 PM'.obs;
  RxString city = 'Paris'.obs;
  RxString name = 'Johan Wick'.obs;
  final RxBool inAsyncCall = true.obs; // final RxBool is also valid
  final RxBool inAsyncCallForForecast = true.obs; // final RxBool is also valid
  final RxBool inAsyncCallForAlert = true.obs; // final RxBool is also valid
  final RxBool isOffline = false.obs;

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
  Weather? weather; // This is already explicitly typed

  final RxInt count = 0.obs; // final RxInt is also valid

  RxInt currentPage = 0.obs;

  String userId = '';
  GetProfileModel? getProfileModelData;
  List<WeeklyForecast> forecastList = [];
  List<AlertsAirport> alertsListNew = [];
  List<Airports>? nearByAirportsList;

  List<Data>? getNotamData;

  @override
  Future<void> onInit() async {
    super.onInit();

    // Global connectivity listener
    final connectivity = Get.find<ConnectivityController>();
    ever(connectivity.connectivityResults, (results) {
      bool offline =
          results.contains(ConnectivityResult.none) && results.length == 1;
      if (!offline && isOffline.value) {
        // Transitioned from offline to online
        refetchData();
      }
      isOffline.value = offline;
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';

    // Load initial data from cache to populate UI immediately
    _loadInitialCache();

    getProfileApi();
    setCurrentDate();
    getFullDate();
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
    var cached = await _loadFromCache(keyWeather);
    if (cached != null) {
      GetWeatherAppModel model = GetWeatherAppModel.fromJson(cached);
      _processWeatherData(model);
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
    String formattedDate = DateFormat('MMMM dd').format(now); // e.g. "June 07"
    date.value = formattedDate;
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('M/d/yyyy h:mm a').format(dateTime);
  }

  void getFullDate() {
    DateTime now = DateTime.now();
    String formattedDate = formatDateTime(now);
    print(formattedDate); // Output: "6/7/2025 4:55 PM"
    rawDate.value = formattedDate;
  }

  @override
  void onClose() {
    stopWeatherPolling();     // ✅ stop timer
    timer?.cancel();          // your existing auto scroll timer
    pageController.dispose();
    super.onClose();
  }

  // Future<void> getUpcomingForecast(String lat, String long) async {
  //   inAsyncCallForForecast.value = true;
  //   // Explicit type for bodyParameter
  //   Map<String, dynamic> bodyParameter = {
  //     ApiKeyConstants.lat: lat,
  //     ApiKeyConstants.lon: long,
  //     ApiKeyConstants.type: "weekly",
  //   };
  //   print("bodyParameter $bodyParameter");
  //
  //   // Explicit type for getWeatherAppModel
  //   UpcomingForecastWeeklyModel? upcomingForecastWeeklyModel =
  //       await ApiMethods.upcomingForecastApi(bodyParams: bodyParameter);
  //
  //   if (upcomingForecastWeeklyModel != null &&
  //       upcomingForecastWeeklyModel.forecast != null) {
  //     forecastList = upcomingForecastWeeklyModel.forecast ?? [];
  //     inAsyncCallForForecast.value = false;
  //     increment();
  //   } else {
  //     inAsyncCallForForecast.value = false;
  //   }
  // }

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
      // ✅ Safe value extraction
      double tempC = f.temperature?.day ?? 0;
      double tempF = f.temperatureF?.day ?? 0;

      // ✅ Apply temperature conversion
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

      // ✅ Wind conversion
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

      // ✅ Pressure conversion
      if (pressureUnit.value == "inHg") {
        f.pressure = f.pressureInhg;
      } else {
        f.pressure = f.pressureHpa;
      }

      return f;
    }).toList();

    // ✅ Assign reactively so UI updates
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

  /// API Call
  Future<void> getUpcomingAlert(String icaoCode) async {
    try {
      inAsyncCallForAlert.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.airportCode2: icaoCode,
      };

      print("bodyParameter $bodyParameter");

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
      // Fix encoding issues first
      String fixed = utf8.decode(text.runes.toList());

      // Keep only emoji-like characters (non a-z, A-Z, 0-9, spaces)
      String emojiOnly = fixed.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '');

      return emojiOnly.trim();
    } catch (_) {
      return text;
    }
  }

  Future<void> getCurrentLocation() async {
    // Explicit type for permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Permission Denied.....');
      getCurrentLocation();
    } else {
      print('Permission Granted.....');
      // Explicit type for currentPosition
      Position currentPosition = await Geolocator.getCurrentPosition();

      lat.value = currentPosition.latitude.toString();
      long.value = currentPosition.longitude.toString();

      await fetchHomeData();
    }
  }

  Future<void> fetchHomeData() async {
    bool canLoad = await _checkAndDeductCredit();

    if (canLoad) {
      getWeatherApiCalling(lat.value, long.value);
      getUpcomingForecast(lat.value, long.value);
      getNearbyByAirportApiCall(lat.value, long.value);

      // ✅ Start 10-second polling once
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
        Uri.parse('https://python.aitechnotech.in/skypeanut-api/credits/check-and-deduct'),
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
    if (Get.isDialogOpen ?? false) return; // Prevent multiple dialogs
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
    if (Get.isDialogOpen ?? false) return; // Prevent multiple dialogs
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

  Future<void> getWeatherApiCallingq(String lat, String long) async {
    inAsyncCall.value = true;

    Map<String, dynamic> bodyParameter = {
      ApiKeyConstants.lat: lat,
      ApiKeyConstants.lon: long,
    };

    final getWeatherAppModel =
        await ApiMethods.getWeatherApi(bodyParams: bodyParameter);
    final settings = Get.find<WeatherSettingsScreenController>();

    if (getWeatherAppModel != null && getWeatherAppModel.weather != null) {
      alertsList = getWeatherAppModel.alerts!;
      final w = getWeatherAppModel.weather!;

      // Convert values using settings
      double temp = double.tryParse(w.temperature.toString()) ?? 0.0;
      double dew = double.tryParse(w.dewPoint.toString()) ?? 0.0;
      double pressureVal = double.tryParse(w.pressure.toString()) ?? 0.0;
      double wind = double.tryParse(w.windSpeed.toString()) ?? 0.0;
      double vis = double.tryParse(w.visibility.toString()) ?? 0.0;

      cityOne.value = w.location ?? '';

      temperature.value = WeatherUnitConverter.convertTemperature(
          temp, settings.temperatureUnit.value);
      dewDew.value = WeatherUnitConverter.convertTemperature(
          dew, settings.dewPointUnit.value);
      pressure.value = WeatherUnitConverter.convertPressure(
          pressureVal, settings.pressureUnit.value);
      windSpeed.value =
          WeatherUnitConverter.convertWind(wind, settings.windUnit.value);
      visibility.value = WeatherUnitConverter.convertVisibility(
          vis, settings.visibilityUnit.value);

      forecast.value = w.forecast.toString();

      print("Unit ::::forecast ${forecast.value}");
      print("Unit ::::forecast ${w.forecast.toString()}");

      inAsyncCall.value = false;
      increment();
    } else {
      inAsyncCall.value = false;
    }
  }

  Timer? _weatherTimer;
  bool _weatherPollingRunning = false;
  bool _isFetchingWeather = false;

  /// Call this when Home screen becomes visible
  void startWeatherPolling() {
    if (_weatherPollingRunning) return;
    _weatherPollingRunning = true;

    _weatherTimer?.cancel();
    _weatherTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      // If no location yet, do nothing
      if (lat.value.isEmpty || long.value.isEmpty) return;

      // Prevent overlapping API calls
      if (_isFetchingWeather) return;

      _isFetchingWeather = true;
      try {
        await getWeatherApiCalling2(lat.value, long.value);
      } catch (_) {
        // ignore; you already handle offline/caching in getWeatherApiCalling
      } finally {
        _isFetchingWeather = false;
      }
    });
  }

  /// Call this when Home screen is not visible
  void stopWeatherPolling() {
    _weatherPollingRunning = false;
    _weatherTimer?.cancel();
    _weatherTimer = null;
  }

  Future<void> getWeatherApiCalling(String lat, String long) async {
    try {
      inAsyncCall.value = true;
      // Explicit type for bodyParameter
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };
      print("bodyParameter $bodyParameter");

      // Explicit type for getWeatherAppModel
      GetWeatherAppModel? getWeatherAppModel =
          await ApiMethods.getWeatherApi(bodyParams: bodyParameter);

      if (getWeatherAppModel != null && getWeatherAppModel.weather != null) {
        _processWeatherData(getWeatherAppModel);
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
  Future<void> getWeatherApiCalling2(String lat, String long) async {
    try {
    //  inAsyncCall.value = true;
      // Explicit type for bodyParameter
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };
      print("bodyParameter $bodyParameter");

      // Explicit type for getWeatherAppModel
      GetWeatherAppModel? getWeatherAppModel =
          await ApiMethods.getWeatherApi(bodyParams: bodyParameter);

      if (getWeatherAppModel != null && getWeatherAppModel.weather != null) {
        _processWeatherData(getWeatherAppModel);
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
     // inAsyncCall.value = false;
    }
  }

  void _processWeatherData(GetWeatherAppModel getWeatherAppModel) async {
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

    if (temperatureUnit.value == "°F") {
      temperature.value =
          getWeatherAppModel.weather!.temperatureF.toString(); // double
    } else {
      temperature.value =
          getWeatherAppModel.weather!.temperatureC.toString(); // double
    }

    if (dewPointUnit.value == "°F") {
      due.value = getWeatherAppModel.weather!.dewPointF.toString(); // double
    } else {
      due.value = getWeatherAppModel.weather!.dewPointC.toString(); // double
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

    cityOne.value = getWeatherAppModel.weather!.location ?? ''; // String
    increment();
  }

  static String formatTimestampToDayDate(int timestamp) {
    // Convert to UTC and then add IST offset (+5:30)
    DateTime dateUtc =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    DateTime istDate = dateUtc.add(const Duration(hours: 5, minutes: 30));

    return DateFormat('EEE d').format(istDate);
  }

  void increment() => count.value++;
}

class DateHelper {
  /// Convert timestamp (in seconds) to "Mon 18" format in IST
  static String formatTimestampToDayDate(int timestamp) {
    // Convert to DateTime in IST
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .toLocal(); // Converts to local timezone (IST if device is IST)

    // Format: Mon 18
    return DateFormat('EEE d').format(date);
  }
}
