import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_profile_model.dart';
import '../../../data/apis/api_models/nearby_weather_model.dart';

class WeatherScreenController extends GetxController {
  var date = 'June 07'.obs;
  var city = 'Paris'.obs;
  var name = 'Johan Wick'.obs;
  RxString lat = "".obs;
  RxString long = "".obs;
  RxBool showDetails = false.obs;
  final RxBool inAsyncCall = true.obs; // final RxBool is also valid

  List<Cities> getCitiesData = [];
  GetProfileModel? getProfileModelData;

  var windUnit = "Knots".obs;
  var visibilityUnit = "KM".obs;
  var temperatureUnit = "°C".obs;
  var dewPointUnit = "°C".obs;
  var pressureUnit = "hPA".obs;


  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  String userId = '';

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    getCurrentLocation();
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

  String fixUtf8(String text) {
    try {
      // First, encode it as Latin-1 (ISO-8859-1)
      final latinBytes = latin1.encode(text);

      // Then decode it properly as UTF-8
      return utf8.decode(latinBytes);
    } catch (_) {
      return text; // fallback if something goes wrong
    }
  }

  String extractCondition(String text) {
    try {
      // Fix common encoding issues first
      final fixed = utf8.decode(text.codeUnits, allowMalformed: true);

      // Strip emojis and variation selectors
      final emojiRegex = RegExp(
        r'[\u{2190}-\u{21FF}\u{2300}-\u{23FF}\u{2460}-\u{24FF}\u{2600}-\u{27BF}\u{1F300}-\u{1FAFF}\u{FE0F}]',
        unicode: true,
      );
      final noEmoji = fixed.replaceAll(emojiRegex, '');

      // Keep only letters (incl. accented), spaces and hyphens
      final lettersOnly = noEmoji.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s-]'), '');

      // Collapse multiple spaces and trim
      return lettersOnly.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (_) {
      // Fallback: remove everything except letters/spaces
      final fallback = text.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ\s-]'), '');
      return fallback.replaceAll(RegExp(r'\s+'), ' ').trim();
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
      getWeatherApiCalling(currentPosition.latitude.toString(),
          currentPosition.longitude.toString());
    }
  }

  void increment() => count.value++;

  Future<void> getWeatherApiCalling(String lat, String long) async {
    inAsyncCall.value = true;
    try {
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };

      NearbyWeatherModel? nearbyWeatherModel =
      await ApiMethods.getNearbyWeatherApi(bodyParams: bodyParameter);
      
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (nearbyWeatherModel != null && nearbyWeatherModel.status != "0") {
        await prefs.setString('cached_weather_data', jsonEncode(nearbyWeatherModel.toJson()));
        await _processWeatherData(nearbyWeatherModel);
      } else {
        await _loadCachedData(prefs);
      }
    } catch (e) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await _loadCachedData(prefs);
    }
  }

  Future<void> _loadCachedData(SharedPreferences prefs) async {
    String? cachedData = prefs.getString('cached_weather_data');
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        var decodedData = jsonDecode(cachedData);
        NearbyWeatherModel cacheModel = NearbyWeatherModel.fromJson(decodedData);
        if (cacheModel.cities != null) {
          await _processWeatherData(cacheModel);
          return;
        }
      } catch (e) {
        print("Error parsing cached weather data: $e");
      }
    }
    getCitiesData.clear();
    inAsyncCall.value = false;
    update();
  }

  Future<void> _processWeatherData(NearbyWeatherModel nearbyWeatherModel) async {
    // Load user settings
    final prefs = await SharedPreferences.getInstance();
    windUnit.value = prefs.getString("windUnit") ?? "Knots";
    visibilityUnit.value = prefs.getString("visibilityUnit") ?? "KM";
    temperatureUnit.value = prefs.getString("temperatureUnit") ?? "°C";
    dewPointUnit.value = prefs.getString("dewPointUnit") ?? "°C";
    pressureUnit.value = prefs.getString("pressureUnit") ?? "hPA";

    // Convert and apply to data
    getCitiesData = nearbyWeatherModel.cities?.map((city) {
      // ========== TEMPERATURE ==========
      city.temperature = (temperatureUnit.value == "°F")
          ? (city.temperatureF ?? 0)
          : (city.temperature ?? 0);

      // ========== DEW POINT ==========
      city.dewPointC = (dewPointUnit.value == "°F")
          ? (city.dewPointF ?? 0)
          : (city.dewPointC ?? 0);

      // ========== WIND SPEED ==========
      double windKnots = double.tryParse(city.windSpeedKnots.toString() ?? '0') ?? 0;
      double windMs = city.windSpeedMs ?? 0.0;
      double windKmh = double.tryParse(city.wind ?? '0') ?? 0;

      if (windUnit.value == "KMH") {
        city.wind = windKmh.toStringAsFixed(1);
      } else if (windUnit.value == "m/s") {
        city.wind = windMs.toStringAsFixed(1);
      } else {
        city.wind = windKnots.toStringAsFixed(1);
      }

      // ========== VISIBILITY ==========
      double visKm = city.visibilityKm ?? 0.0;
      double visSm = city.visibilitySm ?? 0.0;
      double visNm = city.visibilityNm ?? 0.0;

      if (visibilityUnit.value == "KM") {
        city.visibility = visKm.toStringAsFixed(1);
      } else if (visibilityUnit.value == "SM") {
        city.visibility = visSm.toStringAsFixed(1);
      } else {
        city.visibility = visNm.toStringAsFixed(1);
      }

      // ========== PRESSURE ==========
      double pressureInhg = city.pressureInhg ?? 0;
      double pressureHpa = city.pressureHpa ?? 0;
      if (pressureUnit.value == "inHg") {
        city.pressureHpa = pressureInhg;
      } else {
        city.pressureHpa = pressureHpa;
      }

      return city;
    }).toList() ?? [];


    print("list data :::  ${getCitiesData.length}");

    inAsyncCall.value = false;
    update();
  }
}



// Future<void> getWeatherApiCalling(String lat, String long) async {
//   inAsyncCall.value = true;
//   // Explicit type for bodyParameter
//   Map<String, dynamic> bodyParameter = {
//     ApiKeyConstants.lat: lat,
//     ApiKeyConstants.lon: long,
//   };
//   print("bodyParameter $bodyParameter");
//
//   // Explicit type for getWeatherAppModel
//   NearbyWeatherModel? nearbyWeatherModel =
//       await ApiMethods.getNearbyWeatherApi(bodyParams: bodyParameter);
//
//   if (nearbyWeatherModel != null && nearbyWeatherModel.status != "0") {
//     getCitiesData = nearbyWeatherModel.cities ?? [];
//
//     inAsyncCall.value = false;
//     increment();
//   } else {
//     inAsyncCall.value = false;
//   }
// }

