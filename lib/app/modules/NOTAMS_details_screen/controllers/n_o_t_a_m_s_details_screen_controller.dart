import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/connectivity_controller.dart';

// import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_details_notams.dart';

class NOTAMSDetailsScreenController extends GetxController {
  final count = 0.obs;
  Map<String, String?> parameters = Get.parameters;

  final RxBool isOffline = false.obs;

  // Cache Key
  static const String keyNotamsDetails = "cache_notams_details";

  // Full unmodified list from API
  List<Notams> notamsList = [];

  // Reactive list the view always reads from
  final RxList<Notams> filteredNotams = <Notams>[].obs;

  // Drives which chip is highlighted
  final RxString activeFilter = 'all'.obs;

  final inAsyncCall = true.obs;

  @override
  void onInit() {
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

    // Load initial data from cache to populate UI immediately
    _loadInitialCache();
    
    getDetailsNotamsApiData();
  }

  Future<void> refetchData() async {
    await getDetailsNotamsApiData();
  }

  Future<void> _loadInitialCache() async {
    await _loadNotamsDetailsFromCache();
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

  Future<void> _loadNotamsDetailsFromCache() async {
    String airportCode = parameters[ApiKeyConstants.airportCode] ?? '';
    var cached = await _loadFromCache("${keyNotamsDetails}_$airportCode");
    if (cached != null) {
      final NotamAirportModel model = NotamAirportModel.fromJson(cached);
      notamsList = model.notams ?? [];
      _applyFilter();
    }
  }



  // Called by every filter chip tap
  void filterNotams(String filter) {
    activeFilter.value = filter.toLowerCase().trim();
    _applyFilter();
  }

  void _applyFilter() {
    final f = activeFilter.value;
    if (f == 'all' || f.isEmpty) {
      // Show everything
      filteredNotams.assignAll(List<Notams>.from(notamsList));
    } else {
      filteredNotams.assignAll(
        notamsList
            .where((n) => (n.criticality ?? '').toLowerCase().trim() == f)
            .toList(),
      );
    }
    // Force Obx refresh
    increment();
  }

  Future<void> getDetailsNotamsApiData() async {
    try {
      inAsyncCall.value = true;
      String airportCode = parameters[ApiKeyConstants.airportCode] ?? '';

      final NotamAirportModel? model = await ApiMethods.getDetailsNotamsApi(
        bodyParams: {
          ApiKeyConstants.airport: airportCode,
        },
      );

      if (model != null) {
        notamsList = model.notams ?? [];
        _saveToCache("${keyNotamsDetails}_$airportCode", model.toJson());
        isOffline.value = false;
        // Always default to ALL on first load
        activeFilter.value = 'all';
        _applyFilter();
      } else {
        throw Exception("Failed to fetch NOTAM details");
      }
    } catch (e) {
      print("NOTAM Details Error: $e");
      isOffline.value = true;
      await _loadNotamsDetailsFromCache();
    } finally {
      inAsyncCall.value = false;
    }
  }

  void increment() => count.value++;
}