import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/map_routes_page_controller.dart';

class MapRoutesPageView extends GetView<MapRoutesPageController> {
  const MapRoutesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gradientPurple1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientPurple1,
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildStatusCard(),
                      const SizedBox(height: 14),
                      _buildTimeCard(),
                      const SizedBox(height: 14),
                      _buildInfoTiles(),
                      const SizedBox(height: 14),
                      _buildMapPreview(),
                      const SizedBox(height: 14),
                      Obx(() {
                        if (controller.isLoadingExtra.value) {
                          return _buildLoadingCards();
                        }
                        return Column(
                          children: [
                            _buildWeatherCard(),
                            const SizedBox(height: 14),
                            _buildDepartureForecastCard(),
                            const SizedBox(height: 14),
                            _buildRouteStatsCard(),
                            const SizedBox(height: 14),
                          ],
                        );
                      }),
                      CommonWidgets.commonElevatedButton(
                        height: 48.px,
                        width: double.infinity,
                        buttonColor: primaryColor.withOpacity(0.2),
                        borderRadius: 24.px,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_outlined,
                                color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Show Full Map",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.px,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () =>
                            Get.toNamed(Routes.MAP_ROUTES_FULL_PAGE),
                      ),
                      const SizedBox(height: 24),
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

  // ── Top bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  controller.count.value;
                  return Text(
                    controller.routesList?.name ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.px,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
                Text(
                  "Route Details",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.px,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icAiSetting,
                height: 32.px,
                width: 32.px,
                color: primary3Color
            ),
          ),
          const SizedBox(width: 8),
          CommonWidgets.appIcons(
            assetName: IconConstants.icNotificationTop,
            height: 26.px,
            width: 26.px,
          ),
        ],
      ),
    );
  }

  // ── Status card ──────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return _glassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "On Schedule",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18.px,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                controller.routesList?.summary ?? "",
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.px,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          _radarWidget(),
        ],
      ),
    );
  }

  // ── Animated radar icon ──────────────────────────────────────────────────
  Widget _radarWidget() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 3; i >= 1; i--)
            Container(
              width: (i * 18).toDouble(),
              height: (i * 18).toDouble(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.15 * i),
                  width: 1.5,
                ),
              ),
            ),
          const Icon(Icons.radar, color: primaryColor, size: 20),
        ],
      ),
    );
  }

  // ── Departure → Arrival time card ────────────────────────────────────────
  Widget _buildTimeCard() {
    final from = controller.routesList?.fromAirport;
    final to = controller.routesList?.toAirport;
    final mins =
        controller.routesList?.routeInfo?.estimatedFlightTimeMinutes ?? 0;
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    final durationStr = hours > 0 ? "${hours}h ${remMins}m" : "${remMins}m";

    return _glassCard(
      child: Column(
        children: [
          Row(
            children: [
              // Departure
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _timeLabel("Departure"),
                    Text(
                      from?.icao ?? "--",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.px,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      from?.city ?? "",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      from?.name ?? "",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              // Flight path indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      durationStr,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white24,
                            ),
                          ),
                          const Icon(Icons.flight,
                              color: primaryColor, size: 16),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white24,
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _timeLabel("Arrival"),
                    Text(
                      to?.icao ?? "--",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.px,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      to?.city ?? "",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      to?.name ?? "",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.px,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _routeStat(
                Icons.straighten,
                "${controller.routesList?.distanceKm ?? 0} km",
                "Distance",
              ),
              _routeStat(
                Icons.explore,
                "${controller.routesList?.routeInfo?.bearingDegrees?.toStringAsFixed(1) ?? "--"}°",
                "Bearing",
              ),
              _routeStat(
                Icons.timer_outlined,
                durationStr,
                "Est. Time",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeLabel(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 10.px,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );

  Widget _routeStat(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, color: primaryColor2, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.px,
                fontWeight: FontWeight.w600,
              )),
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
        ],
      );

  // ── Info tiles (Check-in / Gate / Baggage) ───────────────────────────────
  Widget _buildInfoTiles() {
    return Row(
      children: [
        Expanded(
            child: _infoTile(Icons.check_circle_outline, "Check-in", "--")),
        const SizedBox(width: 10),
        Expanded(child: _infoTile(Icons.door_back_door_outlined, "Gate", "--")),
        const SizedBox(width: 10),
        Expanded(child: _infoTile(Icons.luggage_outlined, "Baggage", "--")),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.px,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Embedded map ─────────────────────────────────────────────────────────
  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _EmbeddedMapView(controller: controller),
      ),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────────────────
  Widget _buildLoadingCards() {
    return Column(
      children: [
        _skeletonCard(120),
        const SizedBox(height: 14),
        _skeletonCard(200),
        const SizedBox(height: 14),
        _skeletonCard(160),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _skeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // ── Weather card ─────────────────────────────────────────────────────────
  Widget _buildWeatherCard() {
    return Obx(() {
      final w = controller.destinationWeather.value;
      final city = controller.routesList?.toAirport?.city ?? "Destination";
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Arrival Weather",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.px,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  city,
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.px,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (w == null)
              Center(
                child: Text("Weather data unavailable",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w600)),
              )
            else ...[
              Row(
                children: [
                  Text(
                    controller.weatherIcon(w.condition),
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${w.temperature.toStringAsFixed(0)}°C",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36.px,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Text(
                        "${w.condition} | ${w.tempMin.toStringAsFixed(0)}° – ${w.tempMax.toStringAsFixed(0)}°",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.px,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        w.description,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.px,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _weatherStat("💧", "${w.humidity}%", "Humidity"),
                  _weatherStat("💨",
                      "${w.windSpeedKmh.toStringAsFixed(0)} km/h", "Wind"),
                  _weatherStat("👁️", "${w.visibilityKm} km", "Visibility"),
                  _weatherStat("🌡️", "${w.feelsLike.toStringAsFixed(0)}°C",
                      "Feels like"),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _weatherStat(String icon, String value, String label) => Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600)),
        ],
      );

  // ── Departure forecast card ───────────────────────────────────────────────
  Widget _buildDepartureForecastCard() {
    return Obx(() {
      final fs = controller.flightSearchData.value;
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Departure Forecast",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.px,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flight_takeoff,
                          color: Colors.white70, size: 14),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flight_land,
                          color: Colors.white70, size: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Performance based on past 30 flights",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (fs == null)
              Center(
                child: Text("Forecast data unavailable",
                    style: TextStyle(color: Colors.white38, fontSize: 12.px)),
              )
            else ...[
              Row(
                children: [
                  _forecastStat(
                    "${fs.punctualityPercentage}%",
                    "Punctuality",
                    primaryColor,
                  ),
                  _forecastStat(
                    "${fs.avgDelayMinutes} min",
                    "Avg. late",
                    redSecond,
                  ),
                  _forecastStat(
                    "${fs.onTimePct}%",
                    "On time",
                    primaryColor2,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 14),
              _forecastBar("Early", fs.earlyPct, primaryColor),
              _forecastBar("On time", fs.onTimePct, primaryColor),
              _forecastBar("30 min late", fs.late30Pct, yellowColor),
              _forecastBar("60 min late", fs.late60Pct, Colors.orange),
              _forecastBar("90 min late", fs.late90Pct, redSecond),
              _forecastBar("Cancelled", fs.cancelledPct, Colors.red.shade900),
            ],
          ],
        ),
      );
    });
  }

  Widget _forecastStat(String value, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22.px,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.px,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _forecastBar(String label, int pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (pct / 100).clamp(0.0, 1.0),
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
            width: 36,
            child: Text(
              "$pct%",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ── Route stats card (like "aircraft" card in reference) ─────────────────
  Widget _buildRouteStatsCard() {
    final route = controller.routesList;
    final from = route?.fromAirport;
    final to = route?.toAirport;

    return _glassCard(
      child: Column(
        children: [
          // ICAO codes + flight arc
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                from?.icao ?? "--",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.px,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      const Icon(Icons.flight, color: primaryColor, size: 18),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                              child:
                                  Container(height: 1, color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              "${route?.routeInfo?.estimatedFlightTimeMinutes ?? 0} min",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.px,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                              child:
                                  Container(height: 1, color: Colors.white24)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                to?.icao ?? "--",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.px,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() {
                final pct =
                    controller.flightSearchData.value?.punctualityPercentage;
                return _routeStatBig(pct != null ? "$pct%" : "--",
                    "Departure\npunctuality", primaryColor);
              }),
              Obx(() {
                final fs = controller.flightSearchData.value;
                // Arrival punctuality estimated
                final arrPct = fs != null
                    ? (fs.punctualityPercentage + 3).clamp(0, 100)
                    : null;
                return _routeStatBig(arrPct != null ? "$arrPct%" : "--",
                    "Arrival\npunctuality", primaryColor2);
              }),
              Obx(() {
                final delay =
                    controller.flightSearchData.value?.avgDelayMinutes;
                return _routeStatBig(delay != null ? "${delay}m" : "--",
                    "Late on\naverage", yellowColor);
              }),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _routeStatBig(
                "${route?.distanceKm ?? "--"} km",
                "Distance",
                Colors.white70,
              ),
              _routeStatBig(
                "${route?.distanceNm?.toStringAsFixed(1) ?? "--"} NM",
                "Nautical\nmiles",
                Colors.white70,
              ),
              _routeStatBig(
                "${route?.routeInfo?.bearingDegrees?.toStringAsFixed(1) ?? "--"}°",
                "Bearing",
                Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeStatBig(String value, String label, Color color) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18.px,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12.px,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      );

  // ── Shared glass card wrapper ─────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Embedded WebView — stable StatefulWidget
// ─────────────────────────────────────────────────────────────────────────────
class _EmbeddedMapView extends StatefulWidget {
  final MapRoutesPageController controller;

  const _EmbeddedMapView({required this.controller});

  @override
  State<_EmbeddedMapView> createState() => _EmbeddedMapViewState();
}

class _EmbeddedMapViewState extends State<_EmbeddedMapView> {
  late InAppWebViewController _webViewController;
  final RxBool _ready = false.obs;
  static const _webUrl = "https://globe.adsbexchange.com/";

  static const String _viewportScript = r"""
  (function(){var m=document.querySelector('meta[name="viewport"]');
  if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m);}
  m.content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no';})();
  """;

  static const String _cleanupScript = r"""
  (function(){
    var old=document.getElementById('__ec__');if(old)old.remove();
    var s=document.createElement('style');s.id='__ec__';
    s.innerHTML=`
      html,body{margin:0!important;padding:0!important;width:100%!important;height:100%!important;overflow:hidden!important;background:transparent!important;}
      #map,#cesiumContainer,.leaflet-container{position:absolute!important;top:0!important;left:0!important;width:100%!important;height:100%!important;z-index:1!important;margin:0!important;padding:0!important;}
      #topmenu,.topmenu,#top-menu,.top-menu,#buttonGroup,.buttonGroup,.button-group,#typeButtons,.typeButtons,
      #toggle_sidebar_button,#loginButton,#betaButton,#fullscreenButton,#settingsButton,#layersButton,
      #mapButtons,.mapButtons,#mapControls,.mapControls,#right-panel,.right-panel,#rightPanel,#sideButtons,
      #sidebar,#sidebar-toggle,.globeSidebar,.sidebar,#searchbar,#search-wrapper,#toolbar,.toolbar,.top-bar,
      #infoblock,.infoblock,#infoblockBottom,#selected_ac_data,#acList,#acList2,#routeData,#notam,#statsblock,
      #planeList,#flightList,.globeFooter,#globeFooter,#adsb-logo,.adsb-logo,
      .leaflet-control-zoom,.leaflet-bar,.leaflet-control-attribution,.leaflet-control-layers,.leaflet-control-container,
      .leaflet-popup,.leaflet-popup-pane,.scale-line,#scale,#version,#message_block,.top_message_block,
      #helppage,#showFlags,#layer-chooser,#range-rings,#bottombar,#bottom-bar,#status-bar,header,footer,nav,iframe,
      div[id*="advert"]:not([id*="map"]),div[class*="advert"]:not([class*="map"]),
      div[id*="banner"]:not([id*="map"]),div[class*="banner"]:not([class*="map"]),
      div[id*="gdpr"],div[class*="gdpr"],div[id*="consent"],div[class*="consent"],
      div[id*="cookie"],div[class*="cookie"],div[id*="modal"]:not([id*="map"]),div[class*="modal"]:not([class*="map"]){
        display:none!important;visibility:hidden!important;pointer-events:none!important;}
    `;
    document.head.appendChild(s);
    ['#topmenu','#toggle_sidebar_button','#loginButton','#betaButton','#fullscreenButton','#settingsButton',
     '#mapButtons','#mapControls','#rightPanel','#sidebar','.globeSidebar','#searchbar','#toolbar',
     '#infoblock','#acList','#routeData','#statsblock','.globeFooter','#adsb-logo',
     '.leaflet-control-container','.leaflet-popup','#helppage','#bottombar','#status-bar',
     '#scale','#message_block','header','footer','nav','iframe']
    .forEach(function(sel){document.querySelectorAll(sel).forEach(function(el){el.remove();});});
    var mapEl=document.getElementById('map')||document.querySelector('.leaflet-container')||document.getElementById('cesiumContainer');
    if(mapEl){mapEl.style.setProperty('position','absolute','important');mapEl.style.setProperty('top','0','important');mapEl.style.setProperty('left','0','important');mapEl.style.setProperty('width','100%','important');mapEl.style.setProperty('height','100%','important');}
    setTimeout(function(){['OL','ownMap','map','globeMap','mainMap'].forEach(function(k){try{var m=window[k];if(m&&m.invalidateSize)m.invalidateSize(true);}catch(e){}});},300);
    if(!window.__ec_obs__){window.__ec_obs__=new MutationObserver(function(mutations){mutations.forEach(function(m){m.addedNodes.forEach(function(node){if(node.nodeType!==1)return;var id=(node.id||'').toLowerCase();var cls=(typeof node.className==='string'?node.className:'').toLowerCase();var bad=['advert','banner','gdpr','consent','cookie','modal','popup'].some(function(kw){return(id.includes(kw)||cls.includes(kw))&&!id.includes('map')&&!cls.includes('map');});if(bad||node.tagName==='IFRAME')node.remove();});});document.querySelectorAll('.leaflet-popup').forEach(function(p){p.remove();});});window.__ec_obs__.observe(document.body,{childList:true,subtree:true});}
  })();
  """;

  Future<void> _runCleanup() async {
    try {
      await _webViewController.evaluateJavascript(source: _cleanupScript);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_webUrl)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              supportZoom: false,
              userAgent:
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
                  'AppleWebKit/605.1.15 (KHTML, like Gecko) '
                  'Version/17.0 Mobile/15E148 Safari/604.1',
              contentBlockers: [
                ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*doubleclick\.net.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
                ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*googlesyndication\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
                ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*amazon-adsystem\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
                ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*adnxs\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
                ContentBlocker(
                    trigger: ContentBlockerTrigger(urlFilter: r".*1rx\.io.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
                ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*crwdcntrl\.net.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK)),
              ],
            ),
            android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                useWideViewPort: false,
                loadWithOverviewMode: false),
            ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
          ),
          onWebViewCreated: (wc) => _webViewController = wc,
          onPageCommitVisible: (wc, _) async =>
              await wc.evaluateJavascript(source: _viewportScript),
          onLoadStart: (_, __) {
            widget.controller.isLoading.value = true;
            _ready.value = false;
          },
          onLoadStop: (_, __) async {
            widget.controller.isLoading.value = false;
            widget.controller.webCountIncrement();
            await _runCleanup();
            await Future.delayed(const Duration(milliseconds: 800));
            _ready.value = true;
            Future.delayed(const Duration(seconds: 2), _runCleanup);
            Future.delayed(const Duration(seconds: 5), _runCleanup);
          },
        ),
        Obx(() => _ready.value
            ? const SizedBox.shrink()
            : Container(
                color: gradientPurple3,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: primaryColor, strokeWidth: 2),
                ),
              )),
      ],
    );
  }
}
