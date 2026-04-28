import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_sign_up_model.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/social_auth_service.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class SignUpController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeName = FocusNode();
  FocusNode focusNodeReferral = FocusNode();
  FocusNode focusNodeEmail = FocusNode();
  final isPassword = false.obs;
  final isName = false.obs;
  final isEmail = false.obs;
  final isReferral = false.obs;
  final count = 0.obs;
  final isHide = true.obs;
  final showLoading = false.obs;

  final showGoogleLoading = false.obs;
  final showFacebookLoading = false.obs;

  Map<String, String> bodyParamsForSend = {};

  void startListener() {
    focusNodePassword.addListener(onFocusChange);
    focusNodeName.addListener(onFocusChange);
    focusNodeEmail.addListener(onFocusChange);
    focusNodeReferral.addListener(onFocusChange);
  }

  void onFocusChange() {
    isPassword.value = focusNodePassword.hasFocus;
    isName.value = focusNodeName.hasFocus;
    isEmail.value = focusNodeEmail.hasFocus;
    isReferral.value = focusNodeReferral.hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    startListener();
  }



  void increment() => count.value++;

  void clickOnLogin() {
    Get.toNamed(Routes.LOGIN_SCREEN);
  }

  void onClickRegister() {
    Map<String, String> bodyParams = {
      ApiKeyConstants.from: ApiKeyConstants.signup,
    };

    signUpApiCalling();
  }

  signUpApiCalling() async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      // Get.offNamed(
      //   Routes.LOADER_SCREEN,
      // );

      if (nameController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty) {
        showLoading.value = true;
        Map<String, String> bodyParams = {
          ApiKeyConstants.fullName: nameController.text,
          ApiKeyConstants.email: emailController.text,
          ApiKeyConstants.password: passwordController.text,
          ApiKeyConstants.referralCode: referralController.text,
        };

        print("Check data :-- $bodyParams");
        try {
          SignupModel? signupModel =
              await ApiMethods.register(bodyParams: bodyParams);
          if (signupModel != null && signupModel.status != "0") {
            Map<String, String> bodyParams = {
              ApiKeyConstants.from: ApiKeyConstants.signup,
              ApiKeyConstants.email: emailController.text,
            };
            Get.offNamed(
              Routes.LOADER_SCREEN,
              parameters: bodyParams,
            );
          } else {
            CommonWidgets.showMyToastMessage(signupModel!.message ?? '');
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

  void onGoogleLogin() async {
    showGoogleLoading.value = true;
    try {
      final result = await SocialAuthService.signInWithGoogle();

      if (result == null) {
        CommonWidgets.showMyToastMessage('Google sign-in was cancelled.');
        return;
      }

      if (result['token']?.isEmpty ?? true) {
        CommonWidgets.showMyToastMessage('Failed to get Google token. Please try again.');
        return;
      }

      await _socialLoginApiCall(token: result['token']!, isGoogle: true);

    } catch (e) {
      if (e.toString().contains('network')) {
        CommonWidgets.showMyToastMessage('Network error. Please check your connection.');
      } else if (e.toString().contains('cancelled')) {
        CommonWidgets.showMyToastMessage('Google sign-in was cancelled.');
      } else {
        CommonWidgets.showMyToastMessage('Google sign-in failed. Please try again.');
      }
    } finally {
      showGoogleLoading.value = false;
    }
  }

  void onFacebookLogin() async {
    showFacebookLoading.value = true;
    try {
      final result = await SocialAuthService.signInWithFacebook();

      if (result == null) {
        CommonWidgets.showMyToastMessage('Facebook sign-in was cancelled.');
        return;
      }

      if (result['token']?.isEmpty ?? true) {
        CommonWidgets.showMyToastMessage('Failed to get Facebook token. Please try again.');
        return;
      }

      await _socialLoginApiCall(token: result['token']!, isGoogle: false);

    } catch (e) {
      if (e.toString().contains('network')) {
        CommonWidgets.showMyToastMessage('Network error. Please check your connection.');
      } else if (e.toString().contains('cancelled')) {
        CommonWidgets.showMyToastMessage('Facebook sign-in was cancelled.');
      } else {
        CommonWidgets.showMyToastMessage('Facebook sign-in failed. Please try again.');
      }
    } finally {
      showFacebookLoading.value = false;
    }
  }

  Future<void> _socialLoginApiCall({
    required String token,
    required bool isGoogle,
  }) async {
    if (!await CommonWidgets.internetConnectionCheckerMethod()) {
      CommonWidgets.snackBarView(
          title: 'Please Check Your Internet Connection', success: false);
      return;
    }

    final String fcmToken = 'your_fcm_token'; // replace with your FCM retrieval

    final Map<String, dynamic> bodyParams = {
      'token': token,
      'fcm_token': fcmToken,
    };

    try {
      final response = isGoogle
          ? await ApiMethods.googleLogin(bodyParams: bodyParams)
          : await ApiMethods.facebookLogin(bodyParams: bodyParams);

      if (response != null && response.status != "0") {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString(ApiKeyConstants.token, response.resetToken ?? '');
        sp.setString(ApiKeyConstants.userId, response.id.toString());
        Get.offNamed(Routes.NAV_BAR_SCREEN);
      } else if (response == null) {
        CommonWidgets.showMyToastMessage(
            'Server error. Please try again later.');
      } else {
        // Show the exact message from the API
        CommonWidgets.showMyToastMessage(
            response.message?.isNotEmpty == true
                ? response.message!
                : 'Login failed. Please try again.');
      }
    } catch (e) {
      CommonWidgets.showMyToastMessage(
          'Something went wrong. Please try again.');
    }
  }
}
