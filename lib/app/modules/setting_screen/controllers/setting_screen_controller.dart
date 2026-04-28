import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/common_widgets.dart';
import '../../../common/image_pick_and_crop.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_profile_model.dart';
import '../../../data/services/connectivity_controller.dart';
import '../../../routes/app_pages.dart';

class SettingScreenController extends GetxController {
  // ─── Params ──────────────────────────────────────────────────────────────
  Map<String, String?> parameters = Get.parameters;

  // ─── Observables ─────────────────────────────────────────────────────────
  final count = 0.obs;
  final inAsyncCall = true.obs;
  final isUploadingImage = false.obs;
  final isDeletingAccount = false.obs;

  final selectImage = Rxn<File>();
  final profileImage = ''.obs;

  final isWeatherSynced = false.obs;
  final isNotamSynced = false.obs;

  // ✅ FIX: Controller-level password state (properly managed lifecycle)
  late final TextEditingController passwordController;
  final isPasswordVisible = false.obs;
  final isDeleteLoading = false.obs;

  // ─── Data ────────────────────────────────────────────────────────────────
  String userId = '';
  String userEmail = '';
  GetProfileModel? getProfileModelData;

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  Future<void> onInit() async {
    super.onInit();

    // ✅ Initialize here so it's properly disposed in onClose()
    passwordController = TextEditingController();

    final connectivity = Get.find<ConnectivityController>();
    ever(connectivity.connectivityResults, (results) {
      final offline =
          results.contains(ConnectivityResult.none) && results.length == 1;
      if (!offline) refetchData();
    });

    final sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';

    await checkCacheStatus();
    await getProfileApi();
  }

  @override
  void onClose() {
    // ✅ Properly dispose here — never inside a local function
    passwordController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  // ─── Refresh ─────────────────────────────────────────────────────────────
  Future<void> refetchData() async {
    await checkCacheStatus();
    await getProfileApi();
  }

  // ─── Cache status ─────────────────────────────────────────────────────────
  Future<void> checkCacheStatus() async {
    final sp = await SharedPreferences.getInstance();
    isWeatherSynced.value = sp.containsKey('cache_nearby_weather') ||
        sp.containsKey('cache_weather');
    isNotamSynced.value = sp.containsKey('cache_notams_data') ||
        sp.containsKey('cache_notams');
    increment();
  }

  // ─── Pick image ───────────────────────────────────────────────────────────
  Future<void> pickImages() async {
    final picked = await ImagePickerAndCropper.pickImage(
      color: Colors.deepPurple,
      textColor: Colors.white,
      dialogBackgroundColor: Colors.black,
      wantCropper: true,
      context: Get.context!,
    );

    if (picked != null) {
      selectImage.value = picked;
      increment();
    }
  }

  // ─── Cancel pending image ─────────────────────────────────────────────────
  void cancelImageSelection() {
    selectImage.value = null;
    increment();
  }

  // ─── Submit image ─────────────────────────────────────────────────────────
  Future<void> submitProfileImage() async {
    if (selectImage.value == null) return;

    isUploadingImage.value = true;

    try {
      final body = <String, String>{
        ApiKeyConstants.userId: userId,
        ApiKeyConstants.fullName: getProfileModelData?.fullName ?? '',
        ApiKeyConstants.email: getProfileModelData?.email ?? '',
      };

      final result = await ApiMethods.updateProfileApi(
        bodyParams: body,
        image: selectImage.value,
      );

      if (result != null && result.status != '0') {
        CommonWidgets.showMyToastMessage('Profile photo updated!');
        selectImage.value = null;
        await getProfileApi();
      } else {
        CommonWidgets.showMyToastMessage(
          result?.message ?? 'Upload failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('submitProfileImage error: $e');
      CommonWidgets.showMyToastMessage('Something went wrong.');
    } finally {
      isUploadingImage.value = false;
      increment();
    }
  }

  // ─── Get profile ──────────────────────────────────────────────────────────
  Future<void> getProfileApi() async {
    inAsyncCall.value = true;
    try {
      final body = {ApiKeyConstants.userId: userId};
      final model = await ApiMethods.getProfile(bodyParams: body);

      if (model != null && model.status == '1') {
        getProfileModelData = model;
        profileImage.value = model.profilePhotoUrl ?? '';
        userEmail = model.email ?? '';
        increment();
        debugPrint("Profile fetched :: ${profileImage.value}");
      }
    } catch (e) {
      debugPrint('getProfileApi error: $e');
    } finally {
      inAsyncCall.value = false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offNamedUntil(Routes.LOGIN_SCREEN, (route) => false);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Delete Account
  // ══════════════════════════════════════════════════════════════════════════

  /// ✅ Reset dialog state before opening
  void showDeleteAccountDialog() {
    // Reset state every time dialog opens
    passwordController.clear();
    isPasswordVisible.value = false;
    isDeleteLoading.value = false;

    Get.dialog(
      const _DeleteAccountDialog(),
      barrierDismissible: false,
    );
  }

  /// Called by the dialog's Delete button
  Future<void> confirmDeleteAccount() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      CommonWidgets.showMyToastMessage('Please enter your password.');
      return;
    }

    isDeleteLoading.value = true;

    try {
      final result = await ApiMethods.deleteAccountApi(
        userId: userId,
        password: password,
      );

      if (result != null && result['status'] == '1') {
        // ✅ Close dialog BEFORE clearing data
        Get.back();

        CommonWidgets.showMyToastMessage(
          result['message'] ??
              'Your account has been permanently deleted.',
        );

        // Small delay so user can read the toast
        await Future.delayed(const Duration(milliseconds: 800));

        // ✅ Wipe ALL local data
        await _clearAllLocalData();

        // ✅ Clear entire navigation stack → go to login
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      } else {
        CommonWidgets.showMyToastMessage(
          result?['message'] ?? 'Incorrect password. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('confirmDeleteAccount error: $e');
      CommonWidgets.showMyToastMessage(
          'Something went wrong. Please try again.');
    } finally {
      isDeleteLoading.value = false;
    }
  }

  /// ✅ Wipe every key in SharedPreferences
  Future<void> _clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('✅ All SharedPreferences cleared.');
  }
}

// ✅ Completely separate widget — no local TextEditingController creation
// Place this at the bottom of setting_screen_view.dart

class _DeleteAccountDialog extends GetView<SettingScreenController> {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ✅ Prevent accidental back-swipe while deleting
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!controller.isDeleteLoading.value) {
          Get.back();
        }
      },
      child: Dialog(
        backgroundColor: const Color(0xFF1B1142),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            // ✅ FIX: Prevents "Column overflowed by 99631 pixels" on small screens
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ CRITICAL: don't expand infinitely
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Warning Icon ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Title ──────────────────────────────────────────────────
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Warning message ────────────────────────────────────────
                const Text(
                  'This action is permanent and cannot be undone.\n'
                      'All your data will be permanently removed from our system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Password field ─────────────────────────────────────────
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: TextField(
                    // ✅ Using controller-level TextEditingController
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password to confirm',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white54,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => controller.isPasswordVisible.value =
                        !controller.isPasswordVisible.value,
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 24),

                // ── Action Buttons ─────────────────────────────────────────
                Obx(() {
                  final isLoading = controller.isDeleteLoading.value;

                  return Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading ? null : () => Get.back(),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isLoading
                                      ? Colors.white38
                                      : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Delete button
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : controller.confirmDeleteAccount,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding:
                            const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.redAccent.withOpacity(0.5)
                                  : Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isLoading
                                  ? []
                                  : [
                                BoxShadow(
                                  color: Colors.redAccent
                                      .withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}