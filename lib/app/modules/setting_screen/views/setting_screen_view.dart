import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypeanut/app/data/constants/string_constants.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/setting_screen_controller.dart';

class SettingScreenView extends GetView<SettingScreenController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
              controller.count.value;

              return RefreshIndicator(
                onRefresh: controller.refetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Top bar ────────────────────────────────────────
                      _TopBar(),

                      SizedBox(height: 20.px),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Avatar ────────────────────────────────────
                            _AvatarSection(),

                            const SizedBox(height: 30),

                            // ── Menu ──────────────────────────────────────
                            _buildOptionRow(
                              'Update Profile',
                              icon: Icons.person_outline_rounded,
                              onTap: () {
                                Get.toNamed(Routes.UPDATE_PROFILE_SCREEN)
                                    ?.then(
                                        (_) => controller.getProfileApi());
                              },
                            ),
                            _buildOptionRow(
                              'Privacy and Security',
                              icon: Icons.shield_outlined,
                              onTap: () => Get.toNamed(
                                  Routes.PRIVACY_POLICY_SCREEN),
                            ),
                            _buildOptionRow(
                              'Support Center',
                              icon: Icons.support_agent_outlined,
                              onTap: () =>
                                  Get.toNamed(Routes.SUPPORT_SCREEN),
                            ),
                            _buildOptionRow(
                              'Referral',
                              icon: Icons.card_giftcard_outlined,
                              onTap: () =>
                                  Get.toNamed(Routes.REFERRAL_SCREEN),
                            ),
                            _buildOptionRow(
                              'Credit Purchase',
                              icon: Icons.credit_card_outlined,
                              onTap: () =>
                                  Get.toNamed(Routes.CREDITS_SCREEN),
                            ),

                            const SizedBox(height: 24),

                            // ── Divider ───────────────────────────────────
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.15),
                                  Colors.transparent,
                                ]),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Logout ────────────────────────────────────
                            _LogoutButton(),

                            const SizedBox(height: 16),

                            // ✅ NEW ── Delete Account ─────────────────────
                            _DeleteAccountButton(),

                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends GetView<SettingScreenController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (controller.parameters['fromScreen'] == 'button')
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(20),
              child: CommonWidgets.appIconsSvg(
                assetName: IconConstants.icBackRound,
                height: 31.px,
                width: 31.px,
              ),
            )
          else
            const SizedBox(width: 31),

          InkWell(
            onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icAiSetting,
              height: 32.px,
              width: 32.px,
              color: primary3Color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Section ───────────────────────────────────────────────────────────
class _AvatarSection extends GetView<SettingScreenController> {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.inAsyncCall.value;
      final isUploading = controller.isUploadingImage.value;
      final pending = controller.selectImage.value;
      final networkUrl = controller.profileImage.value;
      final hasPending = pending != null;

      return Column(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (hasPending)
                ClipRRect(
                  borderRadius: BorderRadius.circular(65.px),
                  child: Image.file(
                    pending,
                    height: 130.px,
                    width: 130.px,
                    fit: BoxFit.cover,
                  ),
                )
              else if (isLoading)
                Shimmer.fromColors(
                  baseColor: gradientPurple1.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.4),
                  child: Container(
                    height: 130.px,
                    width: 130.px,
                    decoration: const BoxDecoration(
                      color: primary3Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(65.px),
                  child: Image.network(
                    networkUrl.isEmpty
                        ? StringConstants.defaultNetworkImage
                        : networkUrl,
                    height: 130.px,
                    width: 130.px,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CommonWidgets.imageView(
                      image: StringConstants.defaultNetworkImage,
                      height: 130.px,
                      width: 130.px,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(65.px),
                      defaultNetworkImage:
                      StringConstants.defaultNetworkImage,
                    ),
                  ),
                ),

              // Upload spinner
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),

              // Camera edit icon
              if (!isUploading)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: controller.pickImages,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor2,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Name
          if (isLoading)
            Shimmer.fromColors(
              baseColor: const Color(0xFF3C3C98).withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.4),
              child: Container(
                height: 24,
                width: 150,
                decoration: BoxDecoration(
                  color: primary3Color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            Text(
              controller.getProfileModelData?.fullName ?? '—',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

          const SizedBox(height: 12),

          if (hasPending && !isUploading) const _SubmitCancelRow(),

          if (!hasPending && !isUploading)
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

// ─── Submit / Cancel row ──────────────────────────────────────────────────────
class _SubmitCancelRow extends GetView<SettingScreenController> {
  const _SubmitCancelRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.cancelImageSelection,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: controller.submitProfileImage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor2,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryColor2.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Save Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends GetView<SettingScreenController> {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CommonWidgets.showAlertDialog(
          onPressedYes: controller.logout,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.orangeAccent.withOpacity(0.5)),
          color: Colors.orangeAccent.withOpacity(0.06),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: Colors.orangeAccent, size: 20),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ NEW ─── Delete Account Button ─────────────────────────────────────────────
class _DeleteAccountButton extends GetView<SettingScreenController> {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDeleting = controller.isDeletingAccount.value;

      return InkWell(
        onTap:
        isDeleting ? null : controller.showDeleteAccountDialog,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.redAccent.withOpacity(0.5)),
            color: Colors.redAccent.withOpacity(0.06),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isDeleting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isDeleting ? 'Deleting Account...' : 'Delete Account',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Option row ───────────────────────────────────────────────────────────────
Widget _buildOptionRow(
    String label, {
      required VoidCallback onTap,
      IconData icon = Icons.chevron_right,
    }) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Colors.white54, size: 20),
    title: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    trailing:
    const Icon(Icons.chevron_right, color: Colors.greenAccent),
    onTap: onTap,
  );
}