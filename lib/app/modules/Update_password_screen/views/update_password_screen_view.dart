import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/update_password_screen_controller.dart';

class UpdatePasswordScreenView extends GetView<UpdatePasswordScreenController> {
  const UpdatePasswordScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: darkModeBlack,
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.px),
                child: Obx(() {
                  controller.count.value;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                            child: InkWell(
                              onTap: () {
                                Get.back();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icBackSignup,
                                height: 30.px,
                                width: 30.px,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.px,
                        ),
                        Row(
                          children: [
                            Text(
                              "Create New Password",
                              style: TextStyle(
                                fontSize: 25.px,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w600,
                                color: textColorLite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Your new password must be different from previous used passwords.",
                          style: TextStyle(
                            fontSize: 12.px,
                            fontWeight: FontWeight.w400,
                            color: textColorLite,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CommonWidgets.commonTextFieldForLoginSignUP(
                            focusNode: controller.focusNodePassword,
                            controller: controller.passwordController,
                            isCard: controller.isPassword.value,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: controller.isHide.value,
                            hintText: StringConstants.password,
                            // labelText: StringConstants.password,
                            prefixIcon: controller.isPassword.value
                                ? CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icPassActive,
                                    height: 20.px,
                                    color: primaryColor2,
                                    width: 20.px)
                                : CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icPassActive,
                                    height: 20.px,
                                    width: 20.px),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.isHide.value =
                                    !controller.isHide.value;
                                controller.increment();
                              },
                              child: Icon(
                                controller.isHide.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 25.px,
                                color: eyeColor,
                              ),
                            )),
                        CommonWidgets.commonTextFieldForLoginSignUP(
                            focusNode: controller.focusNodeConfirmPass,
                            controller: controller.confirmPassController,
                            isCard: controller.isConfirmPass.value,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: controller.isHideConfirm.value,
                            hintText: StringConstants.confirmPassword,
                            // labelText: StringConstants.password,
                            prefixIcon: controller.isConfirmPass.value
                                ? CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icPassActive,
                                    height: 20.px,
                                    color: primaryColor2,
                                    width: 20.px)
                                : CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icPassActive,
                                    height: 20.px,
                                    width: 20.px),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.isHideConfirm.value =
                                    !controller.isHideConfirm.value;
                                controller.increment();
                              },
                              child: Icon(
                                controller.isHideConfirm.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 25.px,
                                color: eyeColor,
                              ),
                            )),
                        SizedBox(
                          height: 10.px,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "",
                              style: MyTextStyle.titleStyleCustom(
                                  14.px, FontWeight.w600, primaryColor2),
                            ),
                            SizedBox(
                              width: 6.px,
                            ),

                            // Text(
                            //   StringConstants.showPassword.tr,
                            //   style: MyTextStyle.titleStyleCustom(
                            //       14.px, FontWeight.w600, primaryColor2),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 20.px,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.px),
                          child: CommonWidgets.commonElevatedButton(
                              height: 60.px,
                              borderRadius: 14.px,
                              buttonColor: primaryColor2,
                              onPressed: () {
                                if (controller.confirmPassController.text ==
                                    controller.passwordController.text) {
                                  controller.onClickRegister();
                                } else {
                                  CommonWidgets.showMyToastMessage(
                                    'Password and Confirm Password do not match.',
                                  );
                                }
                              },
                              child: Text(
                                StringConstants.save,
                                style: MyTextStyle.titleStyle18bw,
                              ),
                              showLoading: controller.showLoading.value),
                        ),
                        SizedBox(
                          height: 20.px,
                        ),
                      ],
                    ),
                  );
                }))));
  }
}
