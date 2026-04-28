import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_models/get_notam_by_airport_code.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';
import '../controllers/notam_for_back_controller.dart';

// ─── Criticality config ───────────────────────────────────────────────────────
class _Crit {
  static Color bgColor(String c) {
    switch (c.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEA4658).withOpacity(0.18);
      case 'high':
        return const Color(0xFFEBC240).withOpacity(0.18);
      default:
        return const Color(0xff2DC587).withOpacity(0.18);
    }
  }

  static Color borderColor(String c) {
    switch (c.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEA4658);
      case 'high':
        return const Color(0xFFEBC240);
      default:
        return const Color(0xff23F8A1);
    }
  }

  static Color labelColor(String c) => borderColor(c);

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

// ─── Main Screen ──────────────────────────────────────────────────────────────

class NotamForBackView extends GetView<NotamForBackController> {
  const NotamForBackView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<NotamForBackController>(() => NotamForBackController());

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
                  gradientPurple1,
                  gradientPurple2,
                  gradientPurple3,
                  gradientPurple4,
                  gradientPurple5,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ─── Top Bar ──────────────────────────────────────────────
                  _TopBar(),
                  SizedBox(height: 8.px),

                  // ─── Title Row ────────────────────────────────────────────
                  _TitleRow(),
                  SizedBox(height: 12.px),

