// ─────────────────────────────────────────────────────────────────────────────
// flight_status_screen_controller.dart  (UPDATED — map fields added)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/colors.dart';
import '../../../routes/app_pages.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';

/// Tracks which kind of result is currently displayed.
enum ResultType { none, flightStatus, flightSearch }

class FlightStatusScreenController extends GetxController {
  // ── Tab ──────────────────────────────────────────────────────────────────
  final selectedTabIndex = 0.obs; // 0 = Flight no., 1 = Route

  // ── Text controllers ─────────────────────────────────────────────────────
  final flightNumberController = TextEditingController();
  final fromController         = TextEditingController();
  final toController           = TextEditingController();

  // ── Date ─────────────────────────────────────────────────────────────────
  final selectedDate = DateTime.now().obs;

  // ── Async / error state ───────────────────────────────────────────────────
  final inAsyncCall    = false.obs;
  final errorMessage   = ''.obs;
  final hasResult      = false.obs;

  // ── Result type + payloads ────────────────────────────────────────────────
  final Rx<ResultType>          resultType        = ResultType.none.obs;
  final Rxn<FlightStatusModel>  flightStatusResult = Rxn();
  final Rxn<FlightSearchModel>  flightSearchResult = Rxn();

  // ── Map fields (used by _FlightEmbeddedMapView in the view) ──────────────
  final mapIsLoading = true.obs;
  final webCount     = 0.obs;
  void webCountIncrement() => webCount.value++;

  // ── API base URLs ─────────────────────────────────────────────────────────
  static const _statusUrl =
      'https://python.aitechnotech.in/skypeanut-api/api/v1/flight-status';
  static const _searchUrl =
      'https://python.aitechnotech.in/skypeanut-api/api/v1/flight-search';

