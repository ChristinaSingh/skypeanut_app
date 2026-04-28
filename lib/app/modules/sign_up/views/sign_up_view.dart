import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/colors.dart';

import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

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
                              "Create your",
                              style: TextStyle(
                                fontSize: 25.px,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w600,
                                color: textColorLite,
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              "account",
                              style: TextStyle(
                                fontSize: 25.px,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w600,
                                color: primaryColor2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Weather, forecasts, NOTAMs, route search, and live flight tracking for smarter flying.",
                          style: TextStyle(
                            fontSize: 12.px,
                            fontWeight: FontWeight.w400,
                            color: textColorLite,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CommonWidgets.commonTextFieldForLoginSignUP(
                          controller: controller.nameController,
                          focusNode: controller.focusNodeName,
                          isCard: controller.isName.value,
                          hintText: StringConstants.fullName,
                          //labelText: StringConstants.fullName,
                          keyboardType: TextInputType.name,
                          prefixIcon: controller.isName.value
                              ? CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icProfileActive,
                                  height: 20.px,
                                  color: primaryColor2,
                                  width: 20.px)
                              : CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icProfileActive,
                                  height: 20.px,
                                  width: 20.px),
                        ),
                        CommonWidgets.commonTextFieldForLoginSignUP(
                          focusNode: controller.focusNodeEmail,
                          controller: controller.emailController,
                          isCard: controller.isEmail.value,
                          hintText: StringConstants.email,
                          // labelText: StringConstants.email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: controller.isEmail.value
                              ? CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icEmailActive,
                                  height: 20.px,
                                  color: primaryColor2,
                                  width: 20.px)
                              : CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icEmailActive,
                                  height: 20.px,
                                  width: 20.px),
                        ),
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
                        SizedBox(
                          height: 10.px,
                        ),
                        Text(
                          "Have a referral code? Enter it here (optional).",
                          style: TextStyle(
                            fontSize: 12.px,
                            fontWeight: FontWeight.w400,
                            color: textColorLite,
                          ),
                        ),
                        SizedBox(
                          height: 10.px,
                        ),
                        CommonWidgets.commonTextFieldForLoginSignUP(
                          controller: controller.referralController,
                          focusNode: controller.focusNodeReferral,
                          isCard: controller.isReferral.value,
                          hintText: StringConstants.referralCode,
                          //labelText: StringConstants.fullName,
                          keyboardType: TextInputType.name,
                          prefixIcon: controller.isReferral.value
                              ? CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icRefferalCoin,
                                  height: 15.px,
                                  width: 15.px,
                                  color: primaryColor2)
                              : CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icRefferalCoin,
                                  height: 15.px,
                                  width: 15.px,
                                  color: primary3Color),
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
                                controller.onClickRegister();
                              },
                              child: Text(
                                StringConstants.register,
                                style: MyTextStyle.titleStyle18bw,
                              ),
                              showLoading: controller.showLoading.value),
                        ),
                        SizedBox(
                          height: 20.px,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Divider(
                                  height: 2.px,
                                  color: textColorLite,
                                )),
                                SizedBox(
                                  width: 10.px,
                                ),
                                Text(
                                  StringConstants.or.tr,
                                  style: MyTextStyle.titleStyleCustom(
                                      12.px, FontWeight.w600, greyColor),
                                ),
                                SizedBox(
                                  width: 10.px,
                                ),
                                Expanded(
                                    child: Divider(
                                  height: 2.px,
                                  color: textColorLite,
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 40.px,
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  controller.onGoogleLogin();
                                } catch (e) {
                                  CommonWidgets.showMyToastMessage(
                                      'Google sign-in failed. Please try again.');
                                }
                              },
                              child: Obx(() =>
                                  controller.showGoogleLoading.value
                                      ? SizedBox(
                                          height: 25.px,
                                          width: 25.px,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: primaryColor2,
                                          ),
                                        )
                                      : CommonWidgets.appIconsSvg(
                                          assetName: IconConstants.icGoogle,
                                          height: 25.px,
                                          width: 25.px)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40.px,
                        ),
                        CommonWidgets.commonElevatedButton(
                            onPressed: () {
                              controller.clickOnLogin();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  StringConstants.alreadyMessage.tr,
                                  style: MyTextStyle.titleStyleCustom(
                                      16.px, FontWeight.w400, textColorLite),
                                ),
                                SizedBox(
                                  width: 6.px,
                                ),
                                Text(
                                  StringConstants.signIn.tr,
                                  style: MyTextStyle.titleStyleCustom(
                                      16.px, FontWeight.w700, primaryColor2),
                                ),
                              ],
                            ),
                            buttonColor: Colors.transparent),
                      ],
                    ),
                  );
                }))));
  }
}
