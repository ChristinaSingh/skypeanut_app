import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/update_profile_screen_controller.dart';

class UpdateProfileScreenView extends GetView<UpdateProfileScreenController> {
  const UpdateProfileScreenView({super.key});

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
          child: Obx(() {
            // Single Obx at top — reads count to react to all changes
            controller.count.value;

            return Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                _TopBar(),

                // ── Scrollable body ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 30.px),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.px),

                        // ── Avatar ─────────────────────────────────────────
                        _AvatarSection(),

                        SizedBox(height: 24.px),

                        // ── Name field ─────────────────────────────────────
                        Obx(() => CommonWidgets.commonTextFieldForLoginSignUP(
                              controller: controller.nameController,
                              focusNode: controller.focusNodeName,
                              isCard: controller.isName.value,
                              hintText: StringConstants.fullName,
                              keyboardType: TextInputType.name,
                              prefixIcon: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icProfileActive,
                                height: 20.px,
                                width: 20.px,
                                color: controller.isName.value
                                    ? primaryColor2
                                    : null,
                              ),
                            )),

                        SizedBox(height: 4.px),

                        // ── Email field (read-only) ────────────────────────
                        Obx(() => CommonWidgets.commonTextFieldForLoginSignUP(
                              focusNode: controller.focusNodeEmail,
                              controller: controller.emailController,
                              isCard: controller.isEmail.value,
                              hintText: StringConstants.email,
                              readOnly: true,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icEmailActive,
                                height: 20.px,
                                width: 20.px,
                                color: controller.isEmail.value
                                    ? primaryColor2
                                    : null,
                              ),
                            )),

                        SizedBox(height: 4.px),

                        // ── Password field ────────────────────────────────
                        Obx(() => CommonWidgets.commonTextFieldForLoginSignUP(
                              focusNode: controller.focusNodePassword,
                              controller: controller.passwordController,
                              isCard: controller.isPassword.value,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: controller.isHide.value,
                              hintText:
                                  'New password (leave blank to keep current)',
                              prefixIcon: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icPassActive,
                                height: 20.px,
                                width: 20.px,
                                color: controller.isPassword.value
                                    ? primaryColor2
                                    : null,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  controller.isHide.value =
                                      !controller.isHide.value;
                                },
                                child: Icon(
                                  controller.isHide.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 25.px,
                                  color: eyeColor,
                                ),
                              ),
                            )),

                        SizedBox(height: 40.px),

                        // ── Update button ─────────────────────────────────
                        Obx(() => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.px),
                              child: CommonWidgets.commonElevatedButton(
                                height: 60.px,
                                borderRadius: 14.px,
                                buttonColor: primaryColor2,
                                onPressed: () {
                                  if (controller.inAsyncCall.value) {
                                    // Do nothing if already loading
                                    return;
                                  } else {
                                    controller.onClickUpdate();
                                  }
                                },
                                showLoading: controller.inAsyncCall.value,
                                child: Text(
                                  StringConstants.update,
                                  style: MyTextStyle.titleStyle18bw,
                                ),
                              ),
                            )),

                        SizedBox(height: 30.px),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends GetView<UpdateProfileScreenController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.px, vertical: 10.px),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icBackRound,
              height: 31.px,
              width: 31.px,
            ),
          ),
          SizedBox(width: 12.px),
          Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.px,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Section ───────────────────────────────────────────────────────────
class _AvatarSection extends GetView<UpdateProfileScreenController> {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.inAsyncCall.value;
      final selectedFile = controller.selectImage.value;
      final networkUrl = controller.profileImage.value;

      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Avatar image ────────────────────────────────────────────
              if (selectedFile != null)
                // User picked a new image
                ClipRRect(
                  borderRadius: BorderRadius.circular(60.px),
                  child: Image.file(
                    selectedFile,
                    height: 100.px,
                    width: 100.px,
                    fit: BoxFit.cover,
                  ),
                )
              else if (isLoading)
                // Shimmer while loading profile
                Shimmer.fromColors(
                  baseColor: gradientPurple1.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.4),
                  child: Container(
                    height: 100.px,
                    width: 100.px,
                    decoration: const BoxDecoration(
                      color: primary3Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                // Network / default image
                ClipRRect(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(65.px),
                      child: Image.network(
                        networkUrl.isEmpty
                            ? StringConstants.defaultNetworkImage
                            : networkUrl,
                        height: 100.px,
                        width: 100.px,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CommonWidgets.imageView(
                            image: StringConstants.defaultNetworkImage,
                            height:100.px,
                            width: 100.px,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(65.px),
                            defaultNetworkImage: StringConstants.defaultNetworkImage,
                          );
                        },
                      ),
                    )),

              // ── Edit button (bottom-right of avatar) ────────────────────
              Positioned(
                bottom: -4,
                right: -4,
                child: GestureDetector(
                  onTap: controller.pickImages,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: primaryColor2,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: primary3Color,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.px),

          // ── Tap to change label ─────────────────────────────────────────
          GestureDetector(
            onTap: controller.pickImages,
            child: Text(
              'Change Photo',
              style: TextStyle(
                color: primaryColor2,
                fontSize: 12.px,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    });
  }
}
