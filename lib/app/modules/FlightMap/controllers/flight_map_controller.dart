import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../common/app_theme_controller.dart';
import '../../../common/flight_detail_service.dart';
import '../../../data/apis/api_models/flight_model.dart';
import '../../../data/services/flight_api_service.dart';

enum MapLoadState { initial, locating, ready, error }

// ── Isolate-safe polyline builder ─────────────────────────────────────────────
// Runs on a background isolate via compute(), zero UI thread impact.
class _PolylineInput {
  final List<List<double>> waypoints; // [[lat,lng], ...]
  final double aircraftLat;
  final double aircraftLng;
  final double arrivalLat;
  final double arrivalLng;
  final double departureLat;
  final double departureLng;

  const _PolylineInput({
    required this.waypoints,
    required this.aircraftLat,
    required this.aircraftLng,
    required this.arrivalLat,
    required this.arrivalLng,
    required this.departureLat,
    required this.departureLng,
  });
}

class _PolylineResult {
  final List<List<double>> fullPoints;

  const _PolylineResult({required this.fullPoints});
}

// Top-level function required by compute()
_PolylineResult _buildPolylinesInIsolate(_PolylineInput input) {
  final fullPath = _routeThroughAircraft(input);

  return _PolylineResult(fullPoints: _downsample(fullPath, 48));
}

List<List<double>> _routeThroughAircraft(_PolylineInput input) {
  final route = _routeWithEndpoints(input);
  final aircraft = [input.aircraftLat, input.aircraftLng];

  if (!_isValidPoint(aircraft)) return route;
  if (route.length < 2) return [aircraft, ...route];

  var closestIndex = 0;
  var closestDistance = double.infinity;
  for (var i = 0; i < route.length; i++) {
    final distance = _distSq(route[i], aircraft);
    if (distance < closestDistance) {
      closestDistance = distance;
      closestIndex = i;
    }
  }

  final anchored = <List<double>>[];
  for (var i = 0; i <= closestIndex && i < route.length; i++) {
    anchored.add(route[i]);
  }
  if (anchored.isEmpty || _distSq(anchored.last, aircraft) > 0.000001) {
    anchored.add(aircraft);
  }
  for (var i = closestIndex + 1; i < route.length; i++) {
    anchored.add(route[i]);
  }
  return anchored;
}

List<List<double>> _routeWithEndpoints(_PolylineInput input) {
  final departure = [input.departureLat, input.departureLng];
  final arrival = [input.arrivalLat, input.arrivalLng];
  final route = <List<double>>[];

  if (_isValidPoint(departure)) route.add(departure);
  for (final point in input.waypoints) {
    if (_isValidPoint(point) &&
        (route.isEmpty || _distSq(route.last, point) > 0.000001)) {
      route.add(point);
    }
  }
  if (_isValidPoint(arrival) &&
      (route.isEmpty || _distSq(route.last, arrival) > 0.000001)) {
    route.add(arrival);
  }
  return route;
}

List<List<double>> _downsample(List<List<double>> pts, int maxPts) {
  if (pts.length <= maxPts) return pts;
  final result = <List<double>>[];
  final last = pts.length - 1;
  for (int i = 0; i < maxPts; i++) {
    final index = ((i * last) / (maxPts - 1)).round();
    result.add(pts[index.clamp(0, last)]);
  }
  return result;
}

double _distSq(List<double> a, List<double> b) {
  final dLat = a[0] - b[0];
  final dLng = _lngDelta(a[1], b[1]);
  return dLat * dLat + dLng * dLng;
}

double _lngDelta(double a, double b) {
  final diff = (a - b).abs();
  return diff > 180 ? 360 - diff : diff;
}

bool _isValidPoint(List<double> p) =>
    p.length == 2 &&
    p[0] >= -90 &&
    p[0] <= 90 &&
    p[1] >= -180 &&
    p[1] <= 180 &&
    !(p[0] == 0 && p[1] == 0);

// ─────────────────────────────────────────────────────────────────────────────

class FlightController extends GetxController {
  final count = 0.obs;

