import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/notification_for_nav_bar_controller.dart';


import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';


// ─── Type / severity helpers ──────────────────────────────────────────────────
class _N {
  static Color severityColor(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'critical':
        return const Color(0xFFEA4658);
      case 'high':
      case 'warning':
        return const Color(0xFFEBC240);
      default:
        return primaryColor2;
    }
  }

  static IconData typeIcon(String? t) {
    switch ((t ?? '').toLowerCase()) {
      case 'notam':
        return Icons.warning_amber_rounded;
      case 'weather':
        return Icons.cloud_outlined;
      case 'forecast':
        return Icons.wb_sunny_outlined;
      case 'airport':
        return Icons.flight_outlined;
      case 'metar':
        return Icons.air_outlined;
      case 'tip':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color typeColor(String? t) {
    switch ((t ?? '').toLowerCase()) {
      case 'notam':
        return const Color(0xFFEA4658);
      case 'weather':
        return primaryColor2;
      case 'forecast':
        return const Color(0xFFEBC240);
      case 'airport':
        return const Color(0xff23F8A1);
      case 'metar':
        return const Color(0xff2DC587);
      case 'tip':
        return const Color(0xFFEBC240);
      default:
        return primaryColor2;
    }
  }

  static String formatTime(String? ts) {
    if (ts == null || ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  static String formatFullTime(String? ts) {
    if (ts == null || ts.isEmpty) return '';
    try {
      final dt = DateTime.parse(ts).toLocal();
      return '${dt.day.toString().padLeft(2, '0')} '
          '${_monthName(dt.month)} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }

  static String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m - 1];
  }
}

class NotificationForNavBarView
    extends GetView<NotificationForNavBarController> {
  const NotificationForNavBarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
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
                _TopBar(),
                SizedBox(height: 6.px),
                _TitleRow(),
                SizedBox(height: 10.px),
                Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends GetView<NotificationForNavBarController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // InkWell(
              //   onTap: () => Get.back(),
              //   child: CommonWidgets.appIconsSvg(
              //       assetName: IconConstants.icBackRound,
              //       height: 31.px,
              //       width: 31.px),
              // ),
              SizedBox(width: 8.px),
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
                            color: Colors.black26),
                      ],
                    ),
                  )),
                  Obx(() => Text(
                    cityOne.value,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.px,
                        fontWeight: FontWeight.w400),
                  )),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
            child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icAiSetting,
                height: 32.px,
                width: 32.px,
                color: primary3Color),
          ),
        ],
      ),
    );
  }
}

// ─── Title Row ────────────────────────────────────────────────────────────────
class _TitleRow extends GetView<NotificationForNavBarController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
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
            "Notifications",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.px,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 10.px),
          Obx(() {
            final u = controller.unreadCount.value;
            if (u == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEA4658),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$u",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            );
          }),
          const Spacer(),
          Obx(() {
            if (controller.notifications.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => controller.markAllRead(),
              child: Text(
                "Mark all read",
                style: TextStyle(
                  color: primaryColor2,
                  fontSize: 12.px,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor2,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _Body extends GetView<NotificationForNavBarController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.inAsyncCall.value) return _ShimmerList();

      if (controller.errorMsg.value.isNotEmpty &&
          controller.notifications.isEmpty) {
        return _ErrorState(
          message: controller.errorMsg.value,
          onRetry: () => controller.refresh(),
        );
      }

      if (controller.notifications.isEmpty) return _EmptyState();

      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: primaryColor2,
        backgroundColor: gradientPurple3,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 4.px),
          itemCount: controller.notifications.length,
          itemBuilder: (_, i) {
            return _NotificationCard(
              item: controller.notifications[i],
              index: i,
            );
          },
        ),
      );
    });
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────
class _NotificationCard extends GetView<NotificationForNavBarController> {
  final NotificationItem item;
  final int index;

  const _NotificationCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final typeColor = _N.typeColor(item.type);
    final severityColor = _N.severityColor(item.severity);
    final isUnread = item.read == false;

