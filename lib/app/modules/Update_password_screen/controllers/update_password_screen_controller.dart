import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/password_update_model.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class UpdatePasswordScreenController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeName = FocusNode();
  FocusNode focusNodeConfirmPass = FocusNode();
  final isPassword = false.obs;
  final isName = false.obs;
  final isConfirmPass = false.obs;
  final count = 0.obs;
  final isHide = true.obs;
  final isHideConfirm = true.obs;
  final showLoading = false.obs;

  Map<String, String> bodyParamsForSend = {};
  Map<String, String?> parameters = Get.parameters;

  void startListener() {
    focusNodePassword.addListener(onFocusChange);
    focusNodeName.addListener(onFocusChange);
    focusNodeConfirmPass.addListener(onFocusChange);
  }

  void onFocusChange() {
    isPassword.value = focusNodePassword.hasFocus;
    isName.value = focusNodeName.hasFocus;
    isConfirmPass.value = focusNodeConfirmPass.hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    startListener();
  }



  void increment() => count.value++;

  void onClickRegister() {
    updateApiCalling();
  }


  updateApiCalling() async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      if (confirmPassController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty) {
        showLoading.value = true;
        Map<String, String> bodyParams = {
          ApiKeyConstants.email: parameters[ApiKeyConstants.email] ?? '',
          ApiKeyConstants.password: confirmPassController.text,
        };

        print("Check data :-- $bodyParams");
        try {
          PasswordUpdateModel? passwordUpdateModel =
          await ApiMethods.updatePassword(bodyParams: bodyParams);
          if (passwordUpdateModel != null && passwordUpdateModel.status != "0") {
            Get.offAllNamed(Routes.LOGIN_SCREEN);
          } else {
            CommonWidgets.showMyToastMessage(passwordUpdateModel!.message ?? '');
          }
          showLoading.value = false;
        } catch (e) {
          showLoading.value = false;
          CommonWidgets.showMyToastMessage(
              'Enter unique ConfirmPass and phone number...');
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
