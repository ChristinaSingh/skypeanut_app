// lib/common/flight_info_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/FlightMap/controllers/flight_map_controller.dart';
import 'app_theme_controller.dart';
import 'flight_detail_service.dart';
import '../data/apis/api_models/flight_model.dart';

class FlightInfoSheet extends GetView<FlightController> {
  final AppThemeController theme;
  final VoidCallback onClose;

  const FlightInfoSheet({
    super.key,
    required this.theme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final flight = controller.selectedFlight.value;
      if (flight == null) return const SizedBox.shrink();

      return _SheetContent(
        flight: flight,
        theme: theme,
        onClose: onClose,
      );
    });
  }
}

class _SheetContent extends GetView<FlightController> {
  final Flight flight;
  final AppThemeController theme;
  final VoidCallback onClose;

  const _SheetContent({
    required this.flight,
    required this.theme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _SheetHeader(flight: flight, theme: theme, onClose: onClose),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  // Route card
                  _RouteCard(flight: flight, theme: theme),
                  const SizedBox(height: 12),

                  // Live data row
                  _LiveDataRow(flight: flight, theme: theme),
                  const SizedBox(height: 12),

                  // ── ETA Section ──────────────────────────────────────
                  if (flight.estimatedArrivalInfo.isNotEmpty) ...[
                    _EtaSection(flight: flight, theme: theme),
                    const SizedBox(height: 12),
                  ],

                  // Popup details (async)
                  _PopupDetails(theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final Flight flight;
  final AppThemeController theme;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.flight,
    required this.theme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
      child: Row(
        children: [
          // Airline badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                flight.airlineIata.isNotEmpty
                    ? flight.airlineIata
                    : flight.displayCallsign.substring(0, 2),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Callsign + aircraft
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      flight.displayCallsign,
                      style: TextStyle(
                        color: theme.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: flight.status, theme: theme),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (flight.registration.isNotEmpty) ...[
                      Text(
                        flight.registration,
                        style: TextStyle(color: theme.textSub, fontSize: 13),
                      ),
                      Text(
                        ' · ',
                        style: TextStyle(color: theme.textHint, fontSize: 13),
                      ),
                    ],
                    Text(
                      flight.aircraftIata.isNotEmpty
                          ? flight.aircraftIata
                          : 'Unknown type',
                      style: TextStyle(color: theme.textSub, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.cardAlt,
                shape: BoxShape.circle,
                border: Border.all(color: theme.border),
              ),
              child: Icon(Icons.close, color: theme.textSub, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final AppThemeController theme;

  const _StatusBadge({required this.status, required this.theme});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'en-route':
        color = const Color(0xFF0D47A1);
        label = 'EN ROUTE';
        break;
      case 'landed':
        color = const Color(0xFF2E7D32);
        label = 'LANDED';
        break;
      case 'scheduled':
        color = const Color(0xFF6A1B9A);
        label = 'SCHEDULED';
        break;
      default:
        color = const Color(0xFF546E7A);
        label = status.isEmpty ? 'LIVE' : status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Route Card ────────────────────────────────────────────────────────────────
class _RouteCard extends GetView<FlightController> {
  final Flight flight;
  final AppThemeController theme;

  const _RouteCard({required this.flight, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: theme.sheetGradient,
        color: theme.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Obx(() {
        final popup = controller.selectedPopup.value;
        final isLoading = controller.isLoadingPopup.value;

        final depCode = popup?.departure?.airportCode.isNotEmpty == true
            ? popup!.departure!.airportCode
            : flight.departure;

        final arrCode = popup?.arrival?.airportCode.isNotEmpty == true
            ? popup!.arrival!.airportCode
            : flight.arrival;

        final depName = popup?.departure?.name ?? '';
        final arrName = popup?.arrival?.name ?? '';
        final depCountry = popup?.departure?.country ?? '';
        final arrCountry = popup?.arrival?.country ?? '';
        final distKm = popup?.distanceKm;
        final distNm = popup?.distanceNm;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _AirportInfo(
                    code: depCode.isNotEmpty ? depCode : '???',
                    name: depName,
                    country: depCountry,
                    label: 'DEPARTURE',
                    isLoading: isLoading && depCode.isEmpty,
                    theme: theme,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      if (distKm != null)
                        Text(
                          '${distKm.toStringAsFixed(0)} km',
                          style: TextStyle(
                            color: theme.textHint,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Icon(Icons.flight, color: theme.primary, size: 22),
                      if (distNm != null)
                        Text(
                          '${distNm.toStringAsFixed(0)} nm',
                          style: TextStyle(
                            color: theme.textHint,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _AirportInfo(
                    code: arrCode.isNotEmpty ? arrCode : '???',
                    name: arrName,
                    country: arrCountry,
                    label: 'ARRIVAL',
                    isLoading: isLoading && arrCode.isEmpty,
                    theme: theme,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            if (popup?.progressPercent != null) ...[
              const SizedBox(height: 12),
              _ProgressBar(
                progress: (popup!.progressPercent! / 100).clamp(0.0, 1.0),
                eta: popup.etaFormatted,
                theme: theme,
              ),
            ],
          ],
        );
      }),
    );
  }
}

// ── Airport Info ──────────────────────────────────────────────────────────────
class _AirportInfo extends StatelessWidget {
  final String code;
  final String name;
  final String country;
  final String label;
  final bool isLoading;
  final AppThemeController theme;
  final CrossAxisAlignment align;

  const _AirportInfo({
    required this.code,
    required this.name,
    required this.country,
    required this.label,
    required this.isLoading,
    required this.theme,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textHint,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primary,
            ),
          )
        else
          Text(
            code,
            style: TextStyle(
              color: theme.textMain,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        if (name.isNotEmpty)
          Text(
            name,
            style: TextStyle(color: theme.textSub, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align == CrossAxisAlignment.end
                ? TextAlign.right
                : TextAlign.left,
          ),
        if (country.isNotEmpty)
          Text(
            country,
            style: TextStyle(color: theme.textHint, fontSize: 10),
            textAlign: align == CrossAxisAlignment.end
                ? TextAlign.right
                : TextAlign.left,
          ),
      ],
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  final String eta;
  final AppThemeController theme;

  const _ProgressBar({
    required this.progress,
    required this.eta,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(0)}% complete',
              style: TextStyle(color: theme.textSub, fontSize: 11),
            ),
            Text(
              'ETA: $eta',
              style: TextStyle(
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.border,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Live Data Row ─────────────────────────────────────────────────────────────
class _LiveDataRow extends StatelessWidget {
  final Flight flight;
  final AppThemeController theme;

  const _LiveDataRow({required this.flight, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            icon: Icons.height,
            label: 'ALTITUDE',
            value: '${flight.altitudeFt.toStringAsFixed(0)} ft',
            sub: '${flight.altitudeM.toStringAsFixed(0)} m',
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            icon: Icons.speed,
            label: 'SPEED',
            value: '${flight.speedKnots.toStringAsFixed(0)} kts',
            sub: '${flight.speedKmh.toStringAsFixed(0)} km/h',
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            icon: Icons.explore,
            label: 'HEADING',
            value: '${flight.heading.toStringAsFixed(0)}°',
            sub: _compassDir(flight.heading),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            icon: flight.verticalSpeed > 0
                ? Icons.trending_up
                : flight.verticalSpeed < 0
                ? Icons.trending_down
                : Icons.trending_flat,
            label: 'V/S',
            value: '${flight.verticalSpeed.toStringAsFixed(0)}',
            sub: 'm/min',
            theme: theme,
          ),
        ),
      ],
    );
  }

  String _compassDir(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg % 360) / 45).round() % 8];
  }
}

// ── Stat Box ──────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final AppThemeController theme;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.textHint,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sub,
            style: TextStyle(color: theme.textSub, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ── ETA Section ───────────────────────────────────────────────────────────────
class _EtaSection extends StatelessWidget {
  final Flight flight;
  final AppThemeController theme;

  const _EtaSection({required this.flight, required this.theme});

  @override
  Widget build(BuildContext context) {
    final mins    = flight.etaMinutes;
    final etaTime = flight.etaTimeFormatted;
    final etaDur  = flight.etaDurationFormatted;

    // ── Colour tier ───────────────────────────────────────────────────────────
    final Color accent;
    final IconData planeIcon;
    final String phaseLabel;

    if (mins != null && mins <= 5) {
      accent     = const Color(0xFF00C853);
      planeIcon  = Icons.flight_land_rounded;
      phaseLabel = '🛬  Final approach';
    } else if (mins != null && mins <= 15) {
      accent     = const Color(0xFF00C853);
      planeIcon  = Icons.flight_land_rounded;
      phaseLabel = '🟢  Landing soon';
    } else if (mins != null && mins <= 45) {
      accent     = const Color(0xFFFF8F00);
      planeIcon  = Icons.flight_rounded;
      phaseLabel = '🟡  Approaching destination';
    } else if (mins != null && mins <= 120) {
      accent     = const Color(0xFF0D47A1);
      planeIcon  = Icons.flight_rounded;
      phaseLabel = '🔵  Cruising';
    } else {
      accent     = const Color(0xFF0D47A1);
      planeIcon  = Icons.flight_rounded;
      phaseLabel = '✈️  En route';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section title ─────────────────────────────────────────────────
        _SectionTitle('ESTIMATED ARRIVAL', theme),
        const SizedBox(height: 10),

        // ── Main card ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // ── Top row: icon circle + big time + countdown pill ──────
              Row(
                children: [
                  // Icon circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(planeIcon, color: accent, size: 24),
                  ),

                  const SizedBox(width: 12),

                  // ETA clock display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          etaTime,
                          style: TextStyle(
                            color: accent,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Local arrival time',
                          style: TextStyle(
                            color: theme.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Countdown pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          etaDur,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'to land',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Progress bar ──────────────────────────────────────────
              if (mins != null) ...[
                const SizedBox(height: 16),
                _EtaProgressRow(
                  minutes: mins,
                  accent: accent,
                  theme: theme,
                ),
              ],

              // ── Phase label chip ──────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accent.withOpacity(0.18),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  phaseLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── ETA Progress Row ──────────────────────────────────────────────────────────
class _EtaProgressRow extends StatelessWidget {
  final int minutes;
  final Color accent;
  final AppThemeController theme;

  const _EtaProgressRow({
    required this.minutes,
    required this.accent,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // 300 min = reference max; closer to 0 min = more progress filled
    const maxRef = 300;
    final elapsed = (maxRef - minutes).clamp(0, maxRef);
    final progress = elapsed / maxRef;

    return Column(
      children: [
        Row(
          children: [
            // Takeoff icon
            Icon(
              Icons.flight_takeoff_rounded,
              size: 15,
              color: theme.textSub,
            ),
            const SizedBox(width: 6),

            // Bar + plane cursor
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final cursorLeft =
                      (barWidth * progress.clamp(0.0, 0.95)) - 7;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Track
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Filled portion
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.02, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withOpacity(0.45),
                                accent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Plane cursor sitting on top of bar tip
                      Positioned(
                        left: cursorLeft.clamp(0.0, barWidth - 14),
                        top: -5,
                        child: Icon(
                          Icons.flight_rounded,
                          size: 15,
                          color: accent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(width: 6),
            // Land icon
            Icon(
              Icons.flight_land_rounded,
              size: 15,
              color: accent,
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Remaining minutes label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${((progress) * 100).toStringAsFixed(0)}% of journey',
              style: TextStyle(
                color: theme.textHint,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$minutes min remaining',
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Popup Details ─────────────────────────────────────────────────────────────
class _PopupDetails extends GetView<FlightController> {
  final AppThemeController theme;

  const _PopupDetails({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingPopup.value;
      final popup = controller.selectedPopup.value;

      if (isLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Loading flight details…',
                  style: TextStyle(color: theme.textSub, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      if (popup == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aircraft info row
          _InfoRow(
            items: [
              _InfoItem('ICAO24', popup.icao24, theme),
              _InfoItem('AIRLINE', popup.airlineIcao, theme),
              _InfoItem('PHASE', popup.phase ?? '—', theme),
            ],
          ),
          const SizedBox(height: 12),

          // Destination weather
          if (popup.destWeather != null) ...[
            _SectionTitle('DESTINATION WEATHER', theme),
            const SizedBox(height: 8),
            _WeatherCard(weather: popup.destWeather!, theme: theme),
          ],
        ],
      );
    });
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .expand(
            (item) => [Expanded(child: item), const SizedBox(width: 8)],
      )
          .take(items.length * 2 - 1)
          .toList(),
    );
  }
}

// ── Info Item ─────────────────────────────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeController theme;

  const _InfoItem(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textHint,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: TextStyle(
              color: theme.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final AppThemeController theme;
  const _SectionTitle(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.textSub,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: theme.divider, height: 1)),
      ],
    );
  }
}

// ── Weather Card ──────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherInfo weather;
  final AppThemeController theme;

  const _WeatherCard({required this.weather, required this.theme});

  @override
  Widget build(BuildContext context) {
    final ruleColor = _flightRuleColor(weather.flightRules);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rules badge + raw METAR
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ruleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ruleColor.withOpacity(0.5)),
                ),
                child: Text(
                  weather.flightRules,
                  style: TextStyle(
                    color: ruleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weather.raw,
                  style: TextStyle(
                    color: theme.textHint,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Weather stats grid
          Row(
            children: [
              _WeatherStat('🌡', 'TEMP', weather.tempFormatted, theme),
              _WeatherStat('💨', 'WIND', weather.windFormatted, theme),
              _WeatherStat('👁', 'VIS', weather.visFormatted, theme),
              _WeatherStat('📊', 'QNH', weather.pressureFormatted, theme),
            ],
          ),

          // Wx codes
          if (weather.wxCodes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: weather.wxCodes.map((wx) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.loading.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                    Border.all(color: theme.loading.withOpacity(0.4)),
                  ),
                  child: Text(
                    wx,
                    style: TextStyle(
                      color: theme.loading,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Cloud layers
          if (weather.clouds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: weather.clouds.map((c) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardAlt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.border),
                  ),
                  child: Text(
                    c.formatted,
                    style: TextStyle(
                      color: theme.textSub,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _flightRuleColor(String rule) {
    switch (rule.toUpperCase()) {
      case 'VFR':
        return const Color(0xFF00C853);
      case 'MVFR':
        return const Color(0xFF2196F3);
      case 'IFR':
        return const Color(0xFFFF5252);
      case 'LIFR':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF546E7A);
    }
  }
}

// ── Weather Stat ──────────────────────────────────────────────────────────────
class _WeatherStat extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final AppThemeController theme;

  const _WeatherStat(this.emoji, this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.textHint,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.textMain,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}