                  // ─── Body ─────────────────────────────────────────────────
                  Expanded(child: _Body()),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends GetView<NotamForBackController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location
          Row(
            children: [
              InkWell(
                child: CommonWidgets.appIconsSvg(
                    assetName: IconConstants.icBackRound,
                    height: 31.px,
                    width: 31.px),
                onTap: () {
                  Get.back();
                },
              ),
              SizedBox(width: 10.px),
              CommonWidgets.appIcons(
                assetName: IconConstants.icLocationLite,
                height: 31.px,
                width: 31.px,
              ),
              SizedBox(width: 6.px),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        userName.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.px,
                          shadows: const [
                            Shadow(
                                offset: Offset(0, 4),
                                blurRadius: 10,
                                color: Colors.black26)
                          ],
                        ),
                      )),
                  Obx(() => Text(
                        cityOne.value,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.px,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              ),
            ],
          ),
          // Actions
          Row(
            children: [
              InkWell(
                onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
                child: CommonWidgets.appIconsSvg(
                    assetName: IconConstants.icAiSetting,
                    height:32.px,
                    width: 32.px,
                    color: primary3Color),
              ),
              SizedBox(width: 10.px),
              InkWell(
                onTap: () => Get.toNamed(Routes.NOTIFICATION_SCREEN),
                child: CommonWidgets.appIcons(
                    assetName: IconConstants.icNotificationTop,
                    height: 26.px,
                    width: 26.px),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Title Row ────────────────────────────────────────────────────────────────

class _TitleRow extends GetView<NotamForBackController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Vertical accent bar
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10.px),
          Text(
            "NOTAMs",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.px,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Settings icon
          InkWell(
            onTap: () => Get.toNamed(
              Routes.SETTING_FOR_BACK,
            ),
            child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icMenuSettingColor,
                height: 28.px,
                width: 28.px),
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

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends GetView<NotamForBackController> {
  @override
  Widget build(BuildContext context) {
    if (controller.inAsyncCall.value) {
      return _ShimmerList();
    }

    final data = controller.getNotamData;
    if (data == null || data.isEmpty) {
      return Center(child: CommonWidgets.dataNotFound());
    }

    // ── Group by airport location ──────────────────────────────────────────
    final Map<String, List<Data>> grouped = {};
    for (final item in data) {
      final loc = item.location ?? 'UNKNOWN';
      grouped.putIfAbsent(loc, () => []).add(item);
    }

    // ── Count criticalities per airport ───────────────────────────────────
    Map<String, int> critCount(List<Data> items) {
      int critical = 0, high = 0, low = 0;
      for (final i in items) {
        switch ((i.criticality ?? '').toLowerCase()) {
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
      return {'critical': critical, 'high': high, 'low': low};
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 4.px),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final airport = grouped.keys.elementAt(index);
        final items = grouped[airport]!;
        final counts = critCount(items);
        return _AirportSection(
          airport: airport,
          items: items,
          counts: counts,
        );
      },
    );
  }
}

// ─── Airport Section Card ─────────────────────────────────────────────────────

class _AirportSection extends StatefulWidget {
  final String airport;
  final List<Data> items;
  final Map<String, int> counts;

  const _AirportSection({
    required this.airport,
    required this.items,
    required this.counts,
  });

  @override
  State<_AirportSection> createState() => _AirportSectionState();
}

class _AirportSectionState extends State<_AirportSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasCritical = (widget.counts['critical'] ?? 0) > 0;
    final hasHigh = (widget.counts['high'] ?? 0) > 0;

    // Determine the dominant criticality color for airport header accent
    final Color accentColor = hasCritical
        ? const Color(0xFFEA4658)
        : hasHigh
            ? const Color(0xFFEBC240)
            : const Color(0xff23F8A1);

    return Container(
      margin: EdgeInsets.only(bottom: 14.px),
      decoration: BoxDecoration(
        color: const Color(0xffAAA5A5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // ── Airport Header ───────────────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 14.px),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Airport ICAO badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.px, vertical: 6.px),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor, width: 1),
                    ),
                    child: Text(
                      widget.airport,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 15.px,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.px),

                  // Total NOTAM count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.items.length} NOTAM${widget.items.length != 1 ? 's' : ''}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.px,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.px),
                        // Criticality pill row
                        Row(
                          children: [
                            if ((widget.counts['critical'] ?? 0) > 0)
                              _CritPill(
                                count: widget.counts['critical']!,
                                label: 'CRIT',
                                color: const Color(0xFFEA4658),
                              ),
                            if ((widget.counts['high'] ?? 0) > 0) ...[
                              SizedBox(width: 6.px),
                              _CritPill(
                                count: widget.counts['high']!,
                                label: 'HIGH',
                                color: const Color(0xFFEBC240),
                              ),
                            ],
                            if ((widget.counts['low'] ?? 0) > 0) ...[
                              SizedBox(width: 6.px),
                              _CritPill(
                                count: widget.counts['low']!,
                                label: 'LOW',
                                color: const Color(0xff23F8A1),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white60,
                      size: 24.px,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── NOTAM Items (collapsed/expanded) ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(
                  color: accentColor.withOpacity(0.2),
                  height: 1,
                  thickness: 1,
                ),
                ...widget.items.asMap().entries.map((entry) {
                  final isLast = entry.key == widget.items.length - 1;
                  return _NotamRow(
                    item: entry.value,
                    isLast: isLast,
                  );
                }),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

// ─── Criticality Pill ─────────────────────────────────────────────────────────

class _CritPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CritPill({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            "$count $label",
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual NOTAM Row ─────────────────────────────────────────────────────

class _NotamRow extends GetView<NotamForBackController> {
  final Data item;
  final bool isLast;

  const _NotamRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final crit = item.criticality ?? 'low';
    final critColor = _Crit.borderColor(crit);

    // Format time window
    String timeWindow = '';
    if (item.startTime != null) {
      try {
        final start = DateTime.parse(item.startTime!).toLocal();
        final end = item.endTime != null
            ? DateTime.parse(item.endTime!).toLocal()
            : null;
        timeWindow = "${_fmt(start)}${end != null ? ' → ${_fmt(end)}' : ''}";
      } catch (_) {
        timeWindow = item.startTime ?? '';
      }
    }

    return InkWell(
      onTap: () {
        Map<String, String> params = {
          'airportCode': item.location ?? '',
          'warnings': crit,
        };
        Get.toNamed(Routes.N_O_T_A_M_S_DETAILS_SCREEN, parameters: params);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 14.px),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(20))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Criticality indicator bar ──────────────────────────────────
            Container(
              width: 3,
              height: 54,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: critColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Criticality badge + time
                  Row(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _Crit.bgColor(crit),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: critColor.withOpacity(0.6), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_Crit.icon(crit), color: critColor, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              _Crit.label(crit),
                              style: TextStyle(
                                color: critColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (timeWindow.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeWindow,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 9.5.px,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 6.px),

                  // Description (2 lines preview)
                  Text(
                    item.description ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 11.5.px,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6.px),

                  // "View full NOTAM" link
                  Text(
                    "View full NOTAM →",
                    style: TextStyle(
                      color: primaryColor2,
                      fontSize: 11.px,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: primaryColor2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      "${dt.year.toString().substring(2)}/${_p(dt.month)}/${_p(dt.day)} ${_p(dt.hour)}${_p(dt.minute)}Z";

  String _p(int v) => v.toString().padLeft(2, '0');
}

// ─── Shimmer Loader ───────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF3C3C98).withOpacity(0.45),
        highlightColor: Colors.white.withOpacity(0.3),
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xff2B2B6E),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