  @override
  void onClose() {
    flightNumberController.dispose();
    fromController.dispose();
    toController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Date helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Display label  e.g.  "Mon, Mar 16"
  String get formattedDateLabel {
    final d = selectedDate.value;
    const days   = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  /// API query param  e.g.  "2026-03-16"
  String get apiDateString {
    final d = selectedDate.value;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear previous results
  // ─────────────────────────────────────────────────────────────────────────
  void _clearResults() {
    errorMessage.value       = '';
    hasResult.value          = false;
    resultType.value         = ResultType.none;
    flightStatusResult.value = null;
    flightSearchResult.value = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 0 — Check status by Flight Number  →  /flight-status
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> checkByFlightNumber() async {
    final fn = flightNumberController.text.trim().toUpperCase();
    if (fn.isEmpty) {
      _snack('Missing Info', 'Please enter a flight number (e.g. AI2981).');
      return;
    }
    
    inAsyncCall.value = true;
    bool canLoad = await _checkAndDeductCredit();
    if (canLoad) {
      await _callFlightStatusApi(fn);
    } else {
      inAsyncCall.value = false;
    }
  }

  Future<void> _callFlightStatusApi(String flightNumber) async {
    try {
      inAsyncCall.value = true;
      _clearResults();

      final uri = Uri.parse(_statusUrl).replace(queryParameters: {
        'flight_number'  : flightNumber,
        'departure_date' : apiDateString,
      });

      debugPrint('FlightStatus API → $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugPrint('FlightStatus ${response.statusCode}');
      debugPrint('FlightStatus body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        // Guard: response must be a JSON object
        if (jsonBody is! Map<String, dynamic>) {
          errorMessage.value = 'Unexpected response format from server.';
          return;
        }

        final model = FlightStatusModel.fromJson(jsonBody);
        if (model.status == '1' && model.data != null) {
          flightStatusResult.value = model;
          resultType.value         = ResultType.flightStatus;
          hasResult.value          = true;
        } else {
          errorMessage.value =
          model.message?.isNotEmpty == true
              ? model.message!
              : 'No flight data found for $flightNumber on $apiDateString.';
        }
      } else if (response.statusCode == 404) {
        errorMessage.value =
        'Flight $flightNumber not found. Check the number and date.';
      } else {
        errorMessage.value =
        'Server error (${response.statusCode}). Please try again.';
      }
    } on Exception catch (e) {
      debugPrint('FlightStatus error: $e');
      errorMessage.value =
      'Connection failed. Check your internet and try again.';
    } finally {
      inAsyncCall.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1 — Check by Route  →  /flight-search
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> checkByRoute() async {
    final from = fromController.text.trim().toUpperCase();
    final to   = toController.text.trim().toUpperCase();

    if (from.isEmpty || to.isEmpty) {
      _snack('Missing Info',
          'Please enter both departure and arrival locations.');
      return;
    }
    
    inAsyncCall.value = true;
    bool canLoad = await _checkAndDeductCredit();
    if (canLoad) {
      await _callFlightSearchApi(from, to);
    } else {
      inAsyncCall.value = false;
    }
  }

  Future<void> _callFlightSearchApi(String from, String to) async {
    try {
      inAsyncCall.value = true;
      _clearResults();

      final uri = Uri.parse(_searchUrl).replace(queryParameters: {
        'from_location' : from,
        'to_location'   : to,
        'departure_date': apiDateString,
      });

      debugPrint('FlightSearch API → $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugPrint('FlightSearch ${response.statusCode}');
      debugPrint('FlightSearch body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody is! Map<String, dynamic>) {
          errorMessage.value = 'Unexpected response format from server.';
          return;
        }

        final model = FlightSearchModel.fromJson(jsonBody);
        if (model.status == '1' && model.data != null) {
          flightSearchResult.value = model;
          resultType.value         = ResultType.flightSearch;
          hasResult.value          = true;
        } else {
          errorMessage.value =
          model.message?.isNotEmpty == true
              ? model.message!
              : 'No route data found from $from to $to on $apiDateString.';
        }
      } else if (response.statusCode == 404) {
        errorMessage.value =
        'Route $from → $to not found. Try using IATA codes (e.g. DEL, BOM).';
      } else {
        errorMessage.value =
        'Server error (${response.statusCode}). Please try again.';
      }
    } on Exception catch (e) {
      debugPrint('FlightSearch error: $e');
      errorMessage.value =
      'Connection failed. Check your internet and try again.';
    } finally {
      inAsyncCall.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // After Route search, let user jump to full flight status
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> checkStatusForSearchedFlight(String fullFlightNumber) async {
    flightNumberController.text = fullFlightNumber;
    selectedTabIndex.value      = 0;
    
    inAsyncCall.value = true;
    bool canLoad = await _checkAndDeductCredit();
    if (canLoad) {
      await _callFlightStatusApi(fullFlightNumber);
    } else {
      inAsyncCall.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utility helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Format minutes → "2h 15m" style
  String formatDuration(double? minutes) {
    if (minutes == null) return '--';
    final total = minutes.round();
    final h = total ~/ 60;
    final m = total % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Status badge colour
  Color statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF4CAF50);
      case 'delayed':
        return const Color(0xFFFF9800);
      case 'cancelled':
        return const Color(0xFFF44336);
      case 'landed':
      case 'arrived':
        return const Color(0xFF2196F3);
      case 'boarding':
        return const Color(0xFF9C27B0);
      case 'en route':
      case 'airborne':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Punctuality percentage → colour
  Color punctualityColor(double? pct) {
    if (pct == null) return const Color(0xFF9E9E9E);
    if (pct >= 80) return const Color(0xFF4CAF50);
    if (pct >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Credit Check & UI
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> _checkAndDeductCredit() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString(ApiKeyConstants.userId) ?? '30';

      final response = await http.post(
        Uri.parse('https://python.aitechnotech.in/skypeanut-api/credits/check-and-deduct'),
        headers: {
           'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": int.tryParse(userId) ?? 30,
          "feature_key": "flight_plan"
        }),
      );

      debugPrint("Credit API Status: ${response.statusCode}");
      debugPrint("Credit API Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == "0") {
            _showInsufficientCreditsDialog(data['message'] ?? "Insufficient credits.");
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
      debugPrint("Credit Check Error: $e");
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primary3Color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: yellowColor, size: 50),
              const SizedBox(height: 16),
              const Text(
                "Low Credits",
                style: TextStyle(
                  color: textBlackColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You have only 2 credits remaining.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: liteGreenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary3Color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: redSecond, size: 50),
                const SizedBox(height: 16),
                const Text(
                  "Insufficient Credits",
                  style: TextStyle(
                    color: textBlackColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textColorGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: liteGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.CREDITS_SCREEN); 
                  },
                  child: const Text(
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
}


// ─────────────────────────────────────────────────────────────────────────────
// MODEL: FlightStatusModel  (/api/v1/flight-status)
// ─────────────────────────────────────────────────────────────────────────────

class FlightStatusModel {
  final String? status;
  final String? message;
  final FlightStatusData? data;

  FlightStatusModel({this.status, this.message, this.data});

  factory FlightStatusModel.fromJson(Map<String, dynamic> json) =>
      FlightStatusModel(
        status: json['status']?.toString(),
        message: json['message']?.toString(),
        data: json['data'] is Map<String, dynamic>
            ? FlightStatusData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class FlightStatusData {
  final StatusFlightInfo? flightInfo;
  final ResolvedLocations? resolvedLocations;
  final StatusRouteInfo? routeInfo;
  final StatusDeparture? departure;
  final StatusArrival? arrival;
  final StatusAircraft? aircraft;
  final StatusDepartureForecast? departureForecast;
  final StatusArrivalWeather? arrivalWeather;

  FlightStatusData({
    this.flightInfo,
    this.resolvedLocations,
    this.routeInfo,
    this.departure,
    this.arrival,
    this.aircraft,
    this.departureForecast,
    this.arrivalWeather,
  });

  factory FlightStatusData.fromJson(Map<String, dynamic> json) =>
      FlightStatusData(
        flightInfo: json['flight_info'] is Map<String, dynamic>
            ? StatusFlightInfo.fromJson(json['flight_info'])
            : null,
        resolvedLocations: json['resolved_locations'] is Map<String, dynamic>
            ? ResolvedLocations.fromJson(json['resolved_locations'])
            : null,
        routeInfo: json['route_info'] is Map<String, dynamic>
            ? StatusRouteInfo.fromJson(json['route_info'])
            : null,
        departure: json['departure'] is Map<String, dynamic>
            ? StatusDeparture.fromJson(json['departure'])
            : null,
        arrival: json['arrival'] is Map<String, dynamic>
            ? StatusArrival.fromJson(json['arrival'])
            : null,
        aircraft: json['aircraft'] is Map<String, dynamic>
            ? StatusAircraft.fromJson(json['aircraft'])
            : null,
        departureForecast: json['departure_forecast'] is Map<String, dynamic>
            ? StatusDepartureForecast.fromJson(json['departure_forecast'])
            : null,
        arrivalWeather: json['arrival_weather'] is Map<String, dynamic>
            ? StatusArrivalWeather.fromJson(json['arrival_weather'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'flight_info': flightInfo?.toJson(),
    'resolved_locations': resolvedLocations?.toJson(),
    'route_info': routeInfo?.toJson(),
    'departure': departure?.toJson(),
    'arrival': arrival?.toJson(),
    'aircraft': aircraft?.toJson(),
    'departure_forecast': departureForecast?.toJson(),
    'arrival_weather': arrivalWeather?.toJson(),
  };

  // Computed properties for easier access
  FlightPerformance? get performance {
    if (departureForecast == null) return null;
    return FlightPerformance(
      departurePunctuality:
      departureForecast!.departurePunctuality?.toString(),
      arrivalPunctuality: departureForecast!.arrivalPunctuality?.toString(),
      avgDelayMinutes: departureForecast!.avgDelayMinutes,
    );
  }

  FlightRoute? get route {
    if (routeInfo?.distance == null) return null;
    return FlightRoute(distance: routeInfo!.distance);
  }
}

class StatusFlightInfo {
  final String? flightNumber;
  final String? carrierCode;
  final String? number;
  final String? status;
  final String? departureDate;
  final String? dataSource;

  StatusFlightInfo({
    this.flightNumber,
    this.carrierCode,
    this.number,
    this.status,
    this.departureDate,
    this.dataSource,
  });

  factory StatusFlightInfo.fromJson(Map<String, dynamic> json) =>
      StatusFlightInfo(
        flightNumber: json['flight_number']?.toString(),
        carrierCode: json['carrier_code']?.toString(),
        number: json['number']?.toString(),
        status: json['status']?.toString(),
        departureDate: json['departure_date']?.toString(),
        dataSource: json['data_source']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'flight_number': flightNumber,
    'carrier_code': carrierCode,
    'number': number,
    'status': status,
    'departure_date': departureDate,
    'data_source': dataSource,
  };
}

class ResolvedLocations {
  final ResolvedLocation? from;
  final ResolvedLocation? to;

  ResolvedLocations({this.from, this.to});

  factory ResolvedLocations.fromJson(Map<String, dynamic> json) =>
      ResolvedLocations(
        from: json['from'] is Map<String, dynamic>
            ? ResolvedLocation.fromJson(json['from'])
            : null,
        to: json['to'] is Map<String, dynamic>
            ? ResolvedLocation.fromJson(json['to'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'from': from?.toJson(),
    'to': to?.toJson(),
  };
}

class ResolvedLocation {
  final bool? success;
  final String? airportCode;
  final String? icaoCode;
  final String? name;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? state;
  final double? latitude;
  final double? longitude;
  final String? matchedBy;
  final String? input;
  final String? airportName;

  ResolvedLocation({
    this.success,
    this.airportCode,
    this.icaoCode,
    this.name,
    this.city,
    this.country,
    this.countryCode,
    this.state,
    this.latitude,
    this.longitude,
    this.matchedBy,
    this.input,
    this.airportName,
  });

  factory ResolvedLocation.fromJson(Map<String, dynamic> json) =>
      ResolvedLocation(
        success: json['success'] as bool?,
        airportCode: json['airport_code']?.toString(),
        icaoCode: json['icao_code']?.toString(),
        name: json['name']?.toString() ?? json['airport_name']?.toString(),
        city: json['city']?.toString(),
        country: json['country']?.toString(),
        countryCode: json['country_code']?.toString(),
        state: json['state']?.toString(),
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
        matchedBy: json['matched_by']?.toString(),
        input: json['input']?.toString(),
        airportName: json['airport_name']?.toString() ?? json['name']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'airport_code': airportCode,
    'icao_code': icaoCode,
    'name': name,
    'city': city,
    'country': country,
    'country_code': countryCode,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'matched_by': matchedBy,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class StatusRouteInfo {
  final String? from;
  final String? departureDate;
  final RouteDistance? distance;

  StatusRouteInfo({this.from, this.departureDate, this.distance});

  factory StatusRouteInfo.fromJson(Map<String, dynamic> json) =>
      StatusRouteInfo(
        from: json['from']?.toString(),
        departureDate: json['departure_date']?.toString(),
        distance: json['distance'] is Map<String, dynamic>
            ? RouteDistance.fromJson(json['distance'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'from': from,
    'departure_date': departureDate,
    'distance': distance?.toJson(),
  };
}

class RouteDistance {
  final double? distanceKm;
  final double? distanceNm;
  final double? distanceMiles;
  final double? bearingDegrees;
  final double? estimatedFlightTimeHours;
  final double? estimatedFlightTimeMinutes;

  RouteDistance({
    this.distanceKm,
    this.distanceNm,
    this.distanceMiles,
    this.bearingDegrees,
    this.estimatedFlightTimeHours,
    this.estimatedFlightTimeMinutes,
  });

  factory RouteDistance.fromJson(Map<String, dynamic> json) => RouteDistance(
    distanceKm: _parseDouble(json['distance_km']),
    distanceNm: _parseDouble(json['distance_nm']),
    distanceMiles: _parseDouble(json['distance_miles']),
    bearingDegrees: _parseDouble(json['bearing_degrees']),
    estimatedFlightTimeHours:
    _parseDouble(json['estimated_flight_time_hours']),
    estimatedFlightTimeMinutes:
    _parseDouble(json['estimated_flight_time_minutes']),
  );

  Map<String, dynamic> toJson() => {
    'distance_km': distanceKm,
    'distance_nm': distanceNm,
    'distance_miles': distanceMiles,
    'bearing_degrees': bearingDegrees,
    'estimated_flight_time_hours': estimatedFlightTimeHours,
    'estimated_flight_time_minutes': estimatedFlightTimeMinutes,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class StatusDeparture {
  final String? airportCode;
  final String? scheduledTime;

  StatusDeparture({this.airportCode, this.scheduledTime});

  factory StatusDeparture.fromJson(Map<String, dynamic> json) =>
      StatusDeparture(
        airportCode: json['airport_code']?.toString(),
        scheduledTime: json['scheduled_time']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'airport_code': airportCode,
    'scheduled_time': scheduledTime,
  };

  String? get city => null;
  String? get airportName => null;
  String? get terminal => null;

  String get formattedTime {
    if (scheduledTime == null || scheduledTime!.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(scheduledTime!).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}

class StatusArrival {
  final String? airportCode;
  final String? scheduledTime;

  StatusArrival({this.airportCode, this.scheduledTime});

  factory StatusArrival.fromJson(Map<String, dynamic> json) => StatusArrival(
    airportCode: json['airport_code']?.toString(),
    scheduledTime: json['scheduled_time']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'airport_code': airportCode,
    'scheduled_time': scheduledTime,
  };

  String? get city => null;
  String? get airportName => null;
  String? get terminal => null;

  String get formattedTime {
    if (scheduledTime == null || scheduledTime!.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(scheduledTime!).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}

class StatusAircraft {
  final String? aircraftType;
  final String? manufacturer;
  final String? model;
  final int? seats;
  final int? yearsInService;
  final String? firstFlight;
  final double? cruiseSpeedKmh;
  final double? rangeKm;
  final double? lengthM;
  final double? wingspanM;
  final String? registration;
  final String? source;

  StatusAircraft({
    this.aircraftType,
    this.manufacturer,
    this.model,
    this.seats,
    this.yearsInService,
    this.firstFlight,
    this.cruiseSpeedKmh,
    this.rangeKm,
    this.lengthM,
    this.wingspanM,
    this.registration,
    this.source,
  });

  factory StatusAircraft.fromJson(Map<String, dynamic> json) => StatusAircraft(
    aircraftType: json['aircraft_type']?.toString(),
    manufacturer: json['manufacturer']?.toString(),
    model: json['model']?.toString(),
    seats: _parseInt(json['seats']),
    yearsInService: _parseInt(json['years_in_service']),
    firstFlight: json['first_flight']?.toString(),
    cruiseSpeedKmh: _parseDouble(json['cruise_speed_kmh']),
    rangeKm: _parseDouble(json['range_km']),
    lengthM: _parseDouble(json['length_m']),
    wingspanM: _parseDouble(json['wingspan_m']),
    registration: json['registration']?.toString(),
    source: json['source']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'aircraft_type': aircraftType,
    'manufacturer': manufacturer,
    'model': model,
    'seats': seats,
    'years_in_service': yearsInService,
    'first_flight': firstFlight,
    'cruise_speed_kmh': cruiseSpeedKmh,
    'range_km': rangeKm,
    'length_m': lengthM,
    'wingspan_m': wingspanM,
    'registration': registration,
    'source': source,
  };

  String? get type => aircraftType;

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class StatusDepartureForecast {
  final int? departurePunctuality;
  final int? arrivalPunctuality;
  final int? avgDelayMinutes;
  final double? avgDelayHours;
  final DelayDistribution? delayDistribution;
  final Last30Flights? last30Flights;

  StatusDepartureForecast({
    this.departurePunctuality,
    this.arrivalPunctuality,
    this.avgDelayMinutes,
    this.avgDelayHours,
    this.delayDistribution,
    this.last30Flights,
  });

  factory StatusDepartureForecast.fromJson(Map<String, dynamic> json) =>
      StatusDepartureForecast(
        departurePunctuality: _parseInt(json['departure_punctuality']),
        arrivalPunctuality: _parseInt(json['arrival_punctuality']),
        avgDelayMinutes: _parseInt(json['avg_delay_minutes']),
        avgDelayHours: _parseDouble(json['avg_delay_hours']),
        delayDistribution: json['delay_distribution'] is Map<String, dynamic>
            ? DelayDistribution.fromJson(json['delay_distribution'])
            : null,
        last30Flights: json['last_30_flights'] is Map<String, dynamic>
            ? Last30Flights.fromJson(json['last_30_flights'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'departure_punctuality': departurePunctuality,
    'arrival_punctuality': arrivalPunctuality,
    'avg_delay_minutes': avgDelayMinutes,
    'avg_delay_hours': avgDelayHours,
    'delay_distribution': delayDistribution?.toJson(),
    'last_30_flights': last30Flights?.toJson(),
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class DelayDistribution {
  final int? early;
  final int? onTime;
  final int? late030Mins;
  final int? late3060Mins;
  final int? late6090Mins;
  final int? lateOver90Mins;
  final int? cancelled;

  DelayDistribution({
    this.early,
    this.onTime,
    this.late030Mins,
    this.late3060Mins,
    this.late6090Mins,
    this.lateOver90Mins,
    this.cancelled,
  });

  factory DelayDistribution.fromJson(Map<String, dynamic> json) =>
      DelayDistribution(
        early: _parseInt(json['early']),
        onTime: _parseInt(json['on_time']),
        late030Mins: _parseInt(json['late_0_30_mins']),
        late3060Mins: _parseInt(json['late_30_60_mins']),
        late6090Mins: _parseInt(json['late_60_90_mins']),
        lateOver90Mins: _parseInt(json['late_over_90_mins']),
        cancelled: _parseInt(json['cancelled']),
      );

  Map<String, dynamic> toJson() => {
    'early': early,
    'on_time': onTime,
    'late_0_30_mins': late030Mins,
    'late_30_60_mins': late3060Mins,
    'late_60_90_mins': late6090Mins,
    'late_over_90_mins': lateOver90Mins,
    'cancelled': cancelled,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class Last30Flights {
  final int? total;
  final int? onTime;
  final int? delayed;
  final int? cancelled;

  Last30Flights({this.total, this.onTime, this.delayed, this.cancelled});

  factory Last30Flights.fromJson(Map<String, dynamic> json) => Last30Flights(
    total: _parseInt(json['total']),
    onTime: _parseInt(json['on_time']),
    delayed: _parseInt(json['delayed']),
    cancelled: _parseInt(json['cancelled']),
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'on_time': onTime,
    'delayed': delayed,
    'cancelled': cancelled,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class StatusArrivalWeather {
  final String? location;
  final double? temperature;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final String? condition;
  final String? description;
  final int? humidity;
  final int? pressure;
  final double? windSpeedMs;
  final double? windSpeedKmh;
  final double? visibilityKm;
  final int? clouds;

  StatusArrivalWeather({
    this.location,
    this.temperature,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.condition,
    this.description,
    this.humidity,
    this.pressure,
    this.windSpeedMs,
    this.windSpeedKmh,
    this.visibilityKm,
    this.clouds,
  });

  factory StatusArrivalWeather.fromJson(Map<String, dynamic> json) =>
      StatusArrivalWeather(
        location: json['location']?.toString(),
        temperature: _parseDouble(json['temperature']),
        feelsLike: _parseDouble(json['feels_like']),
        tempMin: _parseDouble(json['temp_min']),
        tempMax: _parseDouble(json['temp_max']),
        condition: json['condition']?.toString(),
        description: json['description']?.toString(),
        humidity: _parseInt(json['humidity']),
        pressure: _parseInt(json['pressure']),
        windSpeedMs: _parseDouble(json['wind_speed_ms']),
        windSpeedKmh: _parseDouble(json['wind_speed_kmh']),
        visibilityKm: _parseDouble(json['visibility_km']),
        clouds: _parseInt(json['clouds']),
      );

  Map<String, dynamic> toJson() => {
    'location': location,
    'temperature': temperature,
    'feels_like': feelsLike,
    'temp_min': tempMin,
    'temp_max': tempMax,
    'condition': condition,
    'description': description,
    'humidity': humidity,
    'pressure': pressure,
    'wind_speed_ms': windSpeedMs,
    'wind_speed_kmh': windSpeedKmh,
    'visibility_km': visibilityKm,
    'clouds': clouds,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

// Helper classes for backward compatibility
class FlightPerformance {
  final String? departurePunctuality;
  final String? arrivalPunctuality;
  final int? avgDelayMinutes;

  FlightPerformance({
    this.departurePunctuality,
    this.arrivalPunctuality,
    this.avgDelayMinutes,
  });
}

class FlightRoute {
  final RouteDistance? distance;
  FlightRoute({this.distance});
}


class FlightSearchModel {
  final String?          status;
  final String?          message;
  final FlightSearchData? data;

  FlightSearchModel({this.status, this.message, this.data});

  factory FlightSearchModel.fromJson(Map<String, dynamic> json) =>
      FlightSearchModel(
        status:  json['status']?.toString(),
        message: json['message']?.toString(),
        data: json['data'] is Map<String, dynamic>
            ? FlightSearchData.fromJson(json['data'])
            : null,
      );
}




class SearchFlightInformation {
  final String? carrierCode;
  final String? flightNumber;
  final String? fullFlightNumber;
  final bool? available;
  final String? scheduledDeparture;
  final String? scheduledArrival;
  final int? totalFlightsFound;
  final List<FlightItem>? allFlights; // ADD THIS

  SearchFlightInformation({
    this.carrierCode,
    this.flightNumber,
    this.fullFlightNumber,
    this.available,
    this.scheduledDeparture,
    this.scheduledArrival,
    this.totalFlightsFound,
    this.allFlights,
  });

  factory SearchFlightInformation.fromJson(Map<String, dynamic> json) {
    // Debug print
    debugPrint('=== SearchFlightInformation Parsing ===');
    debugPrint('all_flights exists: ${json.containsKey('all_flights')}');
    debugPrint('all_flights is List: ${json['all_flights'] is List}');

    // Safely parse all_flights
    List<FlightItem>? parsedFlights;
    try {
      if (json['all_flights'] != null && json['all_flights'] is List) {
        final flightsList = json['all_flights'] as List;
        debugPrint('all_flights count: ${flightsList.length}');

        parsedFlights = flightsList
            .whereType<Map<String, dynamic>>()
            .map((e) => FlightItem.fromJson(e))
            .toList();

        debugPrint('Successfully parsed ${parsedFlights.length} flights');
      }
    } catch (e, stackTrace) {
      debugPrint('Error parsing all_flights: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    return SearchFlightInformation(
      carrierCode: json['carrier_code']?.toString(),
      flightNumber: json['flight_number']?.toString(),
      fullFlightNumber: json['full_flight_number']?.toString(),
      available: json['available'] is bool
          ? json['available'] as bool
          : json['available']?.toString().toLowerCase() == 'true',
      scheduledDeparture: json['scheduled_departure']?.toString(),
      scheduledArrival: json['scheduled_arrival']?.toString(),
      totalFlightsFound: json['total_flights_found'] is int
          ? json['total_flights_found'] as int
          : int.tryParse(json['total_flights_found']?.toString() ?? ''),
      allFlights: parsedFlights,
    );
  }

  Map<String, dynamic> toJson() => {
    'carrier_code': carrierCode,
    'flight_number': flightNumber,
    'full_flight_number': fullFlightNumber,
    'available': available,
    'scheduled_departure': scheduledDeparture,
    'scheduled_arrival': scheduledArrival,
    'total_flights_found': totalFlightsFound,
    'all_flights': allFlights?.map((e) => e.toJson()).toList(),
  };
}

class SearchRouteInfo {
  final String? from;
  final String? to;
  final String? departureDate;
  final RouteDistance? distance;

  SearchRouteInfo({this.from, this.to, this.departureDate, this.distance});

  factory SearchRouteInfo.fromJson(Map<String, dynamic> json) =>
      SearchRouteInfo(
        from: json['from']?.toString(),
        to: json['to']?.toString(),
        departureDate: json['departure_date']?.toString(),
        distance: json['distance'] is Map<String, dynamic>
            ? RouteDistance.fromJson(json['distance'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'departure_date': departureDate,
    'distance': distance?.toJson(),
  };
}

class SearchArrivalWeather {
  final String? location;
  final double? temperature;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final String? condition;
  final String? description;
  final int? humidity;
  final int? pressure;
  final double? windSpeedMs;
  final double? windSpeedKmh;
  final double? visibilityKm;
  final int? clouds;

  SearchArrivalWeather({
    this.location,
    this.temperature,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.condition,
    this.description,
    this.humidity,
    this.pressure,
    this.windSpeedMs,
    this.windSpeedKmh,
    this.visibilityKm,
    this.clouds,
  });

  factory SearchArrivalWeather.fromJson(Map<String, dynamic> json) =>
      SearchArrivalWeather(
        location: json['location']?.toString(),
        temperature: _parseDouble(json['temperature']),
        feelsLike: _parseDouble(json['feels_like']),
        tempMin: _parseDouble(json['temp_min']),
        tempMax: _parseDouble(json['temp_max']),
        condition: json['condition']?.toString(),
        description: json['description']?.toString(),
        humidity: _parseInt(json['humidity']),
        pressure: _parseInt(json['pressure']),
        windSpeedMs: _parseDouble(json['wind_speed_ms']),
        windSpeedKmh: _parseDouble(json['wind_speed_kmh']),
        visibilityKm: _parseDouble(json['visibility_km']),
        clouds: _parseInt(json['clouds']),
      );

  Map<String, dynamic> toJson() => {
    'location': location,
    'temperature': temperature,
    'feels_like': feelsLike,
    'temp_min': tempMin,
    'temp_max': tempMax,
    'condition': condition,
    'description': description,
    'humidity': humidity,
    'pressure': pressure,
    'wind_speed_ms': windSpeedMs,
    'wind_speed_kmh': windSpeedKmh,
    'visibility_km': visibilityKm,
    'clouds': clouds,
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class SearchDepartureForecast {
  final double? punctualityPercentage;
  final double? avgDepartureDelayMinutes;
  final double? avgDepartureDelayHours;
  final SearchDelayCategories? delayCategories;
  final PastFlightsSummary? pastFlightsSummary;

  SearchDepartureForecast({
    this.punctualityPercentage,
    this.avgDepartureDelayMinutes,
    this.avgDepartureDelayHours,
    this.delayCategories,
    this.pastFlightsSummary,
  });

  factory SearchDepartureForecast.fromJson(Map<String, dynamic> json) =>
      SearchDepartureForecast(
        punctualityPercentage: _parseDouble(json['punctuality_percentage']),
        avgDepartureDelayMinutes:
        _parseDouble(json['avg_departure_delay_minutes']),
        avgDepartureDelayHours:
        _parseDouble(json['avg_departure_delay_hours']),
        delayCategories: json['delay_categories'] is Map<String, dynamic>
            ? SearchDelayCategories.fromJson(json['delay_categories'])
            : null,
        pastFlightsSummary:
        json['past_30_flights_summary'] is Map<String, dynamic>
            ? PastFlightsSummary.fromJson(json['past_30_flights_summary'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'punctuality_percentage': punctualityPercentage,
    'avg_departure_delay_minutes': avgDepartureDelayMinutes,
    'avg_departure_delay_hours': avgDepartureDelayHours,
    'delay_categories': delayCategories?.toJson(),
    'past_30_flights_summary': pastFlightsSummary?.toJson(),
  };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class SearchDelayCategories {
  final int? early;
  final int? onTime;
  final int? late30Min;
  final int? late60Min;
  final int? late90Min;
  final int? cancelled;

  SearchDelayCategories({
    this.early,
    this.onTime,
    this.late30Min,
    this.late60Min,
    this.late90Min,
    this.cancelled,
  });

  factory SearchDelayCategories.fromJson(Map<String, dynamic> json) =>
      SearchDelayCategories(
        early: _parseInt(json['early']),
        onTime: _parseInt(json['on_time']),
        late30Min: _parseInt(json['late_30_min']),
        late60Min: _parseInt(json['late_60_min']),
        late90Min: _parseInt(json['late_90_min']),
        cancelled: _parseInt(json['cancelled']),
      );

  Map<String, dynamic> toJson() => {
    'early': early,
    'on_time': onTime,
    'late_30_min': late30Min,
    'late_60_min': late60Min,
    'late_90_min': late90Min,
    'cancelled': cancelled,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class PastFlightsSummary {
  final int? total;
  final int? onTime;
  final int? delayed;
  final int? cancelled;

  PastFlightsSummary({this.total, this.onTime, this.delayed, this.cancelled});

  factory PastFlightsSummary.fromJson(Map<String, dynamic> json) =>
      PastFlightsSummary(
        total: _parseInt(json['total']),
        onTime: _parseInt(json['on_time']),
        delayed: _parseInt(json['delayed']),
        cancelled: _parseInt(json['cancelled']),
      );

  Map<String, dynamic> toJson() => {
    'total': total,
    'on_time': onTime,
    'delayed': delayed,
    'cancelled': cancelled,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class FlightInformation {
  final String? carrierCode;
  final String? flightNumber;
  final String? fullFlightNumber;
  final bool?   available;

  FlightInformation({
    this.carrierCode,
    this.flightNumber,
    this.fullFlightNumber,
    this.available,
  });

  factory FlightInformation.fromJson(Map<String, dynamic> json) =>
      FlightInformation(
        carrierCode:      json['carrier_code']?.toString(),
        flightNumber:     json['flight_number']?.toString(),
        fullFlightNumber: json['full_flight_number']?.toString(),
        available: json['available'] is bool
            ? json['available'] as bool
            : json['available']?.toString().toLowerCase() == 'true',
      );
}

// Add this new class for individual flight items
class FlightItem {
  final String? carrierCode;
  final String? flightNumber;
  final String? fullFlightNumber;
  final bool? available;
  final String? scheduledDeparture;
  final String? scheduledArrival;

  FlightItem({
    this.carrierCode,
    this.flightNumber,
    this.fullFlightNumber,
    this.available,
    this.scheduledDeparture,
    this.scheduledArrival,
  });

  factory FlightItem.fromJson(Map<String, dynamic> json) => FlightItem(
    carrierCode: json['carrier_code']?.toString(),
    flightNumber: json['flight_number']?.toString(),
    fullFlightNumber: json['full_flight_number']?.toString(),
    available: json['available'] is bool
        ? json['available'] as bool
        : json['available']?.toString().toLowerCase() == 'true',
    scheduledDeparture: json['scheduled_departure']?.toString(),
    scheduledArrival: json['scheduled_arrival']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'carrier_code': carrierCode,
    'flight_number': flightNumber,
    'full_flight_number': fullFlightNumber,
    'available': available,
    'scheduled_departure': scheduledDeparture,
    'scheduled_arrival': scheduledArrival,
  };

  // Helper to format time
  String get formattedDepartureTime {
    if (scheduledDeparture == null || scheduledDeparture!.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(scheduledDeparture!);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  String get formattedArrivalTime {
    if (scheduledArrival == null || scheduledArrival!.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(scheduledArrival!);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  // Calculate duration between departure and arrival
  String get duration {
    if (scheduledDeparture == null || scheduledArrival == null) return '--';
    try {
      final dep = DateTime.parse(scheduledDeparture!);
      final arr = DateTime.parse(scheduledArrival!);
      final diff = arr.difference(dep);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours == 0) return '${minutes}m';
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    } catch (_) {
      return '--';
    }
  }
}

class FlightSearchData {
  final SearchFlightInformation? flightInformation;
  final ResolvedLocations? resolvedLocations;
  final SearchRouteInfo? routeInfo;
  final SearchArrivalWeather? arrivalWeather;
  final SearchDepartureForecast? departureForecast;

  FlightSearchData({
    this.flightInformation,
    this.resolvedLocations,
    this.routeInfo,
    this.arrivalWeather,
    this.departureForecast,
  });

  factory FlightSearchData.fromJson(Map<String, dynamic> json) {
    debugPrint('=== FlightSearchData Parsing ===');
    debugPrint('Keys in data: ${json.keys.toList()}');

    return FlightSearchData(
      flightInformation: json['flight_information'] is Map<String, dynamic>
          ? SearchFlightInformation.fromJson(json['flight_information'])
          : null,
      resolvedLocations: json['resolved_locations'] is Map<String, dynamic>
          ? ResolvedLocations.fromJson(json['resolved_locations'])
          : null,
      routeInfo: json['route_info'] is Map<String, dynamic>
          ? SearchRouteInfo.fromJson(json['route_info'])
          : null,
      arrivalWeather: json['arrival_weather'] is Map<String, dynamic>
          ? SearchArrivalWeather.fromJson(json['arrival_weather'])
          : null,
      departureForecast: json['departure_forecast'] is Map<String, dynamic>
          ? SearchDepartureForecast.fromJson(json['departure_forecast'])
          : null,
    );
  }

  // Convenience getter to access allFlights
  List<FlightItem>? get allFlights => flightInformation?.allFlights;

  // Convenience getter for total flights count
  int get totalFlightsFound => flightInformation?.totalFlightsFound ?? allFlights?.length ?? 0;

  Map<String, dynamic> toJson() => {
    'flight_information': flightInformation?.toJson(),
    'resolved_locations': resolvedLocations?.toJson(),
    'route_info': routeInfo?.toJson(),
    'arrival_weather': arrivalWeather?.toJson(),
    'departure_forecast': departureForecast?.toJson(),
  };
}



class DepartureForecast {
  final double? punctualityPercentage;
  final double? avgDepartureDelayMinutes;
  final double? avgDepartureDelayHours;
  final DelayCategories?  delayCategories;
  final PastFlightsSummary? pastFlightsSummary;

  DepartureForecast({
    this.punctualityPercentage,
    this.avgDepartureDelayMinutes,
    this.avgDepartureDelayHours,
    this.delayCategories,
    this.pastFlightsSummary,
  });

  factory DepartureForecast.fromJson(Map<String, dynamic> json) =>
      DepartureForecast(
        punctualityPercentage:    _d(json['punctuality_percentage']),
        avgDepartureDelayMinutes: _d(json['avg_departure_delay_minutes']),
        avgDepartureDelayHours:   _d(json['avg_departure_delay_hours']),
        delayCategories: json['delay_categories'] is Map<String, dynamic>
            ? DelayCategories.fromJson(json['delay_categories'])
            : null,
        pastFlightsSummary:
        json['past_30_flights_summary'] is Map<String, dynamic>
            ? PastFlightsSummary.fromJson(json['past_30_flights_summary'])
            : null,
      );

  static double? _d(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());
}

class DelayCategories {
  final int? early;
  final int? onTime;
  final int? late30Min;
  final int? late60Min;
  final int? late90Min;
  final int? cancelled;

  DelayCategories({
    this.early,
    this.onTime,
    this.late30Min,
    this.late60Min,
    this.late90Min,
    this.cancelled,
  });

  factory DelayCategories.fromJson(Map<String, dynamic> json) =>
      DelayCategories(
        early:     _i(json['early']),
        onTime:    _i(json['on_time']),
        late30Min: _i(json['late_30_min']),
        late60Min: _i(json['late_60_min']),
        late90Min: _i(json['late_90_min']),
        cancelled: _i(json['cancelled']),
      );

  static int? _i(dynamic v) =>
      v == null ? null : int.tryParse(v.toString());
}

