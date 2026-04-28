import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/otp_verify_screen_controller.dart';

class OtpVerifyScreenView extends GetView<OtpVerifyScreenController> {
  const OtpVerifyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: darkModeBlack,
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.px),
                child: Obx(() {
                  controller.count.value;
                  return ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
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
                            "Enter the",
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
                            "code",
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter the 4 digit code that we just sent to",
                            style: TextStyle(
                              fontSize: 12.px,
                              fontWeight: FontWeight.w400,
                              color: textColorLite,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.parameters[ApiKeyConstants.email] ??
                                '' "jonathan@email.com",
                            style: TextStyle(
                              fontSize: 12.px,
                              fontWeight: FontWeight.w400,
                              color: textColorLite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                      CommonWidgets.commonOtpView(
                          onChanged: (value) {
                            if (value.length == 4) {
                              // Map<String, String> bodyParams = {
                              //   ApiKeyConstants.from: ApiKeyConstants.otp,
                              // };
                              //
                              // Get.toNamed(Routes.LOADER_SCREEN,
                              //     parameters: bodyParams);

                              print("data is ${controller.parameters[ApiKeyConstants.from]}");
                              if (controller.parameters[ApiKeyConstants.from] ==
                                  ApiKeyConstants.signup) {
                                controller.otpVerifyApiCalling();
                              } else {
                                controller.otpVerifyPasswordApiCalling();
                              }
                            }
                          },
                          controller: controller.pin,
                          width: 74.px,
                          height: 70.px),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height / 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5FA),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer,
                                    color: Color(0xFF4A4A87)),
                                const SizedBox(width: 8),
                                Text(
                                  "00.${controller.secondsRemaining.value.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Color(0xFF4A4A87),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CommonWidgets.commonElevatedButton(
                          onPressed: () {
                            controller.clickOnLogin();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                StringConstants.didNotGetOtp.tr,
                                style: MyTextStyle.titleStyleCustom(
                                    16.px, FontWeight.w400, textColorLite),
                              ),
                              SizedBox(
                                width: 6.px,
                              ),
                              controller.enableResend.value
                                  ? GestureDetector(
                                      onTap: controller.resendOtp,
                                      child: Text(
                                        StringConstants.resendOTP.tr,
                                        style: MyTextStyle.titleStyleCustom(
                                            16.px,
                                            FontWeight.w700,
                                            primaryColor2),
                                      ),
                                    )
                                  : Text(
                                      StringConstants.resendOTP.tr,
                                      style: MyTextStyle.titleStyleCustom(16.px,
                                          FontWeight.w700, primaryColor2),
                                    ),
                            ],
                          ),
                          buttonColor: Colors.transparent),
                      const SizedBox(height: 80),
                    ],
                  );
                }))));
  }
}