  // ─── Services ──────────────────────────────────────────────────────────────
  final FlightApiService _apiService = FlightApiService();
  final FlightDetailService detailService = FlightDetailService();

  // ─── Observables ───────────────────────────────────────────────────────────
  final flights = <String, Flight>{}.obs;
  final markers = Rx<Set<Marker>>({});
  final polylines = Rx<Set<Polyline>>({});

  final selectedFlight = Rxn<Flight>();
  final selectedPopup = Rxn<FlightPopup>();
  final selectedRoute = Rxn<FlightRoute>();
  final routeFlight = Rxn<Flight>();
  final isLoadingPopup = false.obs;
  final isLoadingRoute = false.obs;

  final mapLoadState = MapLoadState.initial.obs;
  final isRefreshing = false.obs;
  final errorMessage = ''.obs;
  final flightCount = 0.obs;
  final lastUpdated = Rxn<DateTime>();

  // Stats
  final statsAirborne = 0.obs;
  final statsGround = 0.obs;
  final statsCountries = 0.obs;

  // Search
  final searchQuery = ''.obs;
  final isSearchOpen = false.obs;
  final searchController = TextEditingController();

  final isMiniMapMode = false.obs;

  // ─── Map state ─────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  LatLng _currentCenter = const LatLng(20.5937, 78.9629);
  double _currentZoom = 6.0;

  // ─── Internal ──────────────────────────────────────────────────────────────
  Timer? _refreshTimer;
  Timer? _debounceTimer;
  Timer? _markerDebounce;
  Timer? _polylineDebounce;

  BitmapDescriptor? _iconDark;
  BitmapDescriptor? _iconDarkSm;
  BitmapDescriptor? _iconDarkGround;
  BitmapDescriptor? _iconBright;
  BitmapDescriptor? _iconBrightSm;
  BitmapDescriptor? _iconBrightGround;
  BitmapDescriptor? _iconSelected;

  bool _isFetching = false;
  bool _isRebuildingMarkers = false;
  bool _isRebuildingPolylines = false;
  bool _needsPolylineRebuild = false;
  bool _isCameraMoving = false;
  String? _currentRouteCallsign;
  int _polylineBuildToken = 0;
  String? _lastPolylineKey;

  static const int _maxMarkers = 50;
  static const Duration _refreshInterval = Duration(seconds: 15);
  static const Duration _debounceDelay = Duration(milliseconds: 800);
  static const Duration _markerDebounceDelay = Duration(milliseconds: 100);
  static const Duration _polylineDebounceDelay = Duration(milliseconds: 200);

  AppThemeController get _theme => AppThemeController.to;
  bool get isDarkTheme => _theme.isDark;
  bool get _isRouteFocusMode =>
      routeFlight.value != null || isLoadingRoute.value;