    return GestureDetector(
      onTap: () {
        controller.markRead(item.id);
        // Open detail bottom sheet
        _NotificationDetailSheet.show(context, item);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.px),
        decoration: BoxDecoration(
          color: isUnread
              ? typeColor.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? typeColor.withOpacity(0.35)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left severity bar ──────────────────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type icon circle
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: typeColor.withOpacity(0.4), width: 1),
                            ),
                            child: Icon(
                              _N.typeIcon(item.type),
                              color: typeColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 10.px),

                          // Category + title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.category != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: typeColor.withOpacity(0.3),
                                          width: 0.8),
                                    ),
                                    child: Text(
                                      item.category!.toUpperCase(),
                                      style: TextStyle(
                                        color: typeColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 3.px),
                                Text(
                                  item.title ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.px,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 6.px),

                          // Time + unread dot
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: severityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              SizedBox(height: 4.px),
                              Text(
                                _N.formatTime(item.timestamp),
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10.px,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8.px),

                      // Message
                      Text(
                        item.message ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 12.px,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Data chips
                      if (_hasChips(item)) ...[
                        SizedBox(height: 8.px),
                        _DataChips(item: item, typeColor: typeColor),
                      ],

                      // "Tap for details" hint
                      SizedBox(height: 6.px),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Tap for details",
                            style: TextStyle(
                              color: typeColor.withOpacity(0.6),
                              fontSize: 10.px,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 3.px),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 9, color: typeColor.withOpacity(0.6)),
                        ],
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
  }

  bool _hasChips(NotificationItem n) {
    final t = (n.type ?? '').toLowerCase();
    return ['notam', 'metar', 'airport', 'weather'].contains(t) &&
        (n.data?.isNotEmpty ?? false);
  }
}

// ─── Data Chips ───────────────────────────────────────────────────────────────
class _DataChips extends StatelessWidget {
  final NotificationItem item;
  final Color typeColor;

