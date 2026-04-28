// ─────────────────────────────────────────────────────────────────────────────
// flight_map_view.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../common/app_theme_controller.dart';
import '../../../common/flight_info_sheet.dart';
import '../../../common/stats_bar.dart';
import '../controllers/flight_map_controller.dart';

class FlightMapScreen extends StatefulWidget {
  final bool miniSize;

  const FlightMapScreen({
    super.key,
    required this.miniSize,
  });

  @override
  State<FlightMapScreen> createState() => _FlightMapScreenState();
}

class _FlightMapScreenState extends State<FlightMapScreen> {
  late FlightController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<FlightController>();
    ctrl.setMiniMapMode(widget.miniSize);
  }

  @override
  void didUpdateWidget(FlightMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.miniSize != widget.miniSize) {
      ctrl.setMiniMapMode(widget.miniSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = AppThemeController.to;

      return Scaffold(
        backgroundColor: theme.bg,
        body: Obx(() {
          if (ctrl.mapLoadState.value == MapLoadState.locating) {
            return _LoadingView(theme: theme);
          }
          return _MapView(
            miniSize: widget.miniSize,
            theme: theme,
          );
        }),
      );
    });
  }
}

// ─── Loading View ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final AppThemeController theme;

  const _LoadingView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.iconActive,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Acquiring location…',
            style: TextStyle(color: theme.iconActive, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─── Map View ─────────────────────────────────────────────────
class _MapView extends GetView<FlightController> {
  final bool miniSize;
  final AppThemeController theme;

  const _MapView({
    required this.miniSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Google Map ──────────────────────────────────────────────────────
        _GoogleMapLayer(theme: theme),

        // ── Search bar (full mode only) ─────────────────────────────────────
        if (!miniSize)

          _SearchOverlay(theme: theme),

        // ── Top bar (full mode only) ────────────────────────────────────────
        if (!miniSize)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(theme: theme),
          ),

        // ── Stats bar (full mode only) ──────────────────────────────────────
        if (!miniSize)
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: 0,
            right: 0,
            child: StatsBar(theme: theme),
          ),

        // ── Right-side FABs + Settings ──────────────────────────────────────
        Positioned(
          right: miniSize ? 8 : 16,
          bottom: miniSize ? 8 : 200,
          child: _ControlFabs(miniSize: miniSize, theme: theme),
        ),

        // ── Map theme settings panel (anchored bottom-right above FABs) ─────
        if (!miniSize)
          Positioned(
            right: 16,
            bottom: 40,
            child: _MapThemePanel(theme: theme),
          ),

        // ── Error banner ────────────────────────────────────────────────────
        Obx(() {
          if (controller.errorMessage.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Positioned(
            bottom: miniSize ? 60 : 180,
            left: 16,
            right: 72,
            child: _ErrorBanner(
              message: controller.errorMessage.value,
              theme: theme,
            ),
          );
        }),

        // ── Flight info sheet (full mode only) ──────────────────────────────
        if (!miniSize)
          Obx(() {
            final flight = controller.selectedFlight.value;
            if (flight == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FlightInfoSheet(
                theme: theme,
                onClose: controller.clearSelection,
              ),
            );
          }),

        // ── Mini map "LIVE" indicator ───────────────────────────────────────
        if (miniSize)
          Positioned(
            top: 10,
            left: 12,
            child: _LiveIndicator(theme: theme),
          ),
      ],
    );
  }
}

// ─── Live Indicator for Mini Map ──────────────────────────────
class _LiveIndicator extends StatelessWidget {
  final AppThemeController theme;

