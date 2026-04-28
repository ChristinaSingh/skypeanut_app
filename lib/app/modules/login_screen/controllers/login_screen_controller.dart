import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_log_in_model.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/microphone_dailog.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/social_auth_service.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class LoginScreenController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeName = FocusNode();
  FocusNode focusNodeEmail = FocusNode();
  final isPassword = false.obs;
  final isName = false.obs;
  final isEmail = false.obs;
  final count = 0.obs;
  final isHide = true.obs;
  final showLoading = false.obs;
  final showGoogleLoading = false.obs;
  final showFacebookLoading = false.obs;

  String _fcmToken = '';
  Map<String, String> bodyParamsForSend = {};

  void startListener() {
    focusNodePassword.addListener(onFocusChange);
    focusNodeName.addListener(onFocusChange);
    focusNodeEmail.addListener(onFocusChange);
  }

  void onFocusChange() {
    isPassword.value = focusNodePassword.hasFocus;
    isName.value = focusNodeName.hasFocus;
    isEmail.value = focusNodeEmail.hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    startListener();
    _initFcmToken();
  }

  // ─── FCM ───────────────────────────────────────────────────────────────────

  Future<void> _initFcmToken() async {
    try {
      // Request notification permission (iOS requires explicit permission)
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final String? token = await FirebaseMessaging.instance.getToken();
      _fcmToken = token ?? '';

      // Save FCM token to SharedPreferences for later use
      final SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(ApiKeyConstants.fcmToken, _fcmToken);

      if (kDebugMode) print('FCM Token: $_fcmToken');

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        final SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString(ApiKeyConstants.fcmToken, newToken);
        if (kDebugMode) print('FCM Token Refreshed: $_fcmToken');
      });
    } catch (e) {
      if (kDebugMode) print('FCM init error: $e');
      _fcmToken = '';
    }
  }

  Future<String> _getFcmToken() async {
    if (_fcmToken.isNotEmpty) return _fcmToken;
    // Fallback: try to get from SharedPreferences
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(ApiKeyConstants.fcmToken) ?? '';
  }

  // ─── NAVIGATION ────────────────────────────────────────────────────────────

  void increment() => count.value++;

  void clickOnLogin() {
    Get.toNamed(Routes.SIGN_UP);
  }

  void onClickRegister() {
    signUpApiCalling();
  }

  // ─── EMAIL LOGIN ───────────────────────────────────────────────────────────

  signUpApiCalling() async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      if (emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty) {
        showLoading.value = true;
        Map<String, String> bodyParams = {
          ApiKeyConstants.email: emailController.text,
          ApiKeyConstants.password: passwordController.text,
          ApiKeyConstants.fcmToken: _fcmToken,
        };

        if (kDebugMode) print("Check data :-- $bodyParams");
        try {
          LoginModel? loginModel =
              await ApiMethods.login(bodyParams: bodyParams);
          if (loginModel != null && loginModel.status != "0") {
            Map<String, String> bodyParams = {
              ApiKeyConstants.email: emailController.text,
              ApiKeyConstants.from: StringConstants.login,
            };
            SharedPreferences sp = await SharedPreferences.getInstance();
            sp.setString(ApiKeyConstants.token, loginModel.resetToken ?? '');
            sp.setString(ApiKeyConstants.userId, loginModel.id.toString());
            Get.offNamed(Routes.LOADER_SCREEN, parameters: bodyParams);
          } else {
            CommonWidgets.showMyToastMessage(loginModel!.message ?? '');
          }
          showLoading.value = false;
        } catch (e) {
          showLoading.value = false;
          CommonWidgets.showMyToastMessage(
              'Enter unique email and phone number...');
        }
      } else {
        showLoading.value = false;
        CommonWidgets.showMyToastMessage(StringConstants.allFieldsRequired);
      }
    } else {
      showLoading.value = false;
      CommonWidgets.snackBarView(
          title: 'Please Check Your Internet Connection', success: false);
    }
  }

  // ─── GOOGLE LOGIN ──────────────────────────────────────────────────────────

  void onGoogleLogin() async {
    showGoogleLoading.value = true;
    try {
      final result = await SocialAuthService.signInWithGoogle();

      if (result == null) {
        CommonWidgets.showMyToastMessage('Google sign-in was cancelled.');
        return;
      }

      if (result['token']?.isEmpty ?? true) {
        CommonWidgets.showMyToastMessage(
            'Failed to get Google token. Please try again.');
        return;
      }

      await _socialLoginApiCall(token: result['token']!, isGoogle: true);
    } catch (e) {
      if (e.toString().contains('network')) {
        CommonWidgets.showMyToastMessage(
            'Network error. Please check your connection.');
      } else if (e.toString().contains('cancelled')) {
        CommonWidgets.showMyToastMessage('Google sign-in was cancelled.');
      } else {
        CommonWidgets.showMyToastMessage(
            'Google sign-in failed. Please try again.');
      }
      if (kDebugMode) print('onGoogleLogin error: $e');
    } finally {
      showGoogleLoading.value = false;
    }
  }

  // ─── FACEBOOK LOGIN ────────────────────────────────────────────────────────

  void onFacebookLogin() async {
    showFacebookLoading.value = true;
    try {
      final result = await SocialAuthService.signInWithFacebook();

      if (result == null) {
        CommonWidgets.showMyToastMessage('Facebook sign-in was cancelled.');
        return;
      }

      if (result['token']?.isEmpty ?? true) {
        CommonWidgets.showMyToastMessage(
            'Failed to get Facebook token. Please try again.');
        return;
      }

      await _socialLoginApiCall(token: result['token']!, isGoogle: false);
    } catch (e) {
      if (e.toString().contains('network')) {
        CommonWidgets.showMyToastMessage(
            'Network error. Please check your connection.');
      } else if (e.toString().contains('cancelled')) {
        CommonWidgets.showMyToastMessage('Facebook sign-in was cancelled.');
      } else {
        CommonWidgets.showMyToastMessage(
            'Facebook sign-in failed. Please try again.');
      }
      if (kDebugMode) print('onFacebookLogin error: $e');
    } finally {
      showFacebookLoading.value = false;
    }
  }

  // ─── SHARED SOCIAL API CALL ────────────────────────────────────────────────

  Future<void> _socialLoginApiCall({
    required String token,
    required bool isGoogle,
  }) async {
    if (!await CommonWidgets.internetConnectionCheckerMethod()) {
      CommonWidgets.snackBarView(
          title: 'Please Check Your Internet Connection', success: false);
      return;
    }

    final String fcmToken = await _getFcmToken();
    if (kDebugMode) print('FCM Token used for social login: $fcmToken');

    final Map<String, dynamic> bodyParams = {
      'token': token,
      'fcm_token': fcmToken,
    };

    if (kDebugMode) print('Social login body: $bodyParams');

    try {
      final LoginModel? response = isGoogle
          ? await ApiMethods.googleLogin(bodyParams: bodyParams)
          : await ApiMethods.facebookLogin(bodyParams: bodyParams);

      if (response != null && response.status != "0") {
        // Success — save credentials
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString(ApiKeyConstants.token, response.resetToken ?? '');
        sp.setString(ApiKeyConstants.userId, response.id.toString());
        if (kDebugMode) print('Social login success: ${response.id}');
        Get.offNamed(Routes.NAV_BAR_SCREEN);
      } else if (response == null) {
        CommonWidgets.showMyToastMessage(
            'Server error. Please try again later.');
      } else {
        // Show exact message from API
        CommonWidgets.showMyToastMessage(
          response.message?.isNotEmpty == true
              ? response.message!
              : 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      if (kDebugMode) print('_socialLoginApiCall error: $e');
      CommonWidgets.showMyToastMessage(
          'Something went wrong. Please try again.');
    }
  }

  // ─── PERMISSION DIALOG ─────────────────────────────────────────────────────

  void showMicrophonePermissionDialog() {
    Get.dialog(
      LocationPermissionDialog(
        onAllow: () async {
          final result = await Permission.location.request();
          Get.back();
          if (result.isGranted) {
            Get.toNamed(Routes.NAV_BAR_SCREEN);
          } else {
            Get.snackbar(
              "",
              "",
              backgroundColor: Colors.redAccent,
              titleText: Text(
                "Permission",
                style: TextStyle(
                    color: primary3Color,
                    fontSize: 12.px,
                    fontWeight: FontWeight.w500),
              ),
              messageText: Text(
                "Permission denied",
                style: TextStyle(
                    color: primary3Color,
                    fontSize: 12.px,
                    fontWeight: FontWeight.w500),
              ),
            );
          }
        },
        onCancel: () {
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}
