import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_forgot_model.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class ForgotPasswordScreenController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodeMobile = FocusNode();
  final isEmail = false.obs;
  final isMobile = false.obs;
  final count = 0.obs;
  final showLoading = false.obs;
  final countryDailCode = '+91'.obs;

  void startListener() {
    focusNodeEmail.addListener(onFocusChange);
    focusNodeMobile.addListener(onFocusChange);
  }

  void onFocusChange() {
    isEmail.value = focusNodeEmail.hasFocus;
    isMobile.value = focusNodeMobile.hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    startListener();
  }



  clickOnCountryCode({required CountryCode value}) {
    countryDailCode.value = value.dialCode.toString();
  }

  void increment() => count.value++;

  void clickOnSubmitButton() {
    signUpApiCalling();
  }

  signUpApiCalling() async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      if (emailController.text.trim().isNotEmpty) {
        showLoading.value = true;
        Map<String, String> bodyParams = {
          ApiKeyConstants.email: emailController.text,
        };

        print("Check data :-- $bodyParams");
        try {
          ForgotPasswordModel? forgotPasswordModel =
              await ApiMethods.forGotPasswordApi(bodyParams: bodyParams);
          if (forgotPasswordModel != null &&
              forgotPasswordModel.status != "0") {
            Map<String, String> bodyParams = {
              ApiKeyConstants.from: ApiKeyConstants.password,
              ApiKeyConstants.email: emailController.text,
            };

            Get.offNamed(Routes.LOADER_SCREEN, parameters: bodyParams);
          } else {
            CommonWidgets.showMyToastMessage(forgotPasswordModel!.message ?? '');
          }
          showLoading.value = false;
        } catch (e) {
          showLoading.value = false;
          CommonWidgets.showMyToastMessage(
              'Enter unique email...');
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
}
