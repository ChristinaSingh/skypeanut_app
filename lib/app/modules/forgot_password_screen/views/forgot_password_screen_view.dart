import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/forgot_password_screen_controller.dart';

class ForgotPasswordScreenView extends GetView<ForgotPasswordScreenController> {
  const ForgotPasswordScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: darkModeBlack,
        body: Obx(() {
          controller.count.value;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.px),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        child: CommonWidgets.appIcons(
                            assetName: IconConstants.icBackPng,
                            height: 31.px,
                            width: 31.px),
                        onTap: () {
                          Get.back();
                        },
                      ),

                    ],
                  ),
                  SizedBox(
                    height: 30.px,
                  ),
                  Text(
                    StringConstants.passwordReset.tr,
                    style: MyTextStyle.titleStyle24bb,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8.px,
                  ),
                  Text(
                    StringConstants.pleasePutYourMobileNumberToReset,
                    style: MyTextStyle.titleStyle14blb,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 30.px,
                  ),
                  Container(
                    padding: EdgeInsets.all(8.px),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.px),
                        border: Border.all(
                            color: controller.isEmail.value
                                ? primaryColor
                                : Colors.grey.withOpacity(0.5))),
                    child: Row(
                      children: [
                        CommonWidgets.appIcons(
                            assetName: IconConstants.icEmailBox,
                            height: 76.px,
                            width: 76.px),
                        SizedBox(
                          width: 5.px,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringConstants.email.tr,
                                style: MyTextStyle.titleStyle16bb,
                                textAlign: TextAlign.center,
                              ),
                              TextFormField(
                                focusNode: controller.focusNodeEmail,
                                controller: controller.emailController,
                                style: MyTextStyle.titleStyle14bb,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: StringConstants.hintEmail.tr,
                                  hintStyle: MyTextStyle.titleStyle14b,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.px,
                  ),

                  const Spacer(),
                  CommonWidgets.commonElevatedButton(
                    buttonColor: primaryColor2,
                      onPressed: () {
                        controller.clickOnSubmitButton();
                      },
                      child: Text(
                        StringConstants.sendResetLink,
                        style: MyTextStyle.titleStyle18bw,
                      ),
                      showLoading: controller.showLoading.value),
                  SizedBox(
                    height: 20.px,
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
