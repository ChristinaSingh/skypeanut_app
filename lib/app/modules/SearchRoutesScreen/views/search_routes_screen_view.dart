import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_models/get_find_routes_model.dart';
import '../../../data/constants/icons_constant.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';
import '../controllers/search_routes_screen_controller.dart';

class SearchRoutesScreenView extends GetView<SearchRoutesScreenController> {
  const SearchRoutesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        controller.count.value;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientPurple1, gradientPurple2, gradientPurple3,
                  gradientPurple4, gradientPurple5,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildPageTitle(),
                          const SizedBox(height: 16),
                          _buildSearchCard(context),
                          const SizedBox(height: 14),
                          _buildSearchButton(),
                          const SizedBox(height: 20),
                          Obx(() => _buildResultSection()),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: CommonWidgets.appIconsSvg(
                  assetName: IconConstants.icBackRound,
                  height: 31.px, width: 31.px,
                ),
              ),
              SizedBox(width: 5.px),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(userName.value,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.px,
                          shadows: [Shadow(
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.25))]))),
                  Obx(() => Text(cityOne.value,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.px,
                          fontWeight: FontWeight.w500))),
                ],
              ),
            ],
          ),
          Row(
            children: [
              CommonWidgets.appIcons(assetName: IconConstants.icMenuSetting,
                  height: 32.px, width: 32.px),
              SizedBox(width: 10.px),
              InkWell(onTap: () {},
                  child: CommonWidgets.appIconsSvg(assetName: IconConstants.icAiSetting,
                      height: 32.px,
                      width: 32.px,
                      color: primary3Color)),
              SizedBox(width: 10.px),
              CommonWidgets.appIcons(assetName: IconConstants.icNotificationTop,
                  height: 26.px, width: 26.px),
            ],
          ),
        ],
      ),
    );
  }

  // ── Page title ────────────────────────────────────────────────────────────
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Search Flights",
            style: TextStyle(color: Colors.white, fontSize: 24.px,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text("Enter any city, airport name, IATA or ICAO code",
            style: TextStyle(color: Colors.white70, fontSize: 12.px,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Search card (FROM / TO / Date) ────────────────────────────────────────
  Widget _buildSearchCard(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 10,
        intensity: 0.8,
        surfaceIntensity: 0.3,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(24)),
        lightSource: LightSource.topLeft,
        color: Colors.transparent,
        shadowDarkColor: Colors.white.withOpacity(0.3),
        shadowLightColor: Colors.black.withOpacity(0.2),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xffaaa5a5b2).withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // FROM
            _buildFreeTextField(
              label: "FROM",
              icon: Icons.flight_takeoff,
              iconColor: primaryColor,
              hint: "City, airport, IATA or ICAO code",
              currentValue: controller.fromDisplayText.value,
              onChanged: (val) {
                controller.selectedFromAirport.value = val;
                controller.fromDisplayText.value = val;
              },
              onSuggestionSelected: (airport) {
                final code = airport.icaoCode ?? "";
                final name = airport.name ?? "";
                controller.selectedFromAirport.value = code;
                controller.fromDisplayText.value =
                code.isNotEmpty ? "$code – $name" : name;
                controller.increment();
              },
            ),
            const SizedBox(height: 10),

            // Swap button
            Row(
              children: [
                Expanded(child: Divider(
                    color: Colors.white.withOpacity(0.15), height: 1)),
                GestureDetector(
                  onTap: controller.swapAirports,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: primaryColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.swap_vert,
                        color: primaryColor, size: 18),
                  ),
                ),
                Expanded(child: Divider(
                    color: Colors.white.withOpacity(0.15), height: 1)),
              ],
            ),
            const SizedBox(height: 10),

            // TO
            _buildFreeTextField(
              label: "TO",
              icon: Icons.flight_land,
              iconColor: primaryColor2,
              hint: "City, airport, IATA or ICAO code",
              currentValue: controller.toDisplayText.value,
              onChanged: (val) {
                controller.selectedToAirport.value = val;
                controller.toDisplayText.value = val;
              },
              onSuggestionSelected: (airport) {
                final code = airport.icaoCode ?? "";
                final name = airport.name ?? "";
                controller.selectedToAirport.value = code;
                controller.toDisplayText.value =
                code.isNotEmpty ? "$code – $name" : name;
                controller.increment();
              },
            ),
            const SizedBox(height: 16),

            // Date picker row
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text("Departure Date",
                        style: TextStyle(color: Colors.white70,
                            fontSize: 12.px, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Obx(() => Text(controller.departureDateDisplay,
                        style: TextStyle(color: Colors.white,
                            fontSize: 12.px, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Free-text input with nearby-airport suggestions ───────────────────────
  Widget _buildFreeTextField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required Function(dynamic airport) onSuggestionSelected,
  }) {
    final textCtrl = TextEditingController(text: currentValue);
    textCtrl.selection =
        TextSelection.collapsed(offset: textCtrl.text.length);
    final showSug = false.obs;
    final filtered = <dynamic>[].obs;

    textCtrl.addListener(() {
      final q = textCtrl.text.toLowerCase().trim();
      onChanged(textCtrl.text);
      if (q.isNotEmpty) {
        filtered.value = controller.nearByAirportsList.where((a) {
          final code = (a.icaoCode ?? "").toLowerCase();
          final name = (a.name ?? "").toLowerCase();
          final city = (a.city ?? "").toLowerCase();
          return code.contains(q) || name.contains(q) || city.contains(q);
        }).take(5).toList();
        showSug.value = filtered.isNotEmpty;
      } else {
        showSug.value = false;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: Colors.white70, fontSize: 12.px,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ],
          ),
        ),
        // TextField
        TextField(
          controller: textCtrl,
          style: TextStyle(color: Colors.white, fontSize: 14.px,
              fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3),
                fontSize: 12.px, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                BorderSide(color: Colors.white.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                BorderSide(color: Colors.white.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                const BorderSide(color: primaryColor, width: 1.5)),
            prefixIcon: Icon(Icons.search, color: Colors.white70, size: 18),
            suffixIcon: textCtrl.text.isNotEmpty
                ? GestureDetector(
                onTap: () {
                  textCtrl.clear();
                  onChanged('');
                  showSug.value = false;
                },
                child: const Icon(Icons.close,
                    color: Colors.white70, size: 16))
                : null,
          ),
        ),
        // Suggestion dropdown
        Obx(() {
          if (!showSug.value || filtered.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xff2A1A4A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.4), blurRadius: 12,
                  offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: List.generate(filtered.length, (i) {
                  final a = filtered[i];
                  final code = a.icaoCode ?? "";
                  final name = a.name ?? "";
                  final city = a.city ?? "";
                  return InkWell(
                    onTap: () {
                      textCtrl.text =
                      code.isNotEmpty ? "$code – $name" : name;
                      textCtrl.selection = TextSelection.collapsed(
                          offset: textCtrl.text.length);
                      onSuggestionSelected(a);
                      showSug.value = false;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        border: i < filtered.length - 1
                            ? Border(bottom: BorderSide(
                            color: Colors.white.withOpacity(0.07)))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(code,
                                style: TextStyle(color: primaryColor,
                                    fontSize: 11.px,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 12.px,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                if (city.isNotEmpty)
                                  Text(city,
                                      style: TextStyle(color: Colors.white70,
                                          fontSize: 11.px,
                                          fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Icon(Icons.north_west,
                              color: Colors.white70, size: 13),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Search button ─────────────────────────────────────────────────────────
  Widget _buildSearchButton() {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value
          ? null
          : () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.findRoutesApiCall(
          controller.selectedFromAirport.value,
          controller.selectedToAirport.value,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: controller.isLoading.value
              ? null
              : const LinearGradient(
              colors: [primaryColor, primaryColor2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight),
          color: controller.isLoading.value
              ? Colors.white.withOpacity(0.08)
              : null,
          borderRadius: BorderRadius.circular(26),
          boxShadow: controller.isLoading.value
              ? []
              : [BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: controller.isLoading.value
              ? const SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text("Search Flights",
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.px)),
            ],
          ),
        ),
      ),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESULT SECTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildResultSection() {
    if (controller.isLoading.value) return const SizedBox.shrink();

    // Error state
    if (controller.errorMessage.value.isNotEmpty) {
      return _glassCard(
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: redSecond, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(controller.errorMessage.value,
                  style: TextStyle(color: redSecond, fontSize: 13.px,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (controller.findRoutesModel == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.flight_outlined,
                  color: Colors.white.withOpacity(0.2), size: 64),
              const SizedBox(height: 12),
              Text(
                "Enter origin and destination\nto search flights",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14.px,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final data = controller.findRoutesModel?.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // API success message
        if (controller.findRoutesModel?.message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: primaryColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(controller.findRoutesModel!.message!,
                      style: TextStyle(color: primaryColor, fontSize: 12.px,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

        // ── Card 1: Flight badge (carrier + number) ──────────────────────
        _buildFlightBadgeCard(data?.flightInformation),
        const SizedBox(height: 14),

        // ── Card 2: Resolved FROM → TO ───────────────────────────────────
        _buildRouteCard(data?.resolvedLocations, data?.routeInfo),
        const SizedBox(height: 14),

        // ── Card 3 & 4: flight-details (schedule + passenger info) ────────
        //    Loads asynchronously after flight-search completes
        Obx(() {
          if (controller.isLoadingDetails.value) {
            return Column(
              children: [
                _shimmerLoadingCard("Loading schedule & passenger info…"),
                const SizedBox(height: 14),
              ],
            );
          }
          final details = controller.flightDetails.value?.data;
          if (details == null) return const SizedBox.shrink();
          return Column(
            children: [
              // Schedule card
              if (details.flightSchedule != null)
                _buildScheduleCard(details.flightSchedule!),
              if (details.flightSchedule != null) const SizedBox(height: 14),
              // Passenger info card
              if (details.passengerInfo != null)
                _buildPassengerCard(details.passengerInfo!),
              if (details.passengerInfo != null) const SizedBox(height: 14),
            ],
          );
        }),

        // ── Card 5: Weather ───────────────────────────────────────────────
        //    Prefer arrival_city_weather from flight-details (more precise);
        //    fall back to arrival_weather from flight-search
        Obx(() {
          final w = controller.flightDetails.value?.data?.arrivalCityWeather
              ?? data?.arrivalWeather;
          if (w == null) return const SizedBox.shrink();
          return Column(
            children: [
              _buildWeatherCard(w),
              const SizedBox(height: 14),
            ],
          );
        }),

        // ── Card 6: Departure forecast ────────────────────────────────────
        if (data?.departureForecast != null) ...[
          _buildForecastCard(data!.departureForecast!),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CARDS
  // ══════════════════════════════════════════════════════════════════════════

  // ── Card 1: Flight badge ──────────────────────────────────────────────────
  Widget _buildFlightBadgeCard(FlightInformation? fi) {
    if (fi == null) return const SizedBox.shrink();
    final carrier = fi.carrierCode ?? "--";
    final full = fi.fullFlightNumber ?? "--";
    final flightNum = fi.flightNumber ?? "--";
    final available = fi.available ?? false;

    return _glassCard(
      child: Row(
        children: [
          // Airline code tile
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [gradientPurple7, primaryColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: primaryColor2.withOpacity(0.3),
                  blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(carrier,
                  style: TextStyle(color: Colors.white, fontSize: 18.px,
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(full,
                        style: TextStyle(color: Colors.white, fontSize: 22.px,
                            fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(width: 10),
                    _statusBadge(
                        available ? "Available" : "Unavailable",
                        available ? primaryColor : redSecond),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _infoBadge("Carrier", carrier, primaryColor),
                    _infoBadge("Flight", flightNum, primaryColor2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 2: Route (resolved locations) ───────────────────────────────────
  Widget _buildRouteCard(ResolvedLocations? locs, RouteInfo? routeInfo) {
    final from = locs?.from;
    final to = locs?.to;
    return _glassCard(
      child: Column(
        children: [
          Row(
            children: [
              // FROM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("FROM", primaryColor),
                    const SizedBox(height: 4),
                    Text(from?.airportCode ?? "--",
                        style: TextStyle(color: Colors.white, fontSize: 28.px,
                            fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text(from?.city ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 13.px,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(from?.airportName ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 11.px,
                            fontWeight: FontWeight.w600),
                        maxLines: 2),
                    const SizedBox(height: 6),
                    if ((from?.icaoCode ?? "").isNotEmpty)
                      _chipTag(from!.icaoCode!, Colors.white70),
                    if ((from?.country ?? "").isNotEmpty)
                      _chipTag(from?.country ?? "", primaryColor2),
                  ],
                ),
              ),
              // Arc
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight, color: primaryColor, size: 22),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 22, height: 1,
                            color: Colors.white.withOpacity(0.25)),
                        Container(width: 6, height: 6,
                            decoration: const BoxDecoration(
                                color: primaryColor, shape: BoxShape.circle)),
                        Container(width: 22, height: 1,
                            color: Colors.white.withOpacity(0.25)),
                      ],
                    ),
                  ],
                ),
              ),
              // TO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabel("TO", primaryColor2),
                    const SizedBox(height: 4),
                    Text(to?.airportCode ?? "--",
                        style: TextStyle(color: Colors.white, fontSize: 28.px,
                            fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text(to?.city ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 13.px,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(to?.airportName ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 11.px,
                            fontWeight: FontWeight.w600),
                        maxLines: 2, textAlign: TextAlign.end),
                    const SizedBox(height: 6),
                    if ((to?.icaoCode ?? "").isNotEmpty)
                      _chipTag(to!.icaoCode!, Colors.white70),
                    if ((to?.country ?? "").isNotEmpty)
                      _chipTag(to?.country ?? "", primaryColor2),
                  ],
                ),
              ),
            ],
          ),
          if (routeInfo != null) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: primaryColor, size: 14),
                const SizedBox(width: 6),
                Text(routeInfo.departureDate ?? "",
                    style: TextStyle(color: Colors.white70, fontSize: 12.px,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.route, color: primaryColor2, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "${routeInfo.from ?? ""} → ${routeInfo.to ?? ""}",
                    style: TextStyle(color: Colors.white70, fontSize: 11.px,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Card 3: Flight schedule (from flight-details) ─────────────────────────
  Widget _buildScheduleCard(FlightSchedule schedule) {
    final dep = schedule.departure;
    final arr = schedule.arrival;
    final statusColor = _statusColor(schedule.status ?? "");

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Flight Schedule",
                      style: TextStyle(color: Colors.white, fontSize: 15.px,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(schedule.flightNumber ?? "",
                      style: TextStyle(color: Colors.white70, fontSize: 12.px,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              _statusBadge(schedule.status ?? "--", statusColor),
            ],
          ),
          const SizedBox(height: 18),

          // Big departure ↔ arrival times
          Row(
            children: [
              // Departure block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("DEPARTURE", primaryColor),
                    const SizedBox(height: 4),
                    Text(dep?.displayTime ?? "--",
                        style: TextStyle(color: Colors.white, fontSize: 34.px,
                            fontWeight: FontWeight.w900, height: 1)),
                    const SizedBox(height: 4),
                    Text(dep?.displayDate ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 12.px,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _cityCountry(dep?.city, dep?.country),
                      style: TextStyle(color: Colors.white70, fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                    ),
                    if ((dep?.airport ?? "").isNotEmpty &&
                        dep!.airport != "N/A") ...[
                      const SizedBox(height: 2),
                      Text(dep.airport!,
                          style: TextStyle(color: Colors.white70,
                              fontSize: 11.px, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              // Centre arc
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight, color: primaryColor, size: 18),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 18, height: 1,
                            color: Colors.white.withOpacity(0.2)),
                        Container(width: 5, height: 5,
                            decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle)),
                        Container(width: 18, height: 1,
                            color: Colors.white.withOpacity(0.2)),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrival block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _fieldLabel("ARRIVAL", primaryColor2),
                    const SizedBox(height: 4),
                    Text(arr?.displayTime ?? "--",
                        style: TextStyle(color: Colors.white, fontSize: 34.px,
                            fontWeight: FontWeight.w900, height: 1)),
                    const SizedBox(height: 4),
                    Text(arr?.displayDate ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 12.px,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _cityCountry(arr?.city, arr?.country),
                      style: TextStyle(color: Colors.white70, fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end,
                    ),
                    if ((arr?.airport ?? "").isNotEmpty &&
                        arr!.airport != "N/A") ...[
                      const SizedBox(height: 2),
                      Text(arr.airport!,
                          style: TextStyle(color: Colors.white70,
                              fontSize: 11.px, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.end),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),

          // Terminal / Gate / Baggage row
          Row(
            children: [
              Expanded(child: _tileBox(Icons.door_back_door_outlined,
                  _tbaIfNull(dep?.terminal), "Terminal", primaryColor)),
              const SizedBox(width: 10),
              Expanded(child: _tileBox(Icons.airline_seat_recline_normal,
                  _tbaIfNull(dep?.gate), "Gate", primaryColor2)),
              const SizedBox(width: 10),
              Expanded(child: _tileBox(Icons.luggage_outlined,
                  _tbaIfNull(arr?.baggageClaim), "Baggage Belt", yellowColor)),
            ],
          ),

          // Check-in strip
          if (dep?.checkInOpens != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: primaryColor, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Check-in opens",
                            style: TextStyle(color: Colors.white70,
                                fontSize: 11.px,
                                fontWeight: FontWeight.w600)),
                        Text(dep?.checkInOpens ?? "--",
                            style: TextStyle(color: Colors.white,
                                fontSize: 13.px, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (dep?.checkInDisplayTime != "--" &&
                      (dep?.checkInTime?.isNotEmpty ?? false))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(dep!.checkInDisplayTime,
                          style: TextStyle(color: primaryColor,
                              fontSize: 13.px,
                              fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Card 4: Passenger info ────────────────────────────────────────────────
  Widget _buildPassengerCard(PassengerInfo info) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Passenger Info",
              style: TextStyle(color: Colors.white, fontSize: 15.px,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _tileBox(
                  Icons.door_front_door_outlined,
                  _tbaIfNull(info.boardingGate),
                  "Boarding Gate", primaryColor)),
              const SizedBox(width: 10),
              Expanded(child: _tileBox(
                  Icons.luggage,
                  _baggageShort(info.baggageAllowance),
                  "Baggage Allowance", primaryColor2)),
              const SizedBox(width: 10),
              Expanded(child: _tileBox(
                  Icons.conveyor_belt,
                  _tbaIfNull(info.baggageClaimBelt),
                  "Claim Belt", yellowColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 5: Weather ───────────────────────────────────────────────────────
  Widget _buildWeatherCard(ArrivalWeather w) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Arrival Weather",
                  style: TextStyle(color: Colors.white, fontSize: 15.px,
                      fontWeight: FontWeight.w700)),
              _chipTag(w.location ?? "", primaryColor2),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_weatherEmoji(w.condition ?? ""),
                  style: const TextStyle(fontSize: 46)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${w.temperature?.toStringAsFixed(0) ?? "--"}°C",
                        style: TextStyle(color: Colors.white, fontSize: 36.px,
                            fontWeight: FontWeight.w900, height: 1)),
                    Text(
                      "${w.condition ?? ""}  ·  "
                          "${w.tempMin?.toStringAsFixed(0) ?? "--"}° – "
                          "${w.tempMax?.toStringAsFixed(0) ?? "--"}°",
                      style: TextStyle(color: Colors.white70, fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(w.description ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 11.px,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weatherStat("💧", "${w.humidity ?? "--"}%", "Humidity"),
              _weatherStat("💨",
                  "${w.windSpeedKmh?.toStringAsFixed(0) ?? "--"} km/h", "Wind"),
              _weatherStat("👁️", "${w.visibilityKm ?? "--"} km", "Visibility"),
              _weatherStat("🌡️",
                  "${w.feelsLike?.toStringAsFixed(0) ?? "--"}°C", "Feels"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniStrip(Icons.compress,
                  "${w.pressure ?? "--"} hPa", "Pressure")),
              const SizedBox(width: 10),
              Expanded(child: _miniStrip(Icons.cloud_outlined,
                  "${w.clouds ?? "--"}%", "Cloud Cover")),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card 6: Departure forecast ────────────────────────────────────────────
  Widget _buildForecastCard(DepartureForecast df) {
    final pct = df.punctualityPercentage ?? 0;
    final avgDelay = df.avgDepartureDelayMinutes ?? 0;
    final dc = df.delayCategories;
    final summary = df.past30FlightsSummary;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Departure Forecast",
                  style: TextStyle(color: Colors.white, fontSize: 15.px,
                      fontWeight: FontWeight.w700)),
              Row(children: [
                _iconBtn(Icons.flight_takeoff),
                const SizedBox(width: 6),
                _iconBtn(Icons.flight_land),
              ]),
            ],
          ),
          Text("Based on past ${summary?.total ?? 30} flights",
              style: TextStyle(color: Colors.white70, fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              _bigStat("$pct%", "Punctuality", primaryColor),
              _bigStat("${avgDelay}m", "Avg. Delay", redSecond),
              _bigStat("${dc?.onTime ?? 0}%", "On Time", primaryColor2),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 14),
          _bar("Early", dc?.early ?? 0, primaryColor),
          _bar("On time", dc?.onTime ?? 0, primaryColor),
          _bar("30 min late", dc?.late30Min ?? 0, yellowColor),
          _bar("60 min late", dc?.late60Min ?? 0, Colors.orange),
          _bar("90 min late", dc?.late90Min ?? 0, redSecond),
          _bar("Cancelled", dc?.cancelled ?? 0, Colors.red.shade800),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _pill("${summary?.onTime ?? 0}", "On Time", primaryColor),
                _pill("${summary?.delayed ?? 0}", "Delayed", yellowColor),
                _pill("${summary?.cancelled ?? 0}", "Cancelled", redSecond),
                _pill("${summary?.total ?? 0}", "Total", Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _glassCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );

  Widget _shimmerLoadingCard(String msg) => _glassCard(
    child: Row(
      children: [
        const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                color: primaryColor, strokeWidth: 2)),
        const SizedBox(width: 12),
        Text(msg,
            style: TextStyle(color: Colors.white70, fontSize: 13.px,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _fieldLabel(String text, Color color) => Text(text,
      style: TextStyle(color: color, fontSize: 11.px,
          fontWeight: FontWeight.w700, letterSpacing: 0.8));

  Widget _statusBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(color: color, fontSize: 11.px,
                fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _infoBadge(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: "$label: ",
            style: TextStyle(color: Colors.white70, fontSize: 11.px,
                fontWeight: FontWeight.w600)),
        TextSpan(text: value,
            style: TextStyle(color: color, fontSize: 11.px,
                fontWeight: FontWeight.w800)),
      ]),
    ),
  );

  Widget _chipTag(String text, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text,
        style: TextStyle(color: color, fontSize: 10.px,
            fontWeight: FontWeight.w700)),
  );

  Widget _tileBox(IconData icon, String value, String label, Color color) {
    final isPlaceholder = value == "TBA";
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: isPlaceholder ? Colors.white70 : Colors.white,
                  fontSize: 11.px, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center, maxLines: 2),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 10.px,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: Colors.white70, size: 14),
  );

  Widget _weatherStat(String emoji, String value, String label) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(color: Colors.white, fontSize: 12.px,
              fontWeight: FontWeight.w700)),
      Text(label,
          style: TextStyle(color: Colors.white70, fontSize: 10.px,
              fontWeight: FontWeight.w600)),
    ],
  );

  Widget _miniStrip(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.white70, fontSize: 10.px,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: TextStyle(color: Colors.white, fontSize: 12.px,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bigStat(String value, String label, Color color) => Expanded(
    child: Column(
      children: [
        Text(value,
            style: TextStyle(color: color, fontSize: 22.px,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: 11.px,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );

  Widget _bar(String label, int pct, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: (pct / 100).clamp(0.0, 1.0),
                child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text("$pct%",
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.white70, fontSize: 12.px,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  Widget _pill(String value, String label, Color color) => Column(
    children: [
      Text(value,
          style: TextStyle(color: color, fontSize: 15.px,
              fontWeight: FontWeight.w800)),
      Text(label,
          style: TextStyle(color: Colors.white70, fontSize: 10.px,
              fontWeight: FontWeight.w600)),
    ],
  );

  // ── Utility helpers ───────────────────────────────────────────────────────
  String _tbaIfNull(String? v) {
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') return "TBA";
    return v;
  }

  String _baggageShort(String? v) {
    if (v == null || v.isEmpty) return "TBA";
    if (v.toLowerCase().contains("check with")) return "Check airline";
    return v;
  }

  String _cityCountry(String? city, String? country) {
    final c = city ?? "";
    final co = country ?? "";
    if (c.isEmpty && co.isEmpty) return "";
    if (co.isEmpty) return c;
    if (c.isEmpty) return co;
    return "$c, $co";
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('schedul')) return primaryColor;
    if (s.contains('depart') || s.contains('en route')) return primaryColor2;
    if (s.contains('land') || s.contains('arriv')) return liteGreenColor;
    if (s.contains('cancel')) return redSecond;
    if (s.contains('delay')) return yellowColor;
    return Colors.white70;
  }

  String _weatherEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sunny')) return '☀️';
    if (c.contains('cloud')) return '⛅';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('fog') || c.contains('mist') || c.contains('haze')) return '🌫️';
    if (c.contains('wind')) return '💨';
    return '🌤️';
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryColor,
            surface: Color(0xff2A1A4A),
            onSurface: Colors.white,
          ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xff2A1A4A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.increment();
    }
  }
}