import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../controllers/notification_screen_controller.dart';

// ══════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════

class NotificationScreenView extends GetView<NotificationScreenController> {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(NotificationScreenController());

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

// ══════════════════════════════════════════════════════════════════════════
// TOP BAR
// ══════════════════════════════════════════════════════════════════════════

class _TopBar extends GetView<NotificationScreenController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  width: 31.px,
                  height: 31.px,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 18.px),
                ),
              ),
              SizedBox(width: 12.px),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.px,
                    ),
                  ),
                  Obx(() => Text(
                    controller.notifications.isEmpty
                        ? "Loading..."
                        : "${controller.notifications.length} items",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.px,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
                ],
              ),
            ],
          ),
          Obx(() {
            if (controller.notifications.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => controller.refresh(),
              child: Container(
                width: 32.px,
                height: 32.px,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh, color: Colors.white, size: 18),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// TITLE ROW
// ══════════════════════════════════════════════════════════════════════════

class _TitleRow extends GetView<NotificationScreenController> {
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
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10.px),
          Text(
            "All Notifications",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.px,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10.px),
          Obx(() {
            final u = controller.unreadCount.value;
            if (u == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$u",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
          const Spacer(),
          Obx(() {
            if (controller.notifications.isEmpty || controller.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => controller.markAllRead(),
              child: Text(
                "Mark all read",
                style: TextStyle(
                  color: const Color(0xFF00E5FF),
                  fontSize: 11.px,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BODY
// ══════════════════════════════════════════════════════════════════════════

class _Body extends GetView<NotificationScreenController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.inAsyncCall.value) {
        return _ShimmerList();
      }

      // Error state
      if (controller.errorMsg.value.isNotEmpty && controller.notifications.isEmpty) {
        return _ErrorState(
          message: controller.errorMsg.value,
          onRetry: () => controller.refresh(),
        );
      }

      // Empty state
      if (controller.notifications.isEmpty) {
        return _EmptyState();
      }

      // Data loaded
      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xFF7B1FA2),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 4.px),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            return _NotificationCard(
              item: controller.notifications[index],
              index: index,
            );
          },
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════
// NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════

class _NotificationCard extends GetView<NotificationScreenController> {
  final NotificationItem item;
  final int index;

  const _NotificationCard({required this.item, required this.index});

  Color _getTypeColor() {
    switch ((item.type ?? '').toLowerCase()) {
      case 'notam':
        return const Color(0xFFFF5252);
      case 'weather':
        return const Color(0xFF00E5FF);
      case 'forecast':
        return const Color(0xFFFFD740);
      case 'airport':
        return const Color(0xFF00E676);
      case 'metar':
        return const Color(0xFF00BFA5);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  Color _getSeverityColor() {
    switch ((item.severity ?? '').toLowerCase()) {
      case 'critical':
        return const Color(0xFFFF5252);
      case 'warning':
      case 'high':
        return const Color(0xFFFFD740);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  IconData _getTypeIcon() {
    switch ((item.type ?? '').toLowerCase()) {
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
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime() {
    if (item.timestamp == null) return '';
    try {
      final dt = DateTime.parse(item.timestamp!).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final severityColor = _getSeverityColor();
    final isUnread = item.read == false;

    return GestureDetector(
      onTap: () {
        controller.markRead(item.id);
        _showDetailSheet(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.px),
        decoration: BoxDecoration(
          color: isUnread
              ? typeColor.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? typeColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Severity bar
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

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: typeColor.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _getTypeIcon(),
                              color: typeColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 10.px),

                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.category != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.category!.toUpperCase(),
                                      style: TextStyle(
                                        color: typeColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
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
                                _formatTime(),
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9.px,
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

                      SizedBox(height: 6.px),

                      // Tap hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Tap for details",
                            style: TextStyle(
                              color: typeColor.withOpacity(0.6),
                              fontSize: 9.px,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 3.px),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 8,
                            color: typeColor.withOpacity(0.6),
                          ),
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

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(item: item),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// DETAIL SHEET
// ══════════════════════════════════════════════════════════════════════════

class _DetailSheet extends StatelessWidget {
  final NotificationItem item;

  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
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

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.category != null)
                      Text(
                        item.category!.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withOpacity(0.1), height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      item.message ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    if (item.data != null && item.data!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "DETAILS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...item.data!.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  e.key.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  e.value?.toString() ?? '--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SHIMMER LOADING
// ══════════════════════════════════════════════════════════════════════════

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF3C3C98).withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B6E),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.white24,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "You're all caught up!",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ══════════════════════════════════════════════════════════════════════════

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
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white24,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}