// lib/common/stats_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/FlightMap/controllers/flight_map_controller.dart';
import 'app_theme_controller.dart';

class StatsBar extends GetView<FlightController> {
  final AppThemeController theme;

  const StatsBar({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: controller.flightCount.value > 0 ? 1 : 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.card.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.border),
              boxShadow: theme.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Stat(
                  icon: Icons.flight,
                  value: controller.statsAirborne.value.toString(),
                  label: 'airborne',
                  color: const Color(0xFF4D9EFF),
                  theme: theme,
                ),
                _Divider(theme: theme),
                _Stat(
                  icon: Icons.airline_seat_recline_extra,
                  value: controller.statsGround.value.toString(),
                  label: 'ground',
                  color: const Color(0xFF90A4AE),
                  theme: theme,
                ),
                _Divider(theme: theme),
                _Stat(
                  icon: Icons.access_time,
                  value: controller.lastUpdated.value != null
                      ? _ago(controller.lastUpdated.value!)
                      : '—',
                  label: 'updated',
                  color: const Color(0xFF66BB6A),
                  theme: theme,
                ),
                if (controller.isRefreshing.value) ...[
                  _Divider(theme: theme),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: theme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  String _ago(DateTime dt) {
    final sec = DateTime.now().difference(dt).inSeconds;
    if (sec < 5) return 'just now';
    if (sec < 60) return '${sec}s ago';
    return '${sec ~/ 60}m ago';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AppThemeController theme;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.textMain,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(color: theme.textSub, fontSize: 10),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final AppThemeController theme;

  const _Divider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: theme.divider,
    );
  }
}
