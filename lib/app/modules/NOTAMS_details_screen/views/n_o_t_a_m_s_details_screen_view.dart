import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_models/get_details_notams.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/n_o_t_a_m_s_details_screen_controller.dart';

// ─── Criticality helpers ─────────────────────────────────────────────────────
class _C {
  static Color border(String c) {
    switch (c.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEA4658);
      case 'high':
        return const Color(0xFFEBC240);
      default:
        return const Color(0xff23F8A1);
    }
  }

  static Color bg(String c) => border(c).withOpacity(0.14);

  static IconData icon(String c) {
    switch (c.toLowerCase()) {
      case 'critical':
        return Icons.warning_rounded;
      case 'high':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  static String label(String c) => c.toUpperCase();
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class NOTAMSDetailsScreenView extends GetView<NOTAMSDetailsScreenController> {
  const NOTAMSDetailsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final airportCode =
        controller.parameters[ApiKeyConstants.airportCode] ?? '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientPurple1,
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5,
            ],
          ),
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                _TopBar(),
                SizedBox(height: 4.px),

                // ── Airport header + filter (reactive) ───────────────────
                Obx(() {
                  if (controller.inAsyncCall.value) {
                    return _headerShimmer();
                  }
                  if (controller.notamsList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _AirportHeaderCard(
                        airportCode: airportCode,
                        notams: controller.notamsList,
                      ),
                      SizedBox(height: 10.px),
                      _FilterChipBar(),
                      SizedBox(height: 6.px),
                    ],
                  );
                }),

                // ── NOTAM list ───────────────────────────────────────────
                Expanded(
                  child: Obx(() {
                    if (controller.inAsyncCall.value) {
                      return _listShimmer();
                    }
                    if (controller.filteredNotams.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.refetchData,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 20),
                            Center(
                                child:
                                    _emptyState(controller.activeFilter.value)),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.refetchData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.px, vertical: 4.px),
                        itemCount: controller.filteredNotams.length,
                        itemBuilder: (_, i) => _NotamDetailCard(
                          notam: controller.filteredNotams[i],
                          index: i + 1,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerShimmer() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.px),
    child: Shimmer.fromColors(
      baseColor: const Color(0xFF3C3C98).withOpacity(0.45),
      highlightColor: Colors.white.withOpacity(0.25),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xff2B2B6E),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  );

  Widget _listShimmer() => ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 4.px),
    itemCount: 4,
    itemBuilder: (_, __) => Shimmer.fromColors(
      baseColor: const Color(0xFF3C3C98).withOpacity(0.45),
      highlightColor: Colors.white.withOpacity(0.25),
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xff2B2B6E),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _emptyState(String filter) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off_rounded,
            color: Colors.white24, size: 48.px),
        SizedBox(height: 12.px),
        Text(
          filter == 'all'
              ? "No NOTAMs found"
              : "No ${filter.toUpperCase()} NOTAMs",
          style: TextStyle(color: Colors.white38, fontSize: 14.px),
        ),
      ],
    ),
  );
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends GetView<NOTAMSDetailsScreenController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icBackRound,
                height: 31.px,
                width: 31.px),
          ),
          const Spacer(),
          Obx(() => controller.isOffline.value
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Offline Mode: Data Cached",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600),
                  ),
                )
              : const SizedBox.shrink()),
          SizedBox(width: 8.px),
          InkWell(
            onTap: () => Get.toNamed(
              Routes.SETTING_FOR_BACK,
            ),
            child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icMenuSettingColor,
                height: 28.px,
                width: 28.px),
          ),
          SizedBox(width: 10.px),
          InkWell(
            onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
            child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icAiSetting,
                height: 32.px,
                width: 32.px,
                color: primary3Color),
          ),
          SizedBox(width: 10.px),
          InkWell(
            onTap: () => Get.toNamed(Routes.NOTIFICATION_SCREEN),
            child: CommonWidgets.appIcons(
                assetName: IconConstants.icNotificationTop,
                height: 24.px,
                width: 24.px),
          ),
          // SizedBox(width: 10.px),
          // CommonWidgets.appIcons(
          //     assetName: IconConstants.icUploadMenu,
          //     height: 28.px,
          //     width: 28.px),
        ],
      ),
    );
  }
}

