import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_models/get_privacy_model.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/privacy_policy_screen_controller.dart';

class PrivacyPolicyScreenView
    extends GetView<PrivacyPolicyScreenController> {
  const PrivacyPolicyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────────
              _PrivacyTopBar(),

              // ── Content ─────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  controller.count.value;

                  if (controller.inAsyncCall.value) {
                    return _ShimmerLoading();
                  }

                  final data = controller.privacyModelData;
                  if (data == null || data.sections.isEmpty) {
                    return _EmptyState();
                  }

                  return _PrivacyContent(model: data);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Top Bar
// ═════════════════════════════════════════════════════════════════════════════

class _PrivacyTopBar extends GetView<PrivacyPolicyScreenController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icBackRound,
              height: 31.px,
              width: 31.px,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                color: primary3Color,
                fontWeight: FontWeight.w700,
                fontSize: 20.px,
              ),
            ),
          ),

          // AI icon
          InkWell(
            onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
            borderRadius: BorderRadius.circular(12),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icAiSetting,
              height: 32.px,
              width: 32.px,
              color: primary3Color,
            ),
          ),
          const SizedBox(width: 8),

          // Notification
          CommonWidgets.appIcons(
            assetName: IconConstants.icNotificationTop,
            height: 26.px,
            width: 26.px,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Privacy Content
// ═════════════════════════════════════════════════════════════════════════════

class _PrivacyContent extends StatelessWidget {
  final PrivacyModel model;

  const _PrivacyContent({required this.model});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.px, vertical: 8.px),
      children: [
        // ── App info header card ───────────────────────────────────────────
        _AppInfoCard(model: model),

        const SizedBox(height: 16),

        // ── Sections ──────────────────────────────────────────────────────
        ...model.sections.map((section) => _SectionCard(section: section)),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// App Info Card (header)
// ═════════════════════════════════════════════════════════════════════════════

class _AppInfoCard extends StatelessWidget {
  final PrivacyModel model;

  const _AppInfoCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App name + company
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                  Border.all(color: primaryColor.withOpacity(0.4)),
                ),
                child: Text(
                  model.appName,
                  style: TextStyle(
                    color: primary3Color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.px,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  model.company,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.px,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Last updated
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Last Updated',
            value: model.lastUpdated,
          ),
          const SizedBox(height: 4),

          // Contact
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Contact',
            value: model.contactEmail,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.px,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.px,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section Card (expandable)
// ═════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatefulWidget {
  final PrivacySection section;

  const _SectionCard({required this.section});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  // Auto-expand Introduction section
  @override
  void initState() {
    super.initState();
    _expanded = widget.section.section == 'Introduction';
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final hasSubsections = section.subsections.isNotEmpty;
    final hasContent = section.content.isNotEmpty;
    final isIntro = section.section == 'Introduction';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded
              ? primaryColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (tap to expand) ───────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Section number badge
                  if (!isIntro)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: primaryColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        section.section,
                        style: TextStyle(
                          color: primary3Color,
                          fontSize: 10.px,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  // Title
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        color: primary3Color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.px,
                      ),
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ─────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Main content text
                  if (hasContent)
                    Text(
                      section.content,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5.px,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),

                  // Subsections
                  if (hasSubsections) ...[
                    if (hasContent) const SizedBox(height: 14),
                    ...section.subsections
                        .map((sub) => _SubSectionItem(sub: sub)),
                  ],
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SubSection Item
// ═════════════════════════════════════════════════════════════════════════════

class _SubSectionItem extends StatelessWidget {
  final PrivacySubSection sub;

  const _SubSectionItem({required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subsection title with badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 2),
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(5),
                  border:
                  Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Text(
                  sub.subsection,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9.px,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  sub.title,
                  style: TextStyle(
                    color: primary3Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.px,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Content
          Text(
            sub.content,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.px,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shimmer Loading
// ═════════════════════════════════════════════════════════════════════════════

class _ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.px, vertical: 8.px),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: gradientPurple1.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.4),
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: primary3Color,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty State
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.policy_outlined,
            color: Colors.white30,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy Policy not available.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 15.px,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Get.find<PrivacyPolicyScreenController>()
                .getPrivacyPolicyApiData(),
            icon: const Icon(Icons.refresh, color: Colors.white54),
            label: Text(
              'Try Again',
              style: TextStyle(color: Colors.white54, fontSize: 14.px),
            ),
          ),
        ],
      ),
    );
  }
}