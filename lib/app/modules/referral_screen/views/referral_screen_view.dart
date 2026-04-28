import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/progress_bar.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/referral_screen_controller.dart';

class ReferralScreenView extends GetView<ReferralScreenController> {
  const ReferralScreenView({super.key});

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
                  gradientPurple1,
                  gradientPurple2,
                  gradientPurple3,
                  gradientPurple4,
                  gradientPurple5,
                ],
              ),
            ),
            child: Obx(() {
              controller.count.value;
              return ProgressBar(
                inAsyncCall: controller.inAsyncCallForLoadReward.value,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ─── Top Navigation Bar ─────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              InkWell(
                                onTap: () => Get.back(),
                                child: CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icBackRound,
                                    height: 31.px,
                                    width: 31.px),
                              ),
                              // Right icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        Get.toNamed(Routes.AI_CHAT_SCREEN),
                                    child: CommonWidgets.appIconsSvg(
                                        assetName: IconConstants.icAiSetting,
                                        height: 32.px,
                                        width: 32.px,
                                        color: primary3Color),
                                  ),
                                  SizedBox(width: 10.px),
                                  InkWell(
                                    onTap: () => Get.toNamed(
                                        Routes.NOTIFICATION_SCREEN,
                                        parameters: {"fromScreen": "button"}),
                                    child: CommonWidgets.appIcons(
                                        assetName:
                                            IconConstants.icNotificationTop,
                                        height: 26.px,
                                        width: 26.px),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.px),

                        // ─── Page Title ─────────────────────────────────────
                        Text(
                          "Refer & Earn",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.px,
                            fontWeight: FontWeight.w700,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 4),
                                blurRadius: 10.0,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.px),

                        // ─── User Name ───────────────────────────────────────
                        Obx(() {
                          controller.count.value;
                          return Text(
                            controller.userName.value,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18.px,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }),

                        SizedBox(height: 30.px),

                        // ─── Credits Summary Card (read-only) ────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 16.px, horizontal: 20.px),
                            decoration: BoxDecoration(
                              color: Color(0xffaaa5a5b2).withOpacity(0.35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icRefferalCoin,
                                    height: 22.px,
                                    width: 22.px),
                                SizedBox(width: 8.px),
                                Obx(() {
                                  controller.count.value;
                                  return Text(
                                    controller.referralModel?.totalCreditsLeft
                                            .toString() ??
                                        "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.px,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }),
                                SizedBox(width: 6.px),
                                Text(
                                  "Skypeanuts Credits",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.px,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.px),

                        // ─── Invite Banner ───────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.px),
                            decoration: BoxDecoration(
                              color: liteGreenColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🎉  Earn 3 Skypeanuts Credits',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.px,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.px),
                                Text(
                                  'Invite a Friend!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.px,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.px),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Text(
                            "Refer a friend to the target audience and\nget a chance to win a huge amount.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.px,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ),

                        SizedBox(height: 24.px),

                        // ─── Divider Label ────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.2),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.px),
                                child: Text(
                                  "YOUR CODE",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11.px,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withOpacity(0.2),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.px),

                        // ─── Referral Code Box ────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.px, horizontal: 20.px),
                            decoration: BoxDecoration(
                              color: Color(0xffaaa5a5b2).withOpacity(0.45),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Referral Code",
                                      style: TextStyle(
                                        color: textColorLite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.px,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4.px),
                                    Obx(() {
                                      controller.count.value;
                                      return Text(
                                        controller
                                                .referralModel?.referralCode ??
                                            'N/A',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22.px,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 3,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final code = controller
                                            .referralModel?.referralCode ??
                                        '';
                                    Clipboard.setData(
                                        ClipboardData(text: code));
                                    Get.snackbar(
                                      "Copied",
                                      "Referral code copied to clipboard",
                                      backgroundColor: Colors.black87,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, color: primaryColor2),
                                      SizedBox(width: 4.px),
                                      Text(
                                        "Copy",
                                        style: TextStyle(
                                          color: primaryColor2,
                                          fontSize: 15.px,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30.px),

                        // ─── Share Via Label ──────────────────────────────────
                        Text(
                          "Share Via:",
                          style: TextStyle(
                            color: textColorLite,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.px,
                          ),
                        ),

                        SizedBox(height: 20.px),

                        // ─── Share Icons ──────────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.px),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ShareButton(
                                label: "WhatsApp",
                                icon: IconConstants.icWhatsApp,
                                onTap: () => controller.shareApp(),
                              ),
                              _ShareButton(
                                label: "X",
                                icon: IconConstants.icX,
                                onTap: () => controller.shareViaTwitter(),
                              ),
                              _ShareButton(
                                label: "Facebook",
                                icon: IconConstants.icFb,
                                onTap: () => controller.shareViaFacebook(),
                              ),
                              _ShareButton(
                                label: "More",
                                icon: IconConstants.icShare,
                                onTap: () => controller.shareGeneral(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.px),

                        // ─── Go to Credits shortcut ───────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: InkWell(
                            onTap: () => controller.goToCredits(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 18.px, horizontal: 20.px),
                              decoration: BoxDecoration(
                                color: Color(0xffaaa5a5b2).withOpacity(0.35),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.px),
                                    decoration: BoxDecoration(
                                      color: primaryColor2.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CommonWidgets.appIconsSvg(
                                      assetName: IconConstants.icRefferalCoin,
                                      height: 20.px,
                                      width: 20.px,
                                    ),
                                  ),
                                  SizedBox(width: 14.px),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Your Credits",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.px,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "View balance & purchase more Credits",
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12.px,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white54, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 30.px),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ─── Private Share Button Widget ─────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _ShareButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CommonWidgets.appIconsSvg(
            assetName: icon,
            height: 50,
            width: 50,
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