  const _DataChips({required this.item, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    final d = item.data ?? {};
    final chips = <_Chip>[];

    switch ((item.type ?? '').toLowerCase()) {
      case 'notam':
        if (d['icao'] != null) {
          chips.add(_Chip(label: "${d['icao']}", color: typeColor));
        }
        if (d['critical_count'] != null) {
          chips.add(_Chip(
              label: "${d['critical_count']} CRIT",
              color: const Color(0xFFEA4658)));
        }
        if (d['high_count'] != null) {
          chips.add(_Chip(
              label: "${d['high_count']} HIGH",
              color: const Color(0xFFEBC240)));
        }
        if (d['total_notams'] != null) {
          chips.add(_Chip(
              label: "${d['total_notams']} TOTAL", color: Colors.white38));
        }
        break;

      case 'weather':
        if (d['temperature'] != null) {
          chips.add(_Chip(label: "${d['temperature']}°C", color: typeColor));
        }
        if (d['humidity'] != null) {
          chips.add(_Chip(label: "💧 ${d['humidity']}%", color: typeColor));
        }
        if (d['wind_speed_knots'] != null) {
          chips.add(_Chip(
              label: "💨 ${d['wind_speed_knots']} kts", color: typeColor));
        }
        if (d['visibility_km'] != null) {
          chips.add(
              _Chip(label: "👁 ${d['visibility_km']} km", color: typeColor));
        }
        break;

      case 'metar':
        if (d['flight_rules'] != null) {
          final fr = "${d['flight_rules']}";
          chips.add(_Chip(
              label: fr,
              color: fr == 'VFR'
                  ? const Color(0xff23F8A1)
                  : const Color(0xFFEA4658)));
        }
        if (d['wind_speed_knots'] != null) {
          chips.add(_Chip(
              label: "💨 ${d['wind_speed_knots']} kts", color: typeColor));
        }
        if (d['temperature'] != null) {
          chips.add(_Chip(label: "${d['temperature']}°C", color: typeColor));
        }
        if (d['visibility_miles'] != null) {
          chips.add(
              _Chip(label: "👁 ${d['visibility_miles']} mi", color: typeColor));
        }
        break;

      case 'airport':
        if (d['icao'] != null) {
          chips.add(_Chip(label: "${d['icao']}", color: typeColor));
        }
        if (d['distance_km'] != null) {
          chips.add(_Chip(label: "${d['distance_km']} km", color: typeColor));
        }
        break;
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 4, children: chips);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationDetailSheet {
  static void show(BuildContext context, NotificationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheetContent(item: item),
    );
  }
}

class _DetailSheetContent extends StatelessWidget {
  final NotificationItem item;

  const _DetailSheetContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final typeColor = _N.typeColor(item.type);
    final severityColor = _N.severityColor(item.severity);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientPurple2, gradientPurple4, gradientPurple5],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: typeColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: typeColor.withOpacity(0.5), width: 1.5),
                      ),
                      child: Icon(_N.typeIcon(item.type),
                          color: typeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.category != null)
                            Text(
                              item.category!.toUpperCase(),
                              style: TextStyle(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1),
                            ),
                          Text(
                            item.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: severityColor.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        (item.severity ?? 'info').toUpperCase(),
                        style: TextStyle(
                            color: severityColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Timestamp ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      _N.formatFullTime(item.timestamp),
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withOpacity(0.08), height: 1),

              // ── Scrollable content ────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Summary message
                    _SectionBox(
                      color: typeColor,
                      child: Text(
                        item.message ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Type-specific detail sections ─────────────────
                    _buildTypeDetail(item, typeColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeDetail(NotificationItem item, Color typeColor) {
    final d = item.data ?? {};
    final type = (item.type ?? '').toLowerCase();

    switch (type) {
      case 'notam':
        return _NotamDetail(data: d, typeColor: typeColor);
      case 'weather':
        return _WeatherDetail(data: d, typeColor: typeColor);
      case 'forecast':
        return _ForecastDetail(data: d, typeColor: typeColor);
      case 'airport':
        return _AirportDetail(data: d, typeColor: typeColor);
      case 'metar':
        return _MetarDetail(data: d, typeColor: typeColor);
      case 'tip':
        return _TipDetail(data: d, typeColor: typeColor);
      default:
        if (d.isEmpty) return const SizedBox.shrink();
        return _GenericDataSection(data: d, typeColor: typeColor);
    }
  }
}

// ─── NOTAM Detail ─────────────────────────────────────────────────────────────
class _NotamDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _NotamDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    final criticalNotams = (data['critical_notams'] as List<dynamic>?) ?? [];
    final highNotams = (data['high_notams'] as List<dynamic>?) ?? [];
    final lowNotams = (data['low_notams'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary stats row
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: "Total",
                    value: "${data['total_notams'] ?? 0}",
                    color: Colors.white54)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: "Critical",
                    value: "${data['critical_count'] ?? 0}",
                    color: const Color(0xFFEA4658))),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: "High",
                    value: "${data['high_count'] ?? 0}",
                    color: const Color(0xFFEBC240))),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: "Low",
                    value: "${data['low_count'] ?? 0}",
                    color: Colors.white38)),
          ],
        ),

        // Airport info
        if (data['airport_name'] != null) ...[
          const SizedBox(height: 12),
          _InfoTile(
              icon: Icons.flight_outlined,
              label: "Airport",
              value: "${data['airport_name']} (${data['icao'] ?? ''})",
              color: typeColor),
        ],

        // Critical NOTAMs
        if (criticalNotams.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NotamSectionHeader(
              label: "Critical NOTAMs",
              count: criticalNotams.length,
              color: const Color(0xFFEA4658)),
          const SizedBox(height: 8),
          ...criticalNotams.take(10).map((n) => _NotamTile(
              notam: n as Map<String, dynamic>,
              color: const Color(0xFFEA4658))),
          if (criticalNotams.length > 10)
            _MoreIndicator(
                count: criticalNotams.length - 10,
                color: const Color(0xFFEA4658)),
        ],

        // High NOTAMs
        if (highNotams.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NotamSectionHeader(
              label: "High Priority NOTAMs",
              count: highNotams.length,
              color: const Color(0xFFEBC240)),
          const SizedBox(height: 8),
          ...highNotams.take(5).map((n) => _NotamTile(
              notam: n as Map<String, dynamic>,
              color: const Color(0xFFEBC240))),
          if (highNotams.length > 5)
            _MoreIndicator(
                count: highNotams.length - 5, color: const Color(0xFFEBC240)),
        ],

        // Low NOTAMs
        if (lowNotams.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NotamSectionHeader(
              label: "Low Priority NOTAMs",
              count: lowNotams.length,
              color: Colors.white54),
          const SizedBox(height: 8),
          ...lowNotams.take(3).map((n) => _NotamTile(
              notam: n as Map<String, dynamic>, color: Colors.white38)),
          if (lowNotams.length > 3)
            _MoreIndicator(count: lowNotams.length - 3, color: Colors.white38),
        ],
      ],
    );
  }
}