  @override
  void onInit() {
    super.onInit();
    _init();
    ever(_theme.isDarkRx, (_) {
      if (mapController != null) _applyMapStyle(mapController!);
      _scheduleMarkerRebuild();
      _schedulePolylineRebuild();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    _markerDebounce?.cancel();
    _polylineDebounce?.cancel();
    _apiService.dispose();
    detailService.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _init() async {
    mapLoadState.value = MapLoadState.locating;
    await _preloadIcons();
    await _getUserLocation();
    mapLoadState.value = MapLoadState.ready;
    await fetchFlights();
    _startAutoRefresh();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));
      _currentCenter = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      log('[FlightController] Location error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAP CALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  void setMiniMapMode(bool mini) {
    isMiniMapMode.value = mini;
    if (mini) clearSelection();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _applyMapStyle(controller);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentCenter, zoom: _currentZoom),
      ),
    );
  }

  void onCameraMove(CameraPosition pos) {
    _isCameraMoving = true;
    _currentCenter = pos.target;
    _currentZoom = pos.zoom;
    _debounceTimer?.cancel();
  }

  void onCameraIdle() {
    _isCameraMoving = false;
    _debounceTimer?.cancel();
    if (_isRouteFocusMode) return;
    _debounceTimer = Timer(_debounceDelay, fetchFlights);
  }

  void toggleMapTheme() => _theme.toggle();
  void setMapThemeDark(bool dark) => _theme.setDark(dark);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  void openSearch() => isSearchOpen.value = true;

  void closeSearch() {
    isSearchOpen.value = false;
    searchQuery.value = '';
    searchController.clear();
    _scheduleMarkerRebuild();
  }

  void onSearchChanged(String q) {
    searchQuery.value = q.trim().toUpperCase();
    _scheduleMarkerRebuild();
  }

  void submitSearch(String query) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) return;
    final matches = flights.values.where((f) {
      return f.callsign.toUpperCase().contains(q) ||
          f.icao.toUpperCase().contains(q) ||
          f.registration.toUpperCase().contains(q);
    }).toList();
    if (matches.isNotEmpty) {
      selectFlight(matches.first);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(matches.first.latitude, matches.first.longitude),
          10,
        ),
      );
      closeSearch();
    } else {
      _setError('No aircraft matching "$q" found in current view.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA FETCHING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchFlights() async {
    if (_isFetching || _isRouteFocusMode) return;
    _isFetching = true;
    isRefreshing.value = true;
    errorMessage.value = '';

    try {
      final bounds = await _getVisibleBounds();
      final fetched = await _apiService.fetchFlights(
        lamin: bounds.southwest.latitude,
        lamax: bounds.northeast.latitude,
        lomin: bounds.southwest.longitude,
        lomax: bounds.northeast.longitude,
        limit: _maxMarkers,
      );

      if (_isRouteFocusMode) return;

      _updateFlightData(fetched);
      _scheduleMarkerRebuild();
      _updateStats();
      lastUpdated.value = DateTime.now();

      _refreshActiveRoutePosition();
    } on FlightApiException catch (e) {
      if (_isRouteFocusMode) return;
      _setError(e.message);
    } catch (e) {
      if (_isRouteFocusMode) return;
      _setError('Unexpected error occurred');
      log('[FlightController] Error: $e');
    } finally {
      _isFetching = false;
      isRefreshing.value = false;
    }
  }

  void _updateFlightData(List<Flight> fetched) {
    final map = {for (final f in fetched) f.icao: f};
    flights.removeWhere((k, _) => !map.containsKey(k));
    for (final f in fetched) {
      flights[f.icao] = f;
    }
    flightCount.value = flights.length;

    if (selectedFlight.value != null) {
      final updated = flights[selectedFlight.value!.icao];
      if (updated != null) {
        selectedFlight.value = updated;
      }
    }

    if (routeFlight.value != null) {
      final updated = flights[routeFlight.value!.icao];
      if (updated != null) {
        routeFlight.value = updated;
      }
    }
  }

  void _refreshActiveRoutePosition() {
    final flight = routeFlight.value;
    final route = selectedRoute.value;
    if (flight == null || route == null) return;

    final key = _polylineKey(flight, route);
    if (key != _lastPolylineKey) {
      _schedulePolylineRebuild();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARKERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _scheduleMarkerRebuild() {
    _markerDebounce?.cancel();
    _markerDebounce = Timer(_markerDebounceDelay, _rebuildMarkersAsync);
  }

  Future<void> _rebuildMarkersAsync() async {
    if (_isRebuildingMarkers) return;
    _isRebuildingMarkers = true;

    try {
      final flightList = flights.values.toList();
      final q = searchQuery.value;
      final selectedIcao =
          selectedFlight.value?.icao ?? routeFlight.value?.icao ?? '';
      final zoom = _currentZoom;
      final dark = isDarkTheme;

      var filtered = q.isNotEmpty
          ? flightList.where((f) {
              return f.callsign.toUpperCase().contains(q) ||
                  f.icao.toUpperCase().contains(q) ||
                  f.registration.toUpperCase().contains(q);
            }).toList()
          : flightList;

      filtered.sort((a, b) => b.altitudeFt.compareTo(a.altitudeFt));
      if (filtered.length > _maxMarkers) {
        filtered = filtered.take(_maxMarkers).toList();
      }

      final BitmapDescriptor normalIcon;
      final BitmapDescriptor smallIcon;
      final BitmapDescriptor groundIcon;
      final BitmapDescriptor selectedIcon;

      if (dark) {
        normalIcon = _iconDark ?? BitmapDescriptor.defaultMarker;
        smallIcon = _iconDarkSm ?? BitmapDescriptor.defaultMarker;
        groundIcon = _iconDarkGround ?? BitmapDescriptor.defaultMarker;
      } else {
        normalIcon = _iconBright ?? BitmapDescriptor.defaultMarker;
        smallIcon = _iconBrightSm ?? BitmapDescriptor.defaultMarker;
        groundIcon = _iconBrightGround ?? BitmapDescriptor.defaultMarker;
      }
      selectedIcon = _iconSelected ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

      final newMarkers = <Marker>{};
      for (final f in filtered) {
        final isSelected = f.icao == selectedIcao;

        BitmapDescriptor icon;
        if (isSelected) {
          icon = selectedIcon;
        } else if (f.onGround) {
          icon = groundIcon;
        } else if (zoom < 5) {
          icon = smallIcon;
        } else {
          icon = normalIcon;
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(f.icao),
            position: LatLng(f.latitude, f.longitude),
            icon: icon,
            rotation: f.heading,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            consumeTapEvents: true,
            onTap: () => selectFlight(f),
            zIndexInt:
                isSelected ? 999 : (f.altitudeFt / 100).clamp(0, 400).round(),
          ),
        );
      }

      markers.value = newMarkers;
    } finally {
      _isRebuildingMarkers = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLYLINES — memory-safe, isolate-backed
  // ═══════════════════════════════════════════════════════════════════════════

  void _schedulePolylineRebuild() {
    if (_isRebuildingPolylines) {
      _needsPolylineRebuild = true;
      return;
    }
    _polylineDebounce?.cancel();
    _polylineDebounce = Timer(_polylineDebounceDelay, _rebuildPolylinesAsync);
  }

  Future<void> _rebuildPolylinesAsync() async {
    final flight = routeFlight.value;
    final route = selectedRoute.value;

    if (flight == null || route == null) {
      polylines.value = {};
      _lastPolylineKey = null;
      return;
    }

    if (_isRebuildingPolylines) return;
    _isRebuildingPolylines = true;
    _needsPolylineRebuild = false;
    final token = ++_polylineBuildToken;

    try {
      final dark = isDarkTheme;
      final key = _polylineKey(flight, route);

      // Convert waypoints to plain List<List<double>> for isolate
      final List<List<double>> waypointData = route.waypoints
          .map((w) => [w.latitude, w.longitude])
          .toList(growable: false);

      final result = await compute(
        _buildPolylinesInIsolate,
        _PolylineInput(
          waypoints: waypointData,
          aircraftLat: flight.latitude,
          aircraftLng: flight.longitude,
          arrivalLat: route.arrival.latitude,
          arrivalLng: route.arrival.longitude,
          departureLat: route.departure.latitude,
          departureLng: route.departure.longitude,
        ),
      );

      if (token != _polylineBuildToken ||
          routeFlight.value?.icao != flight.icao ||
          selectedRoute.value != route ||
          _polylineKey(routeFlight.value!, route) != key) {
        _needsPolylineRebuild = true;
        return;
      }

      final fullLatLng = result.fullPoints
          .map((p) => LatLng(p[0], p[1]))
          .toList(growable: false);

      final newPolylines = <Polyline>{};

      if (fullLatLng.length >= 2) {
        newPolylines.add(Polyline(
          polylineId: const PolylineId('selected_route'),
          points: fullLatLng,
          color: dark ? const Color(0xFF64B5F6) : const Color(0xFF0D47A1),
          width: 4,
          geodesic: true,
          zIndex: 10,
        ));
      }

      polylines.value = newPolylines;
      _lastPolylineKey = key;
    } catch (e) {
      log('[FlightController] polyline build error: $e');
      polylines.value = {};
      _lastPolylineKey = null;
    } finally {
      _isRebuildingPolylines = false;
      if (_needsPolylineRebuild) {
        _schedulePolylineRebuild();
      }
    }
  }

  String _polylineKey(Flight flight, FlightRoute route) {
    final lat = (flight.latitude * 1000).round();
    final lng = (flight.longitude * 1000).round();
    return '${flight.icao}|$lat|$lng|${route.waypoints.length}|$isDarkTheme';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FLIGHT SELECTION
  // ═══════════════════════════════════════════════════════════════════════════

  void selectFlight(Flight flight) {
    if (isMiniMapMode.value) return;

    if (selectedFlight.value?.icao == flight.icao) return;

    _enterRouteFocusMode();
    _polylineDebounce?.cancel();
    _polylineBuildToken++;
    _lastPolylineKey = null;

    _currentRouteCallsign = flight.callsign;
    selectedFlight.value = flight;
    routeFlight.value = flight;
    selectedPopup.value = null;
    selectedRoute.value = null;
    isLoadingPopup.value = false;
    isLoadingRoute.value = false;

    polylines.value = {};

    mapController?.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(flight.latitude, flight.longitude),
        _currentZoom < 7 ? 8 : _currentZoom,
      ),
    );

    Future.microtask(_rebuildMarkersAsync);

    if (flight.callsign.isNotEmpty) {
      _loadRoute(flight.callsign);
    }
  }

  void _enterRouteFocusMode() {
    _debounceTimer?.cancel();
    _refreshTimer?.cancel();
    _apiService.cancelActiveRequests();
    _isFetching = false;
    isRefreshing.value = false;
  }

  Future<void> _loadRoute(String callsign) async {
    isLoadingRoute.value = true;
    try {
      final route = await detailService.getRoute(callsign);

      if (_currentRouteCallsign != callsign) return;

      selectedRoute.value = route;

      if (route != null && routeFlight.value != null) {
        _schedulePolylineRebuild();
      }
    } catch (e) {
      log('[FlightController] route error: $e');
    } finally {
      if (_currentRouteCallsign == callsign) {
        isLoadingRoute.value = false;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEAR SELECTION  ← called by sheet close button AND map tap
  // ═══════════════════════════════════════════════════════════════════════════

  void clearSelection() {
    _polylineDebounce?.cancel();
    _polylineBuildToken++;

    _currentRouteCallsign = null;
    selectedFlight.value = null;
    selectedPopup.value = null;
    selectedRoute.value = null;
    routeFlight.value = null;
    isLoadingPopup.value = false;
    isLoadingRoute.value = false;

    polylines.value = {};
    _lastPolylineKey = null;

    _scheduleMarkerRebuild();
    _startAutoRefresh();
  }

  void closeFlightSheet() {
    selectedFlight.value = null;
    selectedPopup.value = null;
    isLoadingPopup.value = false;
    _scheduleMarkerRebuild();
  }

  void clearSelectionForMiniMap() {
    if (selectedFlight.value != null || routeFlight.value != null) {
      clearSelection();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> centerOnUser() async {
    await _getUserLocation();
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentCenter, zoom: 7),
      ),
    );
    if (!_isRouteFocusMode) fetchFlights();
  }

  Future<void> manualRefresh() async {
    if (_isRouteFocusMode) return;
    _debounceTimer?.cancel();
    detailService.clearCache();
    await fetchFlights();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_isCameraMoving && !_isRouteFocusMode) fetchFlights();
    });
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    Future.delayed(const Duration(seconds: 4), () {
      if (errorMessage.value == msg) errorMessage.value = '';
    });
  }

  Future<LatLngBounds> _getVisibleBounds() async {
    if (mapController == null) return _fallbackBounds();
    try {
      return await mapController!.getVisibleRegion();
    } catch (_) {
      return _fallbackBounds();
    }
  }

  LatLngBounds _fallbackBounds() => LatLngBounds(
        southwest: LatLng(
          _currentCenter.latitude - 5,
          _currentCenter.longitude - 5,
        ),
        northeast: LatLng(
          _currentCenter.latitude + 5,
          _currentCenter.longitude + 5,
        ),
      );

  void _updateStats() {
    final list = flights.values.toList();
    statsAirborne.value = list.where((f) => !f.onGround).length;
    statsGround.value = list.where((f) => f.onGround).length;
    statsCountries.value = list
        .map((f) => f.airlineIcao)
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
  }

  LatLng get initialCameraPosition => _currentCenter;
  double get initialZoom => _currentZoom;

  void increment() => count.value++;

  // ═══════════════════════════════════════════════════════════════════════════
  // ICONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _preloadIcons() async {
    try {
      final results = await Future.wait([
        _makeIcon(
            48, const Color(0xFF0D47A1), Colors.white, Colors.white, false),
        _makeIcon(
            28, const Color(0xFF0D47A1), Colors.white, Colors.white, false),
        _makeIcon(
            36, const Color(0xFF37474F), Colors.white, Colors.white, true),
        _makeIcon(48, Colors.white, const Color(0xFF0D47A1),
            const Color(0xFF0D47A1), false),
        _makeIcon(28, Colors.white, const Color(0xFF0D47A1),
            const Color(0xFF0D47A1), false),
        _makeIcon(36, const Color(0xFFEEEEEE), const Color(0xFF37474F),
            const Color(0xFF37474F), true),
        _makeIcon(
            54, const Color(0xFF00C853), Colors.white, Colors.white, false),
      ]);
      _iconDark = results[0];
      _iconDarkSm = results[1];
      _iconDarkGround = results[2];
      _iconBright = results[3];
      _iconBrightSm = results[4];
      _iconBrightGround = results[5];
      _iconSelected = results[6];
    } catch (e) {
      log('[FlightController] Icon error: $e');
    }
  }

  Future<BitmapDescriptor> _makeIcon(
    int size,
    Color bg,
    Color plane,
    Color border,
    bool isGround,
  ) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final s = size.toDouble();

    canvas.drawCircle(
      Offset(s / 2 + 1, s / 2 + 1),
      s / 2.3,
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2.3, Paint()..color = bg);
    canvas.drawCircle(
      Offset(s / 2, s / 2),
      s / 2.3,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = size / 18,
    );

    final ps = isGround ? s * 0.32 : s * 0.40;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.drawPath(
      _buildAirplanePath(ps),
      Paint()
        ..color = plane
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    final pic = rec.endRecording();
    final img = await pic.toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Path _buildAirplanePath(double ps) {
    return Path()
      ..moveTo(0, -ps * 0.5)
      ..lineTo(ps * 0.12, ps * 0.3)
      ..lineTo(0, ps * 0.18)
      ..lineTo(-ps * 0.12, ps * 0.3)
      ..close()
      ..moveTo(-ps * 0.05, -ps * 0.05)
      ..lineTo(-ps * 0.48, ps * 0.16)
      ..lineTo(-ps * 0.42, ps * 0.26)
      ..lineTo(-ps * 0.05, ps * 0.10)
      ..close()
      ..moveTo(ps * 0.05, -ps * 0.05)
      ..lineTo(ps * 0.48, ps * 0.16)
      ..lineTo(ps * 0.42, ps * 0.26)
      ..lineTo(ps * 0.05, ps * 0.10)
      ..close()
      ..moveTo(-ps * 0.05, ps * 0.25)
      ..lineTo(-ps * 0.22, ps * 0.45)
      ..lineTo(-ps * 0.18, ps * 0.50)
      ..lineTo(-ps * 0.02, ps * 0.32)
      ..close()
      ..moveTo(ps * 0.05, ps * 0.25)
      ..lineTo(ps * 0.22, ps * 0.45)
      ..lineTo(ps * 0.18, ps * 0.50)
      ..lineTo(ps * 0.02, ps * 0.32)
      ..close();
  }

  void _applyMapStyle(GoogleMapController c) {
    c.setMapStyle(
      isDarkTheme
          ? AppThemeController.darkMapStyle
          : AppThemeController.brightMapStyle,
    );
  }
}
