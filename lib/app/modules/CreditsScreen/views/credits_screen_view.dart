import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/progress_bar.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/credits_screen_controller.dart';

class CreditsScreenView extends GetView<CreditsScreenController> {
  const CreditsScreenView({super.key});

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
                        // ─── Top Navigation Bar ───────────────────────────────
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
                                  SizedBox(width: 10.px),
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

                        // ─── Page Title ───────────────────────────────────────
                        Text(
                          "Credits",
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

                        SizedBox(height: 8.px),

                        // ─── User Name ────────────────────────────────────────
                        Obx(() => Text(
                              controller.userName.value,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18.px,
                                fontWeight: FontWeight.w400,
                              ),
                            )),

                        SizedBox(height: 30.px),

                        // ─── Credits Balance Card ─────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 28.px, horizontal: 24.px),
                            decoration: BoxDecoration(
                              color: Color(0xffaaa5a5b2).withOpacity(0.45),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Coin icon + amount
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CommonWidgets.appIconsSvg(
                                        assetName: IconConstants.icRefferalCoin,
                                        height: 36.px,
                                        width: 36.px),
                                    SizedBox(width: 12.px),
                                    Obx(() {
                                      controller.count.value;
                                      return Text(
                                        controller
                                                .referralModel?.totalCreditsLeft
                                                .toString() ??
                                            "0",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 48.px,
                                          fontWeight: FontWeight.w800,
                                          height: 1,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                SizedBox(height: 8.px),
                                Text(
                                  "Your current Skypeanuts Credits",
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

                        SizedBox(height: 30.px),

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
                                  "MANAGE CREDITS",
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

                        SizedBox(height: 24.px),

                        // ─── What you can get button ──────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: CommonWidgets.commonElevatedButton(
                            height: 60.px,
                            borderRadius: 14.px,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14.px),
                              border: Border.all(
                                width: 1,
                                color: primary3Color,
                              ),
                            ),
                            onPressed: () {
                              _showCreditSchemaDialog({
                                "status": "1",
                                "message": "User Credit Balance.",
                                "schema": {
                                  "basic_alert": 1,
                                  "hazard_detail": 2,
                                  "flight_plan": 3,
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.key,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8.px),
                                Text(
                                  "What you can get with Credits",
                                  style: TextStyle(
                                      fontSize: 13.px,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            showLoading: controller.showLoading.value,
                          ),
                        ),

                        SizedBox(height: 14.px),

                        // ─── Shop Now button ──────────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: CommonWidgets.commonElevatedButton(
                            height: 60.px,
                            borderRadius: 14.px,
                            buttonColor: primaryColor2,
                            onPressed: () => controller.clickOnNext(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icShop,
                                  height: 20.px,
                                  width: 18,
                                ),
                                SizedBox(width: 8.px),
                                Text(
                                  "Shop Now",
                                  style: TextStyle(
                                      fontSize: 16.px,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            showLoading: controller.showLoading.value,
                          ),
                        ),

                        SizedBox(height: 30.px),

                        // ─── How to earn credits info card ────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.px),
                            decoration: BoxDecoration(
                              color: liteGreenColor.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8.px),
                                    Text(
                                      "How to earn Credits",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.px,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.px),
                                _buildEarnRow(
                                    icon: Icons.person_add_outlined,
                                    text: "Invite a friend → earn 3 Credits"),
                                SizedBox(height: 8.px),
                                _buildEarnRow(
                                    icon: Icons.shopping_bag_outlined,
                                    text:
                                        "Purchase a plan → get bonus Credits"),
                                SizedBox(height: 8.px),
                                _buildEarnRow(
                                    icon: Icons.star_outline,
                                    text:
                                        "Complete activities → unlock rewards"),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20.px),

                        // ─── Navigate to Referral ─────────────────────────────
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.px),
                          child: InkWell(
                            onTap: () => Get.toNamed(Routes.REFERRAL_SCREEN),
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
                                    child: const Icon(Icons.people_outline,
                                        color: Colors.white, size: 22),
                                  ),
                                  SizedBox(width: 14.px),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Refer & Earn",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.px,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Share your code, earn 3 Credits per referral",
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

  Widget _buildEarnRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        SizedBox(width: 10.px),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.px,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void _showCreditSchemaDialog(Map<String, dynamic> responseData) {
    final schema = responseData['schema'] ?? {};

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                gradientPurple1,
                gradientPurple2,
                gradientPurple3,
                gradientPurple4,
                gradientPurple5,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    responseData['message'] ?? "Credit Schema",
                    style: const TextStyle(
                      color: primary3Color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ...schema.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key
                              .toString()
                              .replaceAll("_", " ")
                              .toUpperCase(),
                          style: const TextStyle(
                            color: primary3Color,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            color: primary3Color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: primary3Color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