class _NotamSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _NotamSectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Text("$count",
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _NotamTile extends StatefulWidget {
  final Map<String, dynamic> notam;
  final Color color;

  const _NotamTile({required this.notam, required this.color});

  @override
  State<_NotamTile> createState() => _NotamTileState();
}

class _NotamTileState extends State<_NotamTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.notam['id']?.toString() ?? '';
    final description = widget.notam['description']?.toString() ?? '';
    final fullText = widget.notam['full_text']?.toString() ?? '';
    final startTime = widget.notam['start_time']?.toString();
    final endTime = widget.notam['end_time']?.toString();

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(0.2), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      id,
                      style: TextStyle(
                          color: widget.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.color.withOpacity(0.6),
                    size: 18,
                  ),
                ],
              ),
            ),

            // Expanded: validity period + full text
            if (_expanded) ...[
              Divider(
                  color: widget.color.withOpacity(0.15),
                  height: 1,
                  indent: 12,
                  endIndent: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (startTime != null || endTime != null) ...[
                      Row(
                        children: [
                          if (startTime != null)
                            Expanded(
                              child: _MiniInfoRow(
                                  label: "From",
                                  value: _N.formatFullTime(startTime),
                                  color: widget.color),
                            ),
                          if (endTime != null)
                            Expanded(
                              child: _MiniInfoRow(
                                  label: "Until",
                                  value: _N.formatFullTime(endTime),
                                  color: widget.color),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (fullText.isNotEmpty) ...[
                      Text("Full Text",
                          style: TextStyle(
                              color: widget.color.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fullText,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreIndicator extends StatelessWidget {
  final int count;
  final Color color;

  const _MoreIndicator({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Text(
          "+ $count more",
          style: TextStyle(
              color: color.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Weather Detail ───────────────────────────────────────────────────────────
class _WeatherDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _WeatherDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temp hero
        _SectionBox(
          color: typeColor,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['temperature_c'] ?? '--'}°C",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w200),
                    ),
                    Text(
                      "${data['temperature_f'] ?? '--'}°F",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['condition']
                          ?.toString()
                          .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
                          .trim() ??
                          '',
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Feels like",
                      style: TextStyle(color: Colors.white38, fontSize: 10)),
                  Text(
                    "${data['feels_like_c'] ?? '--'}°C",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Grid of weather values
        _DetailGrid(items: [
          _GridItem(
              icon: Icons.water_drop_outlined,
              label: "Humidity",
              value: "${data['humidity'] ?? '--'}%",
              color: typeColor),
          _GridItem(
              icon: Icons.air_outlined,
              label: "Wind",
              value:
              "${data['wind_speed_knots'] ?? '--'} kts ${data['wind_direction'] ?? ''}",
              color: typeColor),
          _GridItem(
              icon: Icons.visibility_outlined,
              label: "Visibility",
              value: "${data['visibility_km'] ?? '--'} km",
              color: typeColor),
          _GridItem(
              icon: Icons.compress_outlined,
              label: "Pressure",
              value: "${data['pressure_hpa'] ?? '--'} hPa",
              color: typeColor),
          _GridItem(
              icon: Icons.thermostat_outlined,
              label: "Dew Point",
              value: "${data['dew_point_c'] ?? '--'}°C",
              color: typeColor),
          _GridItem(
              icon: Icons.cloud_outlined,
              label: "Cloudiness",
              value: "${data['cloudiness'] ?? '--'}%",
              color: typeColor),
        ]),

        // Sunrise / sunset
        if (data['sunrise'] != null || data['sunset'] != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (data['sunrise'] != null)
                Expanded(
                    child: _InfoTile(
                        icon: Icons.wb_twilight_outlined,
                        label: "Sunrise",
                        value: data['sunrise'],
                        color: const Color(0xFFEBC240))),
              if (data['sunset'] != null)
                Expanded(
                    child: _InfoTile(
                        icon: Icons.nights_stay_outlined,
                        label: "Sunset",
                        value: data['sunset'],
                        color: const Color(0xFF7B8CFF))),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Forecast Detail ──────────────────────────────────────────────────────────
class _ForecastDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _ForecastDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    final hourly = (data['hourly_breakdown'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // High / Low summary
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: "High",
                    value: "${data['max_temp_c'] ?? '--'}°C",
                    color: const Color(0xFFEA4658))),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: "Low",
                    value: "${data['min_temp_c'] ?? '--'}°C",
                    color: const Color(0xFF7B8CFF))),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: "Rain",
                    value: (data['rain_expected'] == true) ? "Yes" : "No",
                    color: (data['rain_expected'] == true)
                        ? const Color(0xFF7B8CFF)
                        : Colors.white38)),
          ],
        ),

        if (hourly.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel(label: "Hourly Breakdown", color: typeColor),
          const SizedBox(height: 8),
          ...hourly.map((h) => _HourlyForecastTile(
              hour: h as Map<String, dynamic>, color: typeColor)),
        ],
      ],
    );
  }
}

class _HourlyForecastTile extends StatelessWidget {
  final Map<String, dynamic> hour;
  final Color color;

  const _HourlyForecastTile({required this.hour, required this.color});

  @override
  Widget build(BuildContext context) {
    final cond = hour['condition']?.toString() ?? '';
    final emoji = cond.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.12), width: 0.8),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour['time']?.toString() ?? '',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  hour['date_label']?.toString() ?? '',
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Emoji
          // Text(emoji.isEmpty ? '🌡' : emoji,
          //     style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          // Temp
          Text(
            "${hour['temperature_c'] ?? '--'}°C",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const Spacer(),
          // Humidity + wind
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "💧 ${hour['humidity'] ?? '--'}%",
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
              Text(
                "💨 ${hour['wind_speed_knots'] ?? '--'} kts",
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Airport Detail ───────────────────────────────────────────────────────────
class _AirportDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _AirportDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionBox(
          color: typeColor,
          child: Column(
            children: [
              _InfoTile(
                  icon: Icons.flight_outlined,
                  label: "ICAO",
                  value: data['icao']?.toString() ?? '--',
                  color: typeColor),
              _InfoTile(
                  icon: Icons.business_outlined,
                  label: "Airport",
                  value: data['name']?.toString() ?? '--',
                  color: typeColor),
              _InfoTile(
                  icon: Icons.location_city_outlined,
                  label: "City",
                  value: "${data['city'] ?? '--'}, ${data['country'] ?? ''}",
                  color: typeColor),
              _InfoTile(
                  icon: Icons.height_outlined,
                  label: "Elevation",
                  value: "${data['elevation_ft'] ?? '--'} ft",
                  color: typeColor),
              _InfoTile(
                  icon: Icons.near_me_outlined,
                  label: "Distance",
                  value: "${data['distance_km'] ?? '--'} km",
                  color: typeColor),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── METAR Detail ─────────────────────────────────────────────────────────────
class _MetarDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _MetarDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    final fr = data['flight_rules']?.toString() ?? '';
    final frColor =
    fr == 'VFR' ? const Color(0xff23F8A1) : const Color(0xFFEA4658);
    final clouds = (data['clouds'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight rules hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: frColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: frColor.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: frColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: frColor.withOpacity(0.6), width: 1.5),
                ),
                child: Text(
                  fr,
                  style: TextStyle(
                      color: frColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fr == 'VFR'
                      ? "Visual Flight Rules\nConditions are favorable"
                      : "Instrument Flight Rules\nReduced visibility conditions",
                  style: TextStyle(
                      color: frColor.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // METAR data grid
        _DetailGrid(items: [
          _GridItem(
              icon: Icons.air_outlined,
              label: "Wind Speed",
              value: "${data['wind_speed_knots'] ?? '--'} kts",
              color: typeColor),
          _GridItem(
              icon: Icons.explore_outlined,
              label: "Wind Direction",
              value: "${data['wind_direction_deg'] ?? '--'}°",
              color: typeColor),
          _GridItem(
              icon: Icons.visibility_outlined,
              label: "Visibility",
              value: "${data['visibility_miles'] ?? '--'} mi",
              color: typeColor),
          _GridItem(
              icon: Icons.thermostat_outlined,
              label: "Temperature",
              value: "${data['temperature_c'] ?? '--'}°C",
              color: typeColor),
          _GridItem(
              icon: Icons.water_drop_outlined,
              label: "Dewpoint",
              value: "${data['dewpoint_c'] ?? '--'}°C",
              color: typeColor),
          _GridItem(
              icon: Icons.compress_outlined,
              label: "Altimeter",
              value: "${data['altimeter_inhg'] ?? '--'} inHg",
              color: typeColor),
        ]),

        // Raw METAR
        if (data['raw_metar'] != null) ...[
          const SizedBox(height: 12),
          _SectionLabel(label: "Raw METAR", color: typeColor),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              data['raw_metar'],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],

        // Cloud layers
        if (clouds.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionLabel(label: "Cloud Layers", color: typeColor),
          const SizedBox(height: 6),
          ...clouds.map((c) {
            final cloud = c as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: typeColor.withOpacity(0.15), width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_outlined, color: typeColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    cloud['type']?.toString() ?? '--',
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    "${cloud['altitude_ft'] ?? '--'} ft",
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ─── Tip Detail ───────────────────────────────────────────────────────────────
class _TipDetail extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _TipDetail({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      color: typeColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['tip_category'] != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['tip_category'].toString().toUpperCase(),
                style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (data['tip_title'] != null)
            Text(
              data['tip_title'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: 8),
          if (data['tip_message'] != null)
            Text(
              data['tip_message'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Generic fallback ─────────────────────────────────────────────────────────
class _GenericDataSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color typeColor;

  const _GenericDataSection({required this.data, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      color: typeColor,
      child: Column(
        children: data.entries.map((e) {
          final val = e.value?.toString() ?? '';
          if (val.isEmpty || val == 'null') return const SizedBox.shrink();
          return _MiniInfoRow(
              label: e.key.replaceAll('_', ' '), value: val, color: typeColor);
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared small widgets used inside detail sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionBox extends StatelessWidget {
  final Color color;
  final Widget child;

  const _SectionBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 0.8),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 14),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniInfoRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${label.capitalizeFirst}: ",
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25), width: 0.8),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_GridItem> items;

  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: item.color.withOpacity(0.2), width: 0.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: item.color.withOpacity(0.7), size: 16),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: TextStyle(
                    color: item.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.label,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _GridItem(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────
class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF3C3C98).withOpacity(0.45),
        highlightColor: Colors.white.withOpacity(0.25),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xff2B2B6E),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.notifications_off_outlined,
              color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text("No notifications yet",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
          Text("You're all caught up!",
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor2.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: primaryColor2.withOpacity(0.5), width: 1),
                ),
                child: const Text("Retry",
                    style: TextStyle(
                        color: primaryColor2,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
