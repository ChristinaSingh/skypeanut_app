import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';
import '../controllers/setting_for_back_controller.dart';

class SettingForBackView extends GetView<SettingForBackController> {
  const SettingForBackView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<SettingForBackController>(
      () => SettingForBackController(),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(body: Obx(() {
        controller.count.value;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientPurple1, // Dark purple top
                gradientPurple2,
                gradientPurple3,
                gradientPurple4,
                gradientPurple5, // Deep blue bottom
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            SizedBox(width: 3.px),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // CommonWidgets.appIcons(
                            //     assetName: IconConstants.icMenuSetting,
                            //     height: 32.px,
                            //     width: 32.px),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.AI_CHAT_SCREEN);
                              },
                              child: CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icAiSetting,
                                  height: 32.px,
                                  width: 32.px,
                                  color: primary3Color),
                            ),
                            SizedBox(
                              width: 10.px,
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.NOTIFICATION_SCREEN);
                              },
                              child: CommonWidgets.appIcons(
                                  assetName: IconConstants.icNotificationTop,
                                  height: 26.px,
                                  width: 26.px),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.px,
                  ),
                  SizedBox(
                    height: 20.px,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            controller.selectImage.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(61.px),
                                    child: Image.file(
                                      height: 122.px,
                                      width: 122.px,
                                      fit: BoxFit.cover,
                                      File(
                                        controller.selectImage.value!.path
                                            .toString(),
                                      ),
                                    ))
                                : controller.inAsyncCall.value
                                    ? Shimmer.fromColors(
                                        baseColor:
                                            gradientPurple1.withOpacity(.2.px),
                                        highlightColor:
                                            Colors.white.withOpacity(0.4),
                                        child: Container(
                                          height: 130.px,
                                          width: 130.px,
                                          decoration: BoxDecoration(
                                            color: primary3Color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : CommonWidgets.imageView(
                                        image:
                                            controller.profileImage.value == ""
                                                ? StringConstants
                                                    .defaultNetworkImage
                                                : controller.profileImage.value,
                                        height: 130.px,
                                        width: 130.px,
                                        fit: BoxFit.cover,
                                        borderRadius:
                                            BorderRadius.circular(65.px),
                                        defaultNetworkImage: StringConstants
                                            .defaultNetworkImage),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            controller.inAsyncCall.value
                                ? Shimmer.fromColors(
                                    baseColor:
                                        Color(0xFF3C3C98).withOpacity(.2.px),
                                    highlightColor:
                                        Colors.white.withOpacity(0.4),
                                    child: Container(
                                      height: 30,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: primary3Color,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  )
                                : Text(
                                    controller.getProfileModelData?.fullName ??
                                        'Jake',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                            SizedBox(width: 8),
                            InkWell(
                                onTap: () {
                                  controller.pickImages();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Icon(Icons.edit, color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Options
                        _buildOptionRow("Update Profile", onTap: () {
                          Get.toNamed(Routes.UPDATE_PROFILE_SCREEN)
                              ?.then((value) {
                            controller.getProfileApi();
                          });
                        }),

                        _buildOptionRow("Privacy and security", onTap: () {
                          Get.toNamed(Routes.PRIVACY_POLICY_SCREEN);
                        }),
                        _buildOptionRow("Support Center", onTap: () {
                          Get.toNamed(Routes.SUPPORT_SCREEN);
                        }),
                        _buildOptionRow("Referral", onTap: () {
                          Get.toNamed(Routes.REFERRAL_SCREEN);
                        }),
                        _buildOptionRow("Credit Purchase", onTap: () {
                          Get.toNamed(Routes.CREDITS_SCREEN);
                        }),

                        // Logout
                        InkWell(
                          onTap: () {
                            CommonWidgets.showAlertDialog(onPressedYes: () {
                              controller.logout();
                            });
                          },
                          child: Column(
                            children: [
                              // CommonWidgets.appIconsSvg(
                              //   assetName: IconConstants.icDelete,
                              //   height: 64.px,
                              //   width: 64.px,
                              // ),
                              Container(
                                padding: EdgeInsetsGeometry.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.greenAccent, width: 2)),
                                child: Icon(
                                  Icons.logout,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 17),

                        // Offline Mode
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 8.px),
                          ),
                          child: Column(
                            children: [
                              CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icOffline,
                                  height: 16.px,
                                  width: 16.px),
                              SizedBox(
                                height: 10.px,
                              ),
                              Text('Offline Mode',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 16.px)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Cache weather and NOTAMs for offline use.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.px,
                  ),
                ],
              ),
            ),
          ),
        );
      })),
    );
  }
}

Widget _iconTile(IconData icon) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.tealAccent.shade400.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.cyanAccent),
    ),
  );
}

Widget _buildOption(String title) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.greenAccent),
    onTap: () {
      // Use Get.to(...) or handle tap
    },
  );
}

Widget _buildOptionRow(String label, {required VoidCallback onTap}) {
  return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.greenAccent),
      onTap: onTap);
}
