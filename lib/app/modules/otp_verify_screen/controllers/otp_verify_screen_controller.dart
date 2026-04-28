import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_verify_otp.dart';
import '../../../data/apis/api_models/verify_forgot_model.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class OtpVerifyScreenController extends GetxController {
  TextEditingController pin = TextEditingController();
  Map<String, String?> parameters = Get.parameters;
  final showLoading = false.obs;

  final count = 0.obs;


  void increment() => count.value++;

  var secondsRemaining = 30.obs;
  var enableResend = false.obs;
  late final timer;

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  void startTimer() {
    enableResend.value = false;
    secondsRemaining.value = 30;
    timer = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .take(31)
        .listen((tick) {
      secondsRemaining.value = 30 - tick;
      if (secondsRemaining.value == 0) {
        enableResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    // Your logic to resend OTP
    print("Resending OTP...");
    startTimer(); // Restart timer after resend
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }

  void clickOnLogin() {}

  otpVerifyApiCalling() async {
    if (pin.text.trim().isNotEmpty) {
      showLoading.value = true;
      Map<String, dynamic> bodyParams = {
        ApiKeyConstants.email: parameters[ApiKeyConstants.email] ?? '',
        ApiKeyConstants.otp: pin.text.toString(),
      };

      print("Check data :-- $bodyParams");
      try {
        VerifyModel? verifyModel =
            await ApiMethods.otpVerify(bodyParams: bodyParams);
        if (verifyModel != null && verifyModel.success != "0") {
          Get.offAllNamed(
            Routes.LOGIN_SCREEN,
          );
        } else {
          CommonWidgets.showMyToastMessage(
              verifyModel!.message ?? '');
        }
        showLoading.value = false;
      } catch (e) {
        showLoading.value = false;
        CommonWidgets.showMyToastMessage('Enter correct otp for verification');
      }
    } else {
      showLoading.value = false;
      CommonWidgets.showMyToastMessage(StringConstants.allFieldsRequired);
    }
  }
  otpVerifyPasswordApiCalling() async {
    if (pin.text.trim().isNotEmpty) {
      showLoading.value = true;
      Map<String, String> bodyParams = {
        ApiKeyConstants.email: parameters[ApiKeyConstants.email] ?? '',
        ApiKeyConstants.otp: pin.text.toString(),
      };

      print("Check data :-- $bodyParams");
      try {
        ForgotVerifyModel? verifyModel =
            await ApiMethods.otpForgotVerify(bodyParams: bodyParams);
        if (verifyModel != null && verifyModel.status == "1") {
          Get.offAllNamed(
            Routes.UPDATE_PASSWORD_SCREEN,parameters: bodyParams
          );
        } else {
          CommonWidgets.showMyToastMessage(
              verifyModel!.message ?? '');
        }
        showLoading.value = false;
      } catch (e) {
        showLoading.value = false;
        CommonWidgets.showMyToastMessage('Enter correct otp for verification');
      }
    } else {
      showLoading.value = false;
      CommonWidgets.showMyToastMessage(StringConstants.allFieldsRequired);
    }
  }
}
