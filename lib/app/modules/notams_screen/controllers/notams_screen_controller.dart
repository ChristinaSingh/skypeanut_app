import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_airport_near_by.dart';
import '../../../data/services/connectivity_controller.dart';

// import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_notam_by_airport_code.dart';
import '../../../data/apis/api_models/get_profile_model.dart';

class NotamsScreenController extends GetxController {
  var temperature = 24.obs;
  var windSpeed = 4.63.obs;
  var visibility = 56.obs;
  var pressure = 1013.obs;
  var forecast = 56.obs;
  var lat = ''.obs;
  var long = ''.obs;

  Map<String, String?> parameters = Get.parameters;

  var date = 'June 07'.obs;
  var city = 'Paris'.obs;
  var name = 'Johan Wick'.obs;

  RxBool showDetails = false.obs;
  RxBool showDetail2 = false.obs;
  RxBool showDetails3 = false.obs;
  final RxBool isOffline = false.obs;

  // Cache Keys
  static const String keyNearbyAirportsNotams = "cache_nearby_airports_notams";
  static const String keyNotamsData = "cache_notams_data";

  List<Airports>? nearByAirportsList;

  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  void toggleDetails2() {
    showDetail2.value = !showDetail2.value;
  }

  void toggleDetails3() {
    showDetails3.value = !showDetails3.value;
  }

  List<Data>? getNotamData;

  final inAsyncCall = true.obs;

  GetProfileModel? getProfileModelData;
  String userId = '';

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    
    // Global connectivity listener
    final connectivity = Get.find<ConnectivityController>();
    ever(connectivity.connectivityResults, (results) {
      bool offline = results.contains(ConnectivityResult.none) && results.length == 1;
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
    
    getCurrentLocation();
  }

  Future<void> refetchData() async {
    await getCurrentLocation();
  }

  Future<void> _loadInitialCache() async {
    await _loadNearbyAirportsFromCache();
    await _loadNotamsFromCache();
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

  Future<void> _loadNearbyAirportsFromCache() async {
    var cached = await _loadFromCache(keyNearbyAirportsNotams);
    if (cached != null) {
      NearbyAirportModel model = NearbyAirportModel.fromJson(cached);
      nearByAirportsList = model.airports ?? [];
    }
  }

  Future<void> _loadNotamsFromCache() async {
    var cached = await _loadFromCache(keyNotamsData);
    if (cached != null) {
      NotamModel model = NotamModel.fromJson(cached);
      getNotamData = model.data;
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
      getNearbyByAirportApiCall(currentPosition.latitude.toString(),
          currentPosition.longitude.toString());
      lat.value = currentPosition.latitude.toString();
      long.value = currentPosition.longitude.toString();
    }
  }



  Future<void> getNotamBYAirportData(String airportCode) async {
    try {
      inAsyncCall.value = true;
      NotamModel? notamModel =
          await ApiMethods.getNotamBYAirport(bodyParams: airportCode);
      if (notamModel != null && notamModel.success == true) {
        getNotamData = notamModel.data;
        print("data is plans ${getNotamData?.first.description ?? ''}");
        _saveToCache(keyNotamsData, notamModel.toJson());
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
      // Explicit type for bodyParameter
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.lat: lat,
        ApiKeyConstants.lon: long,
      };
      print("bodyParameter $bodyParameter");

      // Explicit type for getWeatherAppModel
      NearbyAirportModel? nearbyAirportModel =
          await ApiMethods.getNearbyByAirport(bodyParams: bodyParameter);

      if (nearbyAirportModel != null && nearbyAirportModel.status != "0") {
        nearByAirportsList = nearbyAirportModel.airports ?? [];
        getNotamBYAirportData(
            "${nearByAirportsList?.first.icaoCode ?? ''},${nearByAirportsList?[1].icaoCode ?? ''},${nearByAirportsList?[2].icaoCode ?? ''}");
        _saveToCache(keyNearbyAirportsNotams, nearbyAirportModel.toJson());
        isOffline.value = false;
        increment();
      } else {
        throw Exception("Failed to fetch nearby airports");
      }
    } catch (e) {
      print("Nearby Airport API Error: $e");
      isOffline.value = true;
      await _loadNearbyAirportsFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

  void increment() => count.value++;
}
