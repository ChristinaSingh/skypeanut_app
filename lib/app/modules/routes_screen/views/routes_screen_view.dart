// ─────────────────────────────────────────────────────────────────────────────
// flight_status_screen_view.dart  (COMPLETE WORKING VERSION)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/app_theme_controller.dart';
import '../../../common/colors.dart';
import '../../../routes/app_pages.dart';
import '../../../data/apis/api_models/get_find_routes_model.dart';
import '../../FlightMap/controllers/flight_map_controller.dart';
import '../../FlightMap/views/flight_map_view.dart';
import '../controllers/routes_screen_controller.dart';

// ── Light-theme palette constants ────────────────────────────────────────────
const primaryColor = Color(0xFF3949AB);
const primaryColorDark = Color(0xFF1A237E);
const _kTextMain = Color(0xFF1C2340);
const _kTextSub = Color(0xFF607D8B);
const _kTextHint = Color(0xFFB0BEC5);
const _kDivider = Color(0xFFECEFF1);
const _kShadow = Color(0x14000000);

// ─────────────────────────────────────────────────────────────────────────────
class FlightStatusScreenView extends GetView<FlightStatusScreenController> {
  const FlightStatusScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<FlightStatusScreenController>(
            () => FlightStatusScreenController());
    Get.lazyPut<FlightController>(() => FlightController());
    Get.lazyPut<AppThemeController>(() => AppThemeController());

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _SearchCard(controller: controller),
                      const SizedBox(height: 20),
                      Obx(() {
                        if (controller.inAsyncCall.value) {
                          return const _LoadingCard();
                        }
                        if (controller.errorMessage.value.isNotEmpty) {
                          return _ErrorCard(
                              message: controller.errorMessage.value);
                        }
                        if (controller.resultType.value ==
                            ResultType.flightStatus &&
                            controller.flightStatusResult.value != null) {
                          return _FlightStatusResultCard(
                            model: controller.flightStatusResult.value!,
                            controller: controller,
                          );
                        }
                        if (controller.resultType.value ==
                            ResultType.flightSearch &&
                            controller.flightSearchResult.value != null) {
                          return _FlightSearchResultCard(
                            model: controller.flightSearchResult.value!,
                            controller: controller,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: primary3Color,
        boxShadow: [
          BoxShadow(color: _kShadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Flight Status',
            style: TextStyle(
              color: _kTextMain,
              fontWeight: FontWeight.w800,
              fontSize: 19.px,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.FLIGHT_MAP),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text('Live Map',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.px,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SEARCH CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _SearchCard extends StatelessWidget {
  final FlightStatusScreenController controller;

  const _SearchCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => _TabRow(
            selectedIndex: controller.selectedTabIndex.value,
            onTab: (i) => controller.selectedTabIndex.value = i,
          )),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: controller.selectedTabIndex.value == 0
                ? _FlightNoTab(
                controller: controller, key: const ValueKey('fn'))
                : _RouteTab(
                controller: controller, key: const ValueKey('rt')),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Departure date',
                    style: TextStyle(color: _kTextSub, fontSize: 12.px)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate:
                      DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme:
                          const ColorScheme.light(primary: primaryColor),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) controller.selectedDate.value = picked;
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined,
                            color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Obx(() => Text(
                          controller.formattedDateLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.px,
                            color: primaryColorDark,
                          ),
                        )),
                        const Spacer(),
                        const Icon(Icons.expand_more,
                            color: _kTextSub, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: _kDivider, height: 1),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Obx(() => GestureDetector(
              onTap: controller.inAsyncCall.value
                  ? null
                  : () {
                FocusScope.of(context).unfocus();
                controller.selectedTabIndex.value == 0
                    ? controller.checkByFlightNumber()
                    : controller.checkByRoute();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: controller.inAsyncCall.value
                        ? [
                      primaryColor.withOpacity(0.5),
                      const Color(0xFF5C6BC0).withOpacity(0.5)
                    ]
                        : [primaryColor, const Color(0xFF5C6BC0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: controller.inAsyncCall.value
                      ? []
                      : [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: controller.inAsyncCall.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    controller.selectedTabIndex.value == 0
                        ? 'Check Flight Status'
                        : 'Search Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.px,
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  TAB ROW
// ═══════════════════════════════════════════════════════════════════════════════
class _TabRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTab;

  const _TabRow({required this.selectedIndex, required this.onTab});

  @override
  Widget build(BuildContext context) =>
      Row(children: [_tab('Flight No.', 0), _tab('Route', 1)]);

  Widget _tab(String label, int idx) {
    final active = selectedIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTab(idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? primaryColor : _kDivider,
                width: active ? 2.5 : 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? primaryColor : _kTextSub,
                fontSize: 14.px,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  FLIGHT NO. TAB
// ═══════════════════════════════════════════════════════════════════════════════
class _FlightNoTab extends StatelessWidget {
  final FlightStatusScreenController controller;

  const _FlightNoTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flight number',
              style: TextStyle(color: _kTextSub, fontSize: 12.px)),
          const SizedBox(height: 6),
          TextField(
            controller: controller.flightNumberController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.px,
              color: _kTextMain,
              letterSpacing: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. AI2981',
              hintStyle: TextStyle(
                color: _kTextHint,
                fontSize: 16.px,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.confirmation_number_outlined,
                    color: primaryColor, size: 20),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ROUTE TAB
// ═══════════════════════════════════════════════════════════════════════════════
class _RouteTab extends StatelessWidget {
  final FlightStatusScreenController controller;

  const _RouteTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From',
                        style: TextStyle(color: _kTextSub, fontSize: 11.px)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller.fromController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24.px,
                        color: _kTextMain,
                        letterSpacing: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'DEL',
                        hintStyle: TextStyle(
                            fontSize: 24.px,
                            fontWeight: FontWeight.w800,
                            color: _kTextHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                    Text('City or IATA code',
                        style: TextStyle(color: _kTextHint, fontSize: 10.px)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: GestureDetector(
                  onTap: () {
                    final tmp = controller.fromController.text;
                    controller.fromController.text =
                        controller.toController.text;
                    controller.toController.text = tmp;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.08),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.swap_horiz,
                        color: primaryColor, size: 18),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('To',
                        style: TextStyle(color: _kTextSub, fontSize: 11.px)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller.toController,
                      textAlign: TextAlign.end,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24.px,
                        color: _kTextMain,
                        letterSpacing: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'BOM',
                        hintStyle: TextStyle(
                            fontSize: 24.px,
                            fontWeight: FontWeight.w800,
                            color: _kTextHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                    Text('City or IATA code',
                        style: TextStyle(color: _kTextHint, fontSize: 10.px)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  LOADING CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return _card(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5),
            SizedBox(height: 12),
            Text('Fetching flight data…',
                style: TextStyle(color: _kTextSub, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ERROR CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  FLIGHT STATUS RESULT CARD (Using correct API response structure)
// ═══════════════════════════════════════════════════════════════════════════════
class _FlightStatusResultCard extends StatelessWidget {
  final FlightStatusModel model;
  final FlightStatusScreenController controller;

  const _FlightStatusResultCard({
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final data = model.data!;
    final info = data.flightInfo;
    final resolvedLoc = data.resolvedLocations;
    final route = data.routeInfo;
    final aircraft = data.aircraft;
    final forecast = data.departureForecast;
    final weather = data.arrivalWeather;

    return Column(
      children: [
        // ── Flight Header ────────────────────────────────────────────
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info?.flightNumber ?? '--',
                        style: TextStyle(
                          color: _kTextMain,
                          fontSize: 24.px,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (aircraft?.aircraftType != null)
                        Text(
                          aircraft!.aircraftType!,
                          style: TextStyle(color: _kTextSub, fontSize: 11.px),
                        ),
                    ],
                  ),
                  const Spacer(),
                  _lBadge(
                    info?.status ?? 'Unknown',
                    controller.statusColor(info?.status),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Route visualization using resolved locations
              Row(
                children: [
                  _lEndpoint(
                    resolvedLoc?.from?.airportCode,
                    resolvedLoc?.from?.city,
                    null,
                    null,
                    CrossAxisAlignment.start,
                    TextAlign.start,
                  ),
                  _lFlightArc(
                    controller.formatDuration(
                        route?.distance?.estimatedFlightTimeMinutes),
                    route?.distance?.distanceKm,
                  ),
                  _lEndpoint(
                    resolvedLoc?.to?.airportCode,
                    resolvedLoc?.to?.city,
                    null,
                    null,
                    CrossAxisAlignment.end,
                    TextAlign.end,
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: _kDivider, height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      resolvedLoc?.from?.name ??
                          resolvedLoc?.from?.airportName ??
                          '',
                      style: TextStyle(color: _kTextSub, fontSize: 11.px),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      resolvedLoc?.to?.name ??
                          resolvedLoc?.to?.airportName ??
                          '',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: _kTextSub, fontSize: 11.px),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Live Map Preview ─────────────────────────────────────────
        const SizedBox(height: 14),
        _buildMapPreview(controller),

        // ── Route Details ────────────────────────────────────────────
        if (route?.distance != null) ...[
          const SizedBox(height: 14),
          _buildRouteDetailsCard(route!.distance!, controller),
        ],

        // ── Aircraft Details ─────────────────────────────────────────
        if (aircraft != null) ...[
          const SizedBox(height: 14),
          _buildAircraftCard(aircraft),
        ],

        // ── Departure Forecast ───────────────────────────────────────
        if (forecast != null) ...[
          const SizedBox(height: 14),
          _buildDepartureForecastCard(forecast, controller),
        ],

        // ── Arrival Weather ──────────────────────────────────────────
        if (weather != null) ...[
          const SizedBox(height: 14),
          _buildStatusWeatherCard(weather),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  FLIGHT SEARCH RESULT CARD
class _FlightSearchResultCard extends StatelessWidget {
  final FlightSearchModel model;
  final FlightStatusScreenController controller;

  const _FlightSearchResultCard({
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final data = model.data!;
    final fi = data.flightInformation;
    final loc = data.resolvedLocations;
    final route = data.routeInfo;
    final weather = data.arrivalWeather;
    final forecast = data.departureForecast;

    // Access allFlights from flightInformation
    final allFlights = fi?.allFlights ?? [];
    final totalFlights = fi?.totalFlightsFound ?? allFlights.length;

    // Debug print
    debugPrint('=== UI Rendering ===');
    debugPrint('flightInformation is null: ${fi == null}');
    debugPrint('allFlights count: ${allFlights.length}');
    debugPrint('totalFlightsFound: $totalFlights');

    return Column(
      children: [
        // ── Route Header Card ─────────────────────────────────────────
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc?.from?.airportCode ?? '--'} → ${loc?.to?.airportCode ?? '--'}',
                        style: TextStyle(
                          color: _kTextMain,
                          fontSize: 20.px,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      if (route?.departureDate != null)
                        Text(
                          route!.departureDate!,
                          style: TextStyle(color: _kTextSub, fontSize: 11.px),
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Show flight count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$totalFlights Flights',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _lEndpoint(
                    loc?.from?.airportCode,
                    loc?.from?.city,
                    null,
                    null,
                    CrossAxisAlignment.start,
                    TextAlign.start,
                  ),
                  _lFlightArc(
                    controller.formatDuration(
                        route?.distance?.estimatedFlightTimeMinutes),
                    route?.distance?.distanceKm,
                  ),
                  _lEndpoint(
                    loc?.to?.airportCode,
                    loc?.to?.city,
                    null,
                    null,
                    CrossAxisAlignment.end,
                    TextAlign.end,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: _kDivider, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc?.from?.airportName ?? '',
                      style: TextStyle(color: _kTextSub, fontSize: 11.px),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      loc?.to?.airportName ?? '',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: _kTextSub, fontSize: 11.px),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── All Flights List ──────────────────────────────────────────
        const SizedBox(height: 14),
        _AllFlightsCard(
          flights: allFlights,
          controller: controller,
          fromCode: loc?.from?.airportCode,
          toCode: loc?.to?.airportCode,
        ),

        // ── Map Preview ───────────────────────────────────────────────
        const SizedBox(height: 14),
        _buildMapPreview(controller),

        // ── Departure Forecast ────────────────────────────────────────
        if (forecast != null) ...[
          const SizedBox(height: 14),
          _buildSearchForecastCard(forecast, controller),
        ],

        // ── Arrival Weather ───────────────────────────────────────────
        if (weather != null) ...[
          const SizedBox(height: 14),
          _buildSearchWeatherCard(weather),
        ],
      ],
    );
  }
}


class _AllFlightsCard extends StatefulWidget {
  final List<FlightItem> flights;
  final FlightStatusScreenController controller;
  final String? fromCode;
  final String? toCode;

  const _AllFlightsCard({
    required this.flights,
    required this.controller,
    this.fromCode,
    this.toCode,
  });

  @override
  State<_AllFlightsCard> createState() => _AllFlightsCardState();
}

class _AllFlightsCardState extends State<_AllFlightsCard> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('_AllFlightsCard building with ${widget.flights.length} flights');

    // Handle empty flights
    if (widget.flights.isEmpty) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lSectionTitle('Available Flights'),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    color: Color(0xFFFF8F00),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No flights found for this route',
                    style: TextStyle(
                      color: const Color(0xFFE65100),
                      fontSize: 13.px,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try a different date or route',
                    style: TextStyle(
                      color: _kTextSub,
                      fontSize: 11.px,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show first 3 flights initially, or all if _showAll is true
    final displayFlights = _showAll
        ? widget.flights
        : widget.flights.take(3).toList();
    final hasMore = widget.flights.length > 3;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _lSectionTitle('Available Flights'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.flights.length} found',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontSize: 11.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Flight list using Column instead of ListView for nested scroll
          ...displayFlights.asMap().entries.map((entry) {
            final index = entry.key;
            final flight = entry.value;
            return Column(
              children: [
                if (index > 0)
                  const Divider(color: _kDivider, height: 1),
                _FlightListItem(
                  flight: flight,
                  controller: widget.controller,
                  fromCode: widget.fromCode,
                  toCode: widget.toCode,
                ),
              ],
            );
          }),

          // Show more/less button
          if (hasMore) ...[
            const SizedBox(height: 8),
            const Divider(color: _kDivider, height: 1),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAll = !_showAll;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showAll
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showAll
                          ? 'Show Less'
                          : 'Show ${widget.flights.length - 3} More Flights',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPER CARD BUILDERS
// ═══════════════════════════════════════════════════════════════════════════════

Widget _buildRouteDetailsCard(
    RouteDistance dist, FlightStatusScreenController controller) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('Route Details'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _lRouteStat(
              Icons.straighten,
              '${dist.distanceKm?.toStringAsFixed(0) ?? '--'} km',
              'Distance',
            ),
            _lRouteStat(
              Icons.public,
              '${dist.distanceNm?.toStringAsFixed(0) ?? '--'} nm',
              'Nautical Miles',
            ),
            _lRouteStat(
              Icons.timer_outlined,
              controller.formatDuration(dist.estimatedFlightTimeMinutes),
              'Est. Time',
            ),
            _lRouteStat(
              Icons.explore_outlined,
              '${dist.bearingDegrees?.toStringAsFixed(1) ?? '--'}°',
              'Bearing',
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildAircraftCard(StatusAircraft aircraft) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('Aircraft Information'),
        const SizedBox(height: 14),
        _aircraftDetailRow('Type', aircraft.aircraftType ?? 'Unknown'),
        if (aircraft.manufacturer != null)
          _aircraftDetailRow('Manufacturer', aircraft.manufacturer!),
        if (aircraft.model != null) _aircraftDetailRow('Model', aircraft.model!),
        if (aircraft.registration != null)
          _aircraftDetailRow('Registration', aircraft.registration!),
      ],
    ),
  );
}

Widget _aircraftDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: _kTextSub,
              fontSize: 12.px,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: _kTextMain,
              fontSize: 13.px,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDepartureForecastCard(
    StatusDepartureForecast forecast, FlightStatusScreenController controller) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('On-Time Performance'),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller
                    .punctualityColor(forecast.departurePunctuality?.toDouble())
                    .withOpacity(0.1),
                border: Border.all(
                  color: controller.punctualityColor(
                      forecast.departurePunctuality?.toDouble()),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${forecast.departurePunctuality?.toString() ?? '--'}%',
                  style: TextStyle(
                    color: controller.punctualityColor(
                        forecast.departurePunctuality?.toDouble()),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.px,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Departure Punctuality',
                      style: TextStyle(
                          color: _kTextMain,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.px)),
                  const SizedBox(height: 4),
                  Text(
                    'Avg delay: ${forecast.avgDelayMinutes?.toString() ?? '--'} min',
                    style: TextStyle(color: _kTextSub, fontSize: 12.px),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (forecast.delayDistribution != null) ...[
          const SizedBox(height: 18),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 14),
          Text('Delay Distribution',
              style: TextStyle(
                  color: _kTextSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.px)),
          const SizedBox(height: 10),
          _delayRow('Early', forecast.delayDistribution!.early, Colors.teal),
          _delayRow('On Time', forecast.delayDistribution!.onTime,
              const Color(0xFF4CAF50)),
          _delayRow('< 30 min late', forecast.delayDistribution!.late030Mins,
              const Color(0xFFFF9800)),
          _delayRow('< 60 min late', forecast.delayDistribution!.late3060Mins,
              const Color(0xFFFF5722)),
          _delayRow('< 90 min late', forecast.delayDistribution!.late6090Mins,
              const Color(0xFFF44336)),
          _delayRow('> 90 min late', forecast.delayDistribution!.lateOver90Mins,
              const Color(0xFFD32F2F)),
          _delayRow('Cancelled', forecast.delayDistribution!.cancelled,
              const Color(0xFF9E9E9E)),
        ],
        if (forecast.last30Flights != null) ...[
          const SizedBox(height: 14),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 14),
          Text('Last 30 Flights',
              style: TextStyle(
                  color: _kTextSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.px)),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniStat(
                  'Total', '${forecast.last30Flights!.total ?? 0}', _kTextMain),
              _miniStat('On Time', '${forecast.last30Flights!.onTime ?? 0}',
                  const Color(0xFF4CAF50)),
              _miniStat('Delayed', '${forecast.last30Flights!.delayed ?? 0}',
                  const Color(0xFFFF9800)),
              _miniStat('Cancelled', '${forecast.last30Flights!.cancelled ?? 0}',
                  const Color(0xFFF44336)),
            ],
          ),
        ],
      ],
    ),
  );
}

class _FlightListItem extends StatelessWidget {
  final FlightItem flight;
  final FlightStatusScreenController controller;
  final String? fromCode;
  final String? toCode;

  const _FlightListItem({
    required this.flight,
    required this.controller,
    this.fromCode,
    this.toCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Flight number and carrier
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flight.fullFlightNumber ?? '--',
                  style: TextStyle(
                    color: primaryColorDark,
                    fontSize: 16.px,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: flight.available == true
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      flight.available == true ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: flight.available == true
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        fontSize: 10.px,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time details
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      flight.formattedDepartureTime,
                      style: TextStyle(
                        color: _kTextMain,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      fromCode ?? 'DEP',
                      style: TextStyle(
                        color: _kTextSub,
                        fontSize: 8.px,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        flight.duration,
                        style: TextStyle(
                          color: _kTextSub,
                          fontSize: 8.px,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _kTextHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 1,
                            color: _kTextHint,
                          ),
                          const Icon(
                            Icons.flight,
                            color: primaryColor,
                            size: 12,
                          ),
                          Container(
                            width: 18,
                            height: 1,
                            color: _kTextHint,
                          ),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _kTextHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      flight.formattedArrivalTime,
                      style: TextStyle(
                        color: _kTextMain,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      toCode ?? 'ARR',
                      style: TextStyle(
                        color: _kTextSub,
                        fontSize: 8.px,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Check status button
          GestureDetector(
            onTap: () {
              if (flight.fullFlightNumber != null &&
                  flight.fullFlightNumber!.isNotEmpty) {
                controller
                    .checkStatusForSearchedFlight(flight.fullFlightNumber!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.px,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSearchForecastCard(
    SearchDepartureForecast forecast, FlightStatusScreenController controller) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('Departure Forecast'),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller
                    .punctualityColor(forecast.punctualityPercentage)
                    .withOpacity(0.1),
                border: Border.all(
                  color: controller
                      .punctualityColor(forecast.punctualityPercentage),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${forecast.punctualityPercentage?.toStringAsFixed(0) ?? '--'}%',
                  style: TextStyle(
                    color: controller
                        .punctualityColor(forecast.punctualityPercentage),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.px,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('On-Time Punctuality',
                      style: TextStyle(
                          color: _kTextMain,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.px)),
                  const SizedBox(height: 4),
                  Text(
                    'Avg delay: ${forecast.avgDepartureDelayMinutes?.toStringAsFixed(0) ?? '--'} min',
                    style: TextStyle(color: _kTextSub, fontSize: 12.px),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (forecast.delayCategories != null) ...[
          const SizedBox(height: 18),
          Text('Delay Breakdown',
              style: TextStyle(
                  color: _kTextSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.px)),
          const SizedBox(height: 10),
          _delayRow('Early', forecast.delayCategories!.early, Colors.teal),
          _delayRow('On Time', forecast.delayCategories!.onTime,
              const Color(0xFF4CAF50)),
          _delayRow('< 30 min late', forecast.delayCategories!.late30Min,
              const Color(0xFFFF9800)),
          _delayRow('< 60 min late', forecast.delayCategories!.late60Min,
              const Color(0xFFFF5722)),
          _delayRow('< 90 min late', forecast.delayCategories!.late90Min,
              const Color(0xFFF44336)),
          _delayRow('Cancelled', forecast.delayCategories!.cancelled,
              const Color(0xFFD32F2F)),
        ],
        if (forecast.pastFlightsSummary != null) ...[
          const SizedBox(height: 14),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 14),
          Text('Past 30 Flights',
              style: TextStyle(
                  color: _kTextSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.px)),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniStat('Total',
                  '${forecast.pastFlightsSummary!.total ?? 0}', _kTextMain),
              _miniStat(
                  'On Time',
                  '${forecast.pastFlightsSummary!.onTime ?? 0}',
                  const Color(0xFF4CAF50)),
              _miniStat(
                  'Delayed',
                  '${forecast.pastFlightsSummary!.delayed ?? 0}',
                  const Color(0xFFFF9800)),
              _miniStat(
                  'Cancelled',
                  '${forecast.pastFlightsSummary!.cancelled ?? 0}',
                  const Color(0xFFF44336)),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildStatusWeatherCard(StatusArrivalWeather w) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('Arrival Weather — ${w.location ?? ''}'),
        const SizedBox(height: 14),
        Row(
          children: [
            _weatherIcon(w.condition),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.temperature?.toStringAsFixed(1) ?? '--'}°C',
                  style: TextStyle(
                    color: _kTextMain,
                    fontSize: 28.px,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(w.description ?? '',
                    style: TextStyle(
                        color: _kTextSub,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _weatherDetail(
                    Icons.water_drop_outlined, '${w.humidity ?? '--'}%'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.air,
                    '${w.windSpeedKmh?.toStringAsFixed(0) ?? '--'} km/h'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.visibility_outlined,
                    '${w.visibilityKm?.toStringAsFixed(1) ?? '--'} km'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.thermostat_outlined,
                    'Feels ${w.feelsLike?.toStringAsFixed(0) ?? '--'}°C'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSearchWeatherCard(SearchArrivalWeather w) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lSectionTitle('Arrival Weather — ${w.location ?? ''}'),
        const SizedBox(height: 14),
        Row(
          children: [
            _weatherIcon(w.condition),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.temperature?.toStringAsFixed(1) ?? '--'}°C',
                  style: TextStyle(
                    color: _kTextMain,
                    fontSize: 28.px,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(w.description ?? '',
                    style: TextStyle(
                        color: _kTextSub,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _weatherDetail(
                    Icons.water_drop_outlined, '${w.humidity ?? '--'}%'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.air,
                    '${w.windSpeedKmh?.toStringAsFixed(0) ?? '--'} km/h'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.visibility_outlined,
                    '${w.visibilityKm?.toStringAsFixed(1) ?? '--'} km'),
                const SizedBox(height: 6),
                _weatherDetail(Icons.thermostat_outlined,
                    'Feels ${w.feelsLike?.toStringAsFixed(0) ?? '--'}°C'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  MAP PREVIEW
// ═══════════════════════════════════════════════════════════════════════════════
Widget _buildMapPreview(FlightStatusScreenController controller) {
  return Column(
    children: [
      Container(
        height: 200,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const _MiniMapWrapper(),
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => Get.toNamed(Routes.FLIGHT_MAP),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: primary3Color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primaryColor.withOpacity(0.25)),
            boxShadow: const [
              BoxShadow(
                color: _kShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.open_in_full, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Open Full-Screen Live Map',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.px,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _MiniMapWrapper extends StatefulWidget {
  const _MiniMapWrapper();

  @override
  State<_MiniMapWrapper> createState() => _MiniMapWrapperState();
}

class _MiniMapWrapperState extends State<_MiniMapWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctrl = Get.find<FlightController>();
        ctrl.clearSelectionForMiniMap();
      } catch (e) {
        debugPrint('FlightController not found: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FlightMapScreen(miniSize: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SHARED UI HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

Widget _card({required Widget child}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: primary3Color,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: _kShadow, blurRadius: 16, offset: Offset(0, 4)),
    ],
  ),
  child: child,
);

Widget _lBadge(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withOpacity(0.4)),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    ],
  ),
);

Widget _lSectionTitle(String title) => Text(
  title,
  style: const TextStyle(
      color: _kTextMain, fontWeight: FontWeight.w700, fontSize: 13),
);

Widget _lEndpoint(
    String? code,
    String? city,
    String? time,
    String? terminal,
    CrossAxisAlignment cross,
    TextAlign textAlign,
    ) =>
    Expanded(
      child: Column(
        crossAxisAlignment: cross,
        children: [
          Text(
            code ?? '--',
            style: const TextStyle(
                color: primaryColorDark,
                fontSize: 28,
                fontWeight: FontWeight.w900),
          ),
          if (city != null && city.isNotEmpty)
            Text(city,
                style: const TextStyle(
                    color: _kTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                textAlign: textAlign),
          if (time != null)
            Text(time,
                style: const TextStyle(
                    color: _kTextMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          if (terminal != null && terminal.isNotEmpty)
            Text('Terminal $terminal',
                style: const TextStyle(color: _kTextSub, fontSize: 11),
                textAlign: textAlign),
        ],
      ),
    );

Widget _lFlightArc(String? duration, double? distKm) => Column(
  children: [
    if (duration != null)
      Text(duration,
          style: const TextStyle(
              color: _kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
    const SizedBox(height: 4),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.3),
                shape: BoxShape.circle)),
        Container(
            width: 28, height: 1, color: primaryColor.withOpacity(0.2)),
        const Icon(Icons.flight, color: primaryColor, size: 16),
        Container(
            width: 28, height: 1, color: primaryColor.withOpacity(0.2)),
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.3),
                shape: BoxShape.circle)),
      ],
    ),
    const SizedBox(height: 4),
    if (distKm != null)
      Text('${distKm.toStringAsFixed(0)} km',
          style: const TextStyle(
              color: _kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
  ],
);

Widget _lRouteStat(IconData icon, String? value, String label) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, color: primaryColor, size: 14),
    const SizedBox(width: 6),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value ?? '--',
            style: const TextStyle(
                color: _kTextMain,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(color: _kTextSub, fontSize: 10)),
      ],
    ),
  ],
);

Widget _delayRow(String label, int? value, Color color) {
  final v = value ?? 0;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: TextStyle(color: _kTextSub, fontSize: 11.px)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (v / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text('$v%',
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: _kTextMain,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.px)),
        ),
      ],
    ),
  );
}

Widget _miniStat(String label, String value, Color color) {
  return Expanded(
    child: Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 18.px)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: _kTextSub, fontSize: 10.px)),
      ],
    ),
  );
}

Widget _weatherIcon(String? condition) {
  IconData icon;
  Color color;
  switch ((condition ?? '').toLowerCase()) {
    case 'rain':
    case 'drizzle':
      icon = Icons.water_drop;
      color = const Color(0xFF1976D2);
      break;
    case 'clouds':
      icon = Icons.cloud;
      color = const Color(0xFF78909C);
      break;
    case 'clear':
      icon = Icons.wb_sunny;
      color = const Color(0xFFFFA000);
      break;
    case 'snow':
      icon = Icons.ac_unit;
      color = const Color(0xFF80DEEA);
      break;
    case 'thunderstorm':
      icon = Icons.thunderstorm;
      color = const Color(0xFF7B1FA2);
      break;
    case 'haze':
    case 'mist':
    case 'fog':
      icon = Icons.blur_on;
      color = const Color(0xFF90A4AE);
      break;
    default:
      icon = Icons.cloud_outlined;
      color = const Color(0xFF78909C);
  }
  return Icon(icon, color: color, size: 42);
}

Widget _weatherDetail(IconData icon, String value) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, color: _kTextSub, size: 13),
    const SizedBox(width: 4),
    Text(value, style: const TextStyle(color: _kTextSub, fontSize: 12)),
  ],
);