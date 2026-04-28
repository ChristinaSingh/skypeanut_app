import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/common_methods.dart';
import '../../../common/common_widgets.dart';
import '../../../common/image_pick_and_crop.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_profile_model.dart';
import '../../../data/apis/api_models/update_profile_model.dart';
import '../../../data/constants/string_constants.dart';

class UpdateProfileScreenController extends GetxController {
  // ─── Text Controllers ──────────────────────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ─── Focus Nodes ───────────────────────────────────────────────────────────
  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  // ─── Observables ───────────────────────────────────────────────────────────
  final isPassword = false.obs;
  final isName = false.obs;
  final isEmail = false.obs;
  final count = 0.obs;
  final isHide = true.obs;
  final inAsyncCall = false.obs;

  final selectImage = Rxn<File>();
  final profileImage = ''.obs;

  // ─── Data ──────────────────────────────────────────────────────────────────
  String userId = '';
  GetProfileModel? getProfileModelData;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  Future<void> onInit() async {
    super.onInit();
    _startFocusListeners();
    final sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    await getProfileApi();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    focusNodeName.dispose();
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.onClose();
  }

  // ─── Focus ─────────────────────────────────────────────────────────────────
  void _startFocusListeners() {
    focusNodeName.addListener(_onFocusChange);
    focusNodeEmail.addListener(_onFocusChange);
    focusNodePassword.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    isName.value = focusNodeName.hasFocus;
    isEmail.value = focusNodeEmail.hasFocus;
    isPassword.value = focusNodePassword.hasFocus;
  }

  void increment() => count.value++;

  // ─── Image Picker ──────────────────────────────────────────────────────────
  Future<void> pickImages() async {
    final picked = await ImagePickerAndCropper.pickImage(
      color: Colors.deepPurple,
      textColor: Colors.white,
      dialogBackgroundColor: Colors.black,
      wantCropper: true,
      context: Get.context!,
    );
    
    print("Picked image: $picked");
    if (picked != null) {
      selectImage.value = picked;
      increment();
    }
  }

  // ─── Get Profile ───────────────────────────────────────────────────────────
  Future<void> getProfileApi() async {
    inAsyncCall.value = true;
    try {
      final body = {ApiKeyConstants.userId: userId};
      final model = await ApiMethods.getProfile(bodyParams: body);

      if (model != null && model.status == '1') {
        getProfileModelData = model;
        nameController.text = model.fullName ?? '';
        emailController.text = model.email ?? '';
        // Do NOT pre-fill password - leave blank for security
        passwordController.clear();
        profileImage.value = model.profilePhotoUrl ?? '';
        increment();
      }
    } catch (e) {
      debugPrint('getProfileApi error: $e');
    } finally {
      inAsyncCall.value = false;
    }
  }

  // ─── Validation ────────────────────────────────────────────────────────────
  String? _validate() {
    final name = nameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      return 'Full name is required.';
    }

    // Password is optional on update — only validate if user typed something
    if (password.isNotEmpty && password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null; // valid
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  Future<void> onClickUpdate() async {
    // Dismiss keyboard
    CommonMethods.unFocsKeyBoard();

    // Validate
    final error = _validate();
    if (error != null) {
      CommonWidgets.showMyToastMessage(error);
      return;
    }

    // Check internet
    if (!await CommonWidgets.internetConnectionCheckerMethod()) {
      CommonWidgets.snackBarView(
        title: 'Please check your internet connection',
        success: false,
      );
      return;
    }

    inAsyncCall.value = true;

    try {
      final body = <String, String>{
        ApiKeyConstants.userId: userId,
        ApiKeyConstants.fullName: nameController.text.trim(),
        ApiKeyConstants.email: emailController.text.trim(),
        // Only send password if user actually typed a new one
        if (passwordController.text.trim().isNotEmpty)
          ApiKeyConstants.password: passwordController.text.trim(),
      };

      debugPrint('Update Profile Body: $body');

      final result = await ApiMethods.updateProfileApi(
        bodyParams: body,
        image: selectImage.value,
      );

      if (result != null && result.status != '0') {
        CommonWidgets.showMyToastMessage('Profile updated successfully!');
        // Clear password field after successful update
        passwordController.clear();
        // Refresh profile data
        await getProfileApi();
      } else {
        CommonWidgets.showMyToastMessage(
          result?.message ?? 'Update failed. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('updateProfileApi error: $e');
      CommonWidgets.showMyToastMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      inAsyncCall.value = false;
    }
  }
}