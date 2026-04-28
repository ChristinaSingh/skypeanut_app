import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../common/app_theme_controller.dart';
import '../../../common/flight_detail_service.dart';
import '../../../data/apis/api_models/flight_model.dart';
import '../../../data/services/flight_api_service.dart';

enum MapLoadState { initial, locating, ready, error }

class FlightController extends GetxController {
  final count = 0.obs;

  // ─── Services ──────────────────────────────────────────────────────────────
  final FlightApiService _apiService = FlightApiService();
  final FlightDetailService detailService = FlightDetailService();

  // ─── Observables ───────────────────────────────────────────────────────────
  final flights = <String, Flight>{}.obs;
  final markers = Rx<Set<Marker>>({});

  final selectedFlight = Rxn<Flight>();
  final selectedPopup = Rxn<FlightPopup>();
  final isLoadingPopup = false.obs;

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

  BitmapDescriptor? _iconDark;
  BitmapDescriptor? _iconDarkSm;
  BitmapDescriptor? _iconDarkGround;
  BitmapDescriptor? _iconBright;
  BitmapDescriptor? _iconBrightSm;
  BitmapDescriptor? _iconBrightGround;
  BitmapDescriptor? _iconSelected;

  bool _isFetching = false;
  bool _isRebuildingMarkers = false;
  String? _currentSelectedCallsign;

  static const int _maxMarkers = 300;
  static const Duration _refreshInterval = Duration(seconds: 5);
  static const Duration _debounceDelay = Duration(milliseconds: 600);
  static const Duration _markerDebounceDelay = Duration(milliseconds: 100);

  AppThemeController get _theme => AppThemeController.to;
  bool get isDarkTheme => _theme.isDark;

  @override
  void onInit() {
    super.onInit();
    _init();
    ever(_theme.isDarkRx, (_) {
      if (mapController != null) _applyMapStyle(mapController!);
      _scheduleMarkerRebuild();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    _markerDebounce?.cancel();
    _apiService.dispose();
    detailService.dispose();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }

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
    _currentCenter = pos.target;
    _currentZoom = pos.zoom;
    _debounceTimer?.cancel();
  }

  void onCameraIdle() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, fetchFlights);
  }

  void toggleMapTheme() => _theme.toggle();
  void setMapThemeDark(bool dark) => _theme.setDark(dark);

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

  Future<void> fetchFlights() async {
    if (_isFetching) return;
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

      _updateFlightData(fetched);
      _scheduleMarkerRebuild();
      _updateStats();
      lastUpdated.value = DateTime.now();
    } on FlightApiException catch (e) {
      _setError(e.message);
    } catch (e) {
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
  }

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
      final selectedIcao = selectedFlight.value?.icao ?? '';
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
            zIndex: isSelected ? 999.0 : (f.altitudeFt / 100).clamp(0, 400),
          ),
        );
      }

      markers.value = newMarkers;
    } finally {
      _isRebuildingMarkers = false;
    }
  }

  // ─── Only popup/details on tap ─────────────────────────────────────────────
  void selectFlight(Flight flight) {
    if (isMiniMapMode.value) return;
    if (selectedFlight.value?.icao == flight.icao) return;

    _currentSelectedCallsign = flight.callsign;
    selectedFlight.value = flight;
    selectedPopup.value = null;
    isLoadingPopup.value = false;

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(flight.latitude, flight.longitude),
        _currentZoom < 7 ? 8 : _currentZoom,
      ),
    );

    Future.microtask(_rebuildMarkersAsync);

    if (flight.callsign.isNotEmpty) {
      _loadPopup(flight.callsign);
    }
  }

  Future<void> _loadPopup(String callsign) async {
    isLoadingPopup.value = true;

    try {
      final popup = await detailService.getPopup(callsign);

      // prevent stale response if user tapped another flight
      if (_currentSelectedCallsign != callsign) return;

      selectedPopup.value = popup;
    } catch (e) {
      log('[FlightController] popup error: $e');
    } finally {
      if (_currentSelectedCallsign == callsign) {
        isLoadingPopup.value = false;
      }
    }
  }

  void clearSelection() {
    _currentSelectedCallsign = null;
    selectedFlight.value = null;
    selectedPopup.value = null;
    isLoadingPopup.value = false;
    _scheduleMarkerRebuild();
  }

  void clearSelectionForMiniMap() {
    if (selectedFlight.value != null) clearSelection();
  }

  Future<void> centerOnUser() async {
    await _getUserLocation();
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentCenter, zoom: 7),
      ),
    );
    fetchFlights();
  }

  Future<void> manualRefresh() async {
    _debounceTimer?.cancel();
    detailService.clearCache();
    await fetchFlights();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => fetchFlights());
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
    southwest:
    LatLng(_currentCenter.latitude - 5, _currentCenter.longitude - 5),
    northeast:
    LatLng(_currentCenter.latitude + 5, _currentCenter.longitude + 5),
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

  Future<void> _preloadIcons() async {
    try {
      final results = await Future.wait([
        _makeIcon(48, const Color(0xFF0D47A1), Colors.white, Colors.white, false),
        _makeIcon(28, const Color(0xFF0D47A1), Colors.white, Colors.white, false),
        _makeIcon(36, const Color(0xFF37474F), Colors.white, Colors.white, true),
        _makeIcon(48, Colors.white, const Color(0xFF0D47A1), const Color(0xFF0D47A1), false),
        _makeIcon(28, Colors.white, const Color(0xFF0D47A1), const Color(0xFF0D47A1), false),
        _makeIcon(36, const Color(0xFFEEEEEE), const Color(0xFF37474F), const Color(0xFF37474F), true),
        _makeIcon(54, const Color(0xFF00C853), Colors.white, Colors.white, false),
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

  void increment() => count.value++;
}