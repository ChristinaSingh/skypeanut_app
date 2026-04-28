import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_airport_near_by.dart';
import '../../../data/apis/api_models/get_find_routes_model.dart';

class SearchRoutesScreenController extends GetxController {
  final count = 0.obs;
  final RxBool inAsyncCall = true.obs;

  static const _baseUrl = "https://python.aitechnotech.in/skypeanut-api/api/v1";

  // ── Nearby airports for quick-fill suggestions ────────────────────────────
  List<Airports> nearByAirportsList = [];
  RxString lat = "".obs;
  RxString long = "".obs;

  // ── Search input values ───────────────────────────────────────────────────
  // Code/text sent to API (ICAO / IATA / city name / airport name)
  var selectedFromAirport = "".obs;
  var selectedToAirport = "".obs;
  // Display text shown inside the TextField (may include full airport name)
  var fromDisplayText = "".obs;
  var toDisplayText = "".obs;

  // ── Loading states ────────────────────────────────────────────────────────
  var isLoading = false.obs;          // Step 1: flight-search
  var isLoadingDetails = false.obs;   // Step 2: flight-details
  var errorMessage = "".obs;

  // ── Results ───────────────────────────────────────────────────────────────
  FindRoutesModel? findRoutesModel;
  Rx<FlightDetailsModel?> flightDetails = Rx<FlightDetailsModel?>(null);

  // ── Date ──────────────────────────────────────────────────────────────────
  var selectedDate = DateTime.now().obs;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }



  // ── Location ──────────────────────────────────────────────────────────────
  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location Permission Denied – retrying');
      getCurrentLocation();
      return;
    }
    print('Location Permission Granted');
    Position pos = await Geolocator.getCurrentPosition();
    lat.value = pos.latitude.toString();
    long.value = pos.longitude.toString();
    await getNearbyByAirportApiCall(lat.value, long.value);
  }

  Future<void> getNearbyByAirportApiCall(String lat, String long) async {
    inAsyncCall.value = true;
    final NearbyAirportModel? nearbyAirportModel =
    await ApiMethods.getNearbyByAirport(
        bodyParams: {ApiKeyConstants.lat: lat, ApiKeyConstants.lon: long});

    if (nearbyAirportModel != null && nearbyAirportModel.status != "0") {
      nearByAirportsList = nearbyAirportModel.airports ?? [];

      // Auto-fill FROM with nearest airport
      if (nearByAirportsList.isNotEmpty && selectedFromAirport.value.isEmpty) {
        final nearest = nearByAirportsList.first;
        final code = nearest.icaoCode ?? "";
        selectedFromAirport.value = code;
        fromDisplayText.value =
        (code.isNotEmpty && (nearest.name?.isNotEmpty ?? false))
            ? "$code – ${nearest.name}"
            : code;
      }
    }
    inAsyncCall.value = false;
    increment();
  }

  void increment() => count.value++;

  // ── Date helpers ──────────────────────────────────────────────────────────
  String get departureDateString {
    final d = selectedDate.value;
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String get departureDateDisplay {
    final d = selectedDate.value;
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return "${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}";
  }

  // ── Swap FROM ↔ TO ────────────────────────────────────────────────────────
  void swapAirports() {
    final tmpCode = selectedFromAirport.value;
    final tmpDisplay = fromDisplayText.value;
    selectedFromAirport.value = selectedToAirport.value;
    fromDisplayText.value = toDisplayText.value;
    selectedToAirport.value = tmpCode;
    toDisplayText.value = tmpDisplay;
    increment();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  STEP 1 — flight-search
  //  Uses: /api/v1/flight-search?from_location=&to_location=&departure_date=
  //  Accepts any city, airport name, IATA, or ICAO code
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> findRoutesApiCall(String from, String to) async {
    if (from.trim().isEmpty || to.trim().isEmpty) {
      CommonWidgets.showMyToastMessage('Please enter both From and To locations');
      return;
    }

    // Reset previous results
    findRoutesModel = null;
    flightDetails.value = null;
    errorMessage.value = "";
    increment();

    if (!await CommonWidgets.internetConnectionCheckerMethod()) {
      CommonWidgets.snackBarView(
          title: 'Please Check Your Internet Connection', success: false);
      return;
    }

    isLoading.value = true;

    try {
      final uri = Uri.parse(
        "$_baseUrl/flight-search"
            "?from_location=${Uri.encodeComponent(from.trim())}"
            "&to_location=${Uri.encodeComponent(to.trim())}"
            "&departure_date=$departureDateString",
      );

      print("flight-search → $uri");

      final res = await http.get(uri).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (json['status']?.toString() == '1') {
          findRoutesModel = FindRoutesModel.fromJson(json);
          increment(); // show search results immediately

          // ── STEP 2: chain flight-details ────────────────────────────────
          final carrier = findRoutesModel?.data?.flightInformation?.carrierCode;
          final flight = findRoutesModel?.data?.flightInformation?.flightNumber;
          if ((carrier?.isNotEmpty ?? false) && (flight?.isNotEmpty ?? false)) {
            _fetchFlightDetails(carrier!, flight!); // non-awaited – loads async
          }
        } else {
          errorMessage.value = json['message']?.toString() ?? 'No results found';
          increment();
        }
      } else {
        errorMessage.value = 'Server error (${res.statusCode}). Please try again.';
        increment();
      }
    } catch (e) {
      errorMessage.value = "Failed to fetch flight data. Please try again.";
      increment();
      print("flight-search error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  STEP 2 — flight-details (auto-called after flight-search succeeds)
  //  Uses: /api/v1/flight-details?carrier_code=&flight_number=&departure_date=
  //  Shows: schedule, terminal/gate, passenger info, arrival city weather
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _fetchFlightDetails(String carrierCode, String flightNumber) async {
    isLoadingDetails.value = true;
    try {
      final uri = Uri.parse(
        "$_baseUrl/flight-details"
            "?carrier_code=${Uri.encodeComponent(carrierCode)}"
            "&flight_number=${Uri.encodeComponent(flightNumber)}"
            "&departure_date=$departureDateString",
      );

      print("flight-details → $uri");

      final res = await http.get(uri).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (json['status']?.toString() == '1') {
          flightDetails.value = FlightDetailsModel.fromJson(json);
          increment();
        }
      }
    } catch (e) {
      // flight-details failure is non-fatal; search results are still visible
      print("flight-details error: $e");
    } finally {
      isLoadingDetails.value = false;
    }
  }
}