  const _LiveIndicator({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Overlay ───────────────────────────────────────────
class _SearchOverlay extends GetView<FlightController> {
  final AppThemeController theme;

  const _SearchOverlay({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isSearchOpen.value) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: controller.closeSearch,
        child: Container(
          margin: EdgeInsetsGeometry.only(top: 120),
          color: Colors.transparent,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: theme.elevatedShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: theme.iconActive,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: controller.searchController,
                                  autofocus: true,
                                  style: TextStyle(
                                    color: theme.textMain,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search flight (e.g. AI2119, N88BG)',
                                    hintStyle: TextStyle(
                                      color: theme.textHint,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  onChanged: controller.onSearchChanged,
                                  onSubmitted: controller.submitSearch,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.closeSearch,
                                child: Icon(
                                  Icons.close,
                                  color: theme.textSub,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: theme.divider, height: 1),
                        // Search hints
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search by:',
                                style: TextStyle(
                                  color: theme.textSub,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _searchHint(theme, 'Flight number', 'AI2119, BA142'),
                              const SizedBox(height: 4),
                              _searchHint(theme, 'Aircraft registration', 'N88BG, VT-ABC'),
                              const SizedBox(height: 4),
                              _searchHint(theme, 'ICAO24 hex code', 'a1b2c3'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _searchHint(AppThemeController theme, String label, String example) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.iconActive,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.textMain,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($example)',
          style: TextStyle(
            color: theme.textHint,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Map Theme Panel ──────────────────────────────────────────
class _MapThemePanel extends GetView<FlightController> {
  final AppThemeController theme;

  const _MapThemePanel({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkTheme;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.border, width: 1),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Label ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers_outlined,
                    size: 12,
                    color: theme.textSub,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'MAP STYLE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: theme.textSub,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            // ── Toggle row ─────────────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeTab(
                  label: 'Dark',
                  icon: Icons.nights_stay_rounded,
                  isSelected: isDark,
                  onTap: () => controller.setMapThemeDark(true),
                  theme: theme,
                ),
                const SizedBox(width: 4),
                _ThemeTab(
                  label: 'Bright',
                  icon: Icons.wb_sunny_rounded,
                  isSelected: !isDark,
                  onTap: () => controller.setMapThemeDark(false),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─── Theme tab chip ───────────────────────────────────────────
class _ThemeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeController theme;

  const _ThemeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = theme.isDark
        ? const Color(0xFF0D47A1)
        : const Color(0xFFE8F4FF);
    final selectedFg = theme.isDark
        ? Colors.white
        : const Color(0xFF0D47A1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? selectedFg : theme.textSub,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedFg : theme.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google Map Layer ─────────────────────────────────────────
class _GoogleMapLayer extends GetView<FlightController> {
  final AppThemeController theme;

  const _GoogleMapLayer({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GoogleMap(
      onMapCreated: controller.onMapCreated,
      onCameraMove: controller.onCameraMove,
      onCameraIdle: controller.onCameraIdle,
      onTap: (_) => controller.clearSelection(),
      initialCameraPosition: CameraPosition(
        target: controller.initialCameraPosition,
        zoom: controller.initialZoom,
      ),
      markers: controller.markers.value,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
    ));
  }
}

// ─── Top Bar ─────────────────────────────────────────────────
class _TopBar extends GetView<FlightController> {
  final AppThemeController theme;

  const _TopBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 12,
          20,
          12,
        ),
        decoration: BoxDecoration(
          gradient: theme.topBarGradient,
        ),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Get.back(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: theme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SkyTracker',
                  style: TextStyle(
                    color: theme.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Live Flight Radar',
                  style: TextStyle(
                    color: theme.textSub,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Search button
            GestureDetector(
              onTap: controller.openSearch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search,
                  color: theme.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            _FlightCountBadge(theme: theme),
          ],
        ),
      );
    });
  }
}

class _FlightCountBadge extends GetView<FlightController> {
  final AppThemeController theme;

  const _FlightCountBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: theme.cardDecoration(radius: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: controller.isRefreshing.value
                    ? theme.loading
                    : theme.online,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${controller.flightCount.value} flights',
              style: TextStyle(
                color: theme.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Control FABs ─────────────────────────────────────────────
class _ControlFabs extends GetView<FlightController> {
  final bool miniSize;
  final AppThemeController theme;

  const _ControlFabs({required this.miniSize, required this.theme});

  @override
  Widget build(BuildContext context) {
    final size = miniSize ? 36.0 : 44.0;
    final iconSize = miniSize ? 16.0 : 20.0;

    return Obx(() {
      controller.count.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FabButton(
            icon: Icons.my_location,
            onTap: controller.centerOnUser,
            tooltip: 'My Location',
            theme: theme,
            size: size,
            iconSize: iconSize,
          ),
          SizedBox(height: miniSize ? 6 : 10),
          _FabButton(
            icon: Icons.refresh,
            onTap: controller.manualRefresh,
            tooltip: 'Refresh',
            theme: theme,
            size: size,
            iconSize: iconSize,
          ),
        ],
      );
    });
  }
}

class _FabButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final AppThemeController theme;
  final double size;
  final double iconSize;

  const _FabButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.theme,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: theme.fabDecoration(),
          child: Icon(
            icon,
            color: theme.iconActive,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final AppThemeController theme;

  const _ErrorBanner({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.errorBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.errorText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}