// ─── Airport Header Card ──────────────────────────────────────────────────────
class _AirportHeaderCard extends StatelessWidget {
  final String airportCode;
  final List<Notams> notams;

  const _AirportHeaderCard({
    required this.airportCode,
    required this.notams,
  });

  @override
  Widget build(BuildContext context) {
    int critical = 0, high = 0, low = 0;
    for (final n in notams) {
      switch ((n.criticality ?? '').toLowerCase()) {
        case 'critical':
          critical++;
          break;
        case 'high':
          high++;
          break;
        default:
          low++;
      }
    }
    final Color accent = critical > 0
        ? const Color(0xFFEA4658)
        : high > 0
        ? const Color(0xFFEBC240)
        : const Color(0xff23F8A1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.px),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.px),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.4), width: 1.2),
        ),
        child: Row(
          children: [
            // ICAO badge
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.px, vertical: 10.px),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent, width: 1.2),
              ),
              child: Column(
                children: [
                  Text(
                    airportCode,
                    style: TextStyle(
                      color: accent,
                      fontSize: 18.px,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "ICAO",
                    style: TextStyle(
                      color: accent.withOpacity(0.7),
                      fontSize: 9.px,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.px),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NOTAM Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.px,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8.px),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _StatBadge(
                          count: notams.length,
                          label: "TOTAL",
                          color: Colors.white54),
                      if (critical > 0)
                        _StatBadge(
                            count: critical,
                            label: "CRIT",
                            color: const Color(0xFFEA4658)),
                      if (high > 0)
                        _StatBadge(
                            count: high,
                            label: "HIGH",
                            color: const Color(0xFFEBC240)),
                      if (low > 0)
                        _StatBadge(
                            count: low,
                            label: "LOW",
                            color: const Color(0xff23F8A1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$count",
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ─── Filter Chip Bar — driven entirely by controller.activeFilter ─────────────
class _FilterChipBar extends GetView<NOTAMSDetailsScreenController> {
  const _FilterChipBar();

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'critical', 'high', 'low'];

    return SizedBox(
      height: 38,
      child: Obx(() {
        // Reading activeFilter inside Obx means chips repaint on every change
        final current = controller.activeFilter.value;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.px),
          itemCount: filters.length,
          itemBuilder: (_, i) {
            final f = filters[i];
            final isSelected = current == f;

            final Color color = f == 'all'
                ? primaryColor2
                : f == 'critical'
                ? const Color(0xFFEA4658)
                : f == 'high'
                ? const Color(0xFFEBC240)
                : const Color(0xff23F8A1);

            final String chipLabel = f == 'all'
                ? 'ALL'
                : f == 'critical'
                ? '🔴  CRITICAL'
                : f == 'high'
                ? '🟡  HIGH'
                : '🟢  LOW';

            return GestureDetector(
              // ✅ Directly call controller — no local state involved
              onTap: () => controller.filterNotams(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.22)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white54,
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Individual NOTAM Detail Card ─────────────────────────────────────────────
class _NotamDetailCard extends StatefulWidget {
  final Notams notam;
  final int index;

  const _NotamDetailCard({required this.notam, required this.index});

  @override
  State<_NotamDetailCard> createState() => _NotamDetailCardState();
}

class _NotamDetailCardState extends State<_NotamDetailCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final crit = widget.notam.criticality ?? 'low';
    final critColor = _C.border(crit);
    final description = widget.notam.description ?? '';
    final isLong = description.length > 120;

    // ── Time parsing ─────────────────────────────────────────────────────────
    String startStr = '';
    String endStr = '';
    String duration = '';

    final rawStart = widget.notam.startTime;
    final rawEnd = widget.notam.endTime;

    if (rawStart != null && rawStart.isNotEmpty) {
      try {
        final start = DateTime.parse(rawStart).toLocal();
        startStr = _fmtFull(start);
        if (rawEnd != null && rawEnd.isNotEmpty) {
          final end = DateTime.parse(rawEnd).toLocal();
          endStr = _fmtFull(end);
          final diff = end.difference(start);
          duration = diff.inDays > 0
              ? "${diff.inDays}d ${diff.inHours % 24}h"
              : "${diff.inHours}h ${diff.inMinutes % 60}m";
        }
      } catch (_) {
        startStr = rawStart;
        endStr = rawEnd ?? '';
      }
    }

    final String? loc = widget.notam.location;

    return Container(
      margin: EdgeInsets.only(bottom: 12.px),
      decoration: BoxDecoration(
        color: const Color(0xffAAA5A5).withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: critColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 14.px, vertical: 12.px),
            decoration: BoxDecoration(
              color: critColor.withOpacity(0.08),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Index circle
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: critColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: critColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    "${widget.index}",
                    style: TextStyle(
                        color: critColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(width: 10.px),

                // Criticality badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.bg(crit),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: critColor.withOpacity(0.7), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_C.icon(crit), color: critColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _C.label(crit),
                        style: TextStyle(
                          color: critColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Location chip (only if present)
                if (loc != null && loc.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor2.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: primaryColor2.withOpacity(0.4),
                          width: 0.8),
                    ),
                    child: Text(
                      loc,
                      style: const TextStyle(
                        color: primaryColor2,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Time window (only if present) ────────────────────────────────
          if (startStr.isNotEmpty)
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.px, vertical: 8.px),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.07), width: 1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: Colors.white38, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: startStr,
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500),
                      ),
                      if (endStr.isNotEmpty) ...[
                        const TextSpan(
                            text: "  →  ",
                            style: TextStyle(
                                color: Colors.white30, fontSize: 10.5)),
                        TextSpan(
                          text: endStr,
                          style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ])),
                  ),
                  if (duration.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(duration,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

          // ── Format + title ───────────────────────────────────────────────
          if (widget.notam.format != null || widget.notam.title != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.px, vertical: 8.px),
              child: Row(
                children: [
                  if (widget.notam.format != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xff2AB1FB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: const Color(0xff2AB1FB)
                                .withOpacity(0.3),
                            width: 0.8),
                      ),
                      child: Text(
                        widget.notam.format!,
                        style: const TextStyle(
                          color: Color(0xff2AB1FB),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (widget.notam.title != null)
                    Expanded(
                      child: Text(
                        widget.notam.title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.px,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

          // ── Description ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.px),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: critColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "NOTAM TEXT",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9.5.px,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.px),

                // Description text with expand/collapse
                AnimatedCrossFade(
                  firstChild: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.px,
                      height: 1.6,
                      fontFamily: 'monospace',
                    ),
                  ),
                  secondChild: Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.px,
                      height: 1.6,
                      fontFamily: 'monospace',
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),

                if (isLong) ...[
                  SizedBox(height: 6.px),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Row(
                      children: [
                        Text(
                          _expanded
                              ? "Show less"
                              : "Show full NOTAM",
                          style: TextStyle(
                            color: primaryColor2,
                            fontSize: 11.px,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryColor2,
                          ),
                        ),
                        SizedBox(width: 4.px),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: primaryColor2,
                              size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 12.px),
        ],
      ),
    );
  }

  String _fmtFull(DateTime dt) {
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return "${_p(dt.day)} ${months[dt.month]} ${dt.year} ${_p(dt.hour)}${_p(dt.minute)}Z";
  }

  String _p(int v) => v.toString().padLeft(2, '0');
}