import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skypeanut/app/data/apis/api_models/support_model.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/constants/string_constants.dart';

class SupportScreenController extends GetxController {
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
  }



  void increment() => count.value++;

  void onClickUpdate() {
    updateApiCalling();
  }

  updateApiCalling() async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      if (emailController.text.trim().isNotEmpty &&
          nameController.text.trim().isNotEmpty) {
        showLoading.value = true;
        Map<String, String> bodyParams = {
          ApiKeyConstants.email: emailController.text ,
          ApiKeyConstants.details: nameController.text,
        };

        print("Check data :-- $bodyParams");
        try {
          SupportModel? supportModel =
          await ApiMethods.supportApi(bodyParams: bodyParams);
          if (supportModel != null && supportModel.status != "0") {
            increment();
          } else {
            CommonWidgets.showMyToastMessage(supportModel!.message ?? '');
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
