import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';
import '../controllers/support_screen_controller.dart';

class SupportScreenView extends GetView<SupportScreenController> {
  const SupportScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      controller.count.value;
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientPurple1, // Dark purple top
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5, // Deep blue bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.px),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icBackRound,
                                  height: 31.px,
                                  width: 31.px),
                            ),
                            SizedBox(width: 3.px),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.AI_CHAT_SCREEN);
                              },
                              child: CommonWidgets.appIcons(
                                  assetName: IconConstants.icAiSetting,
                                  height: 32.px,
                                  width: 32.px,
                                  color: primary3Color),
                            ),
                            SizedBox(
                              width: 10.px,
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.NOTIFICATION_SCREEN);
                              },
                              child: CommonWidgets.appIcons(
                                  assetName: IconConstants.icNotificationTop,
                                  height: 26.px,
                                  width: 26.px),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.px,
                  ),
                  SizedBox(
                    height: 20.px,
                  ),
                  Column(
                    children: [
                      Text(
                        StringConstants.support,
                        style: MyTextStyle.titleStyleCustom(
                            24.px, FontWeight.w700, primaryColor2),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        StringConstants.supportText,
                        style: MyTextStyle.titleStyle16bw,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.px,
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
                    controller: controller.nameController,
                    focusNode: controller.focusNodeName,
                    isCard: controller.isName.value,
                    hintText: StringConstants.details,
                    maxLines: 5,
                    //labelText: StringConstants.fullName,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 80.px,
                  ),


                  Obx((){
                    controller.count.value;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.px),
                      child: CommonWidgets.commonElevatedButton(
                          height: 60.px,
                          borderRadius: 14.px,
                          buttonColor: primaryColor2,
                          onPressed: () {
                            controller.onClickUpdate();
                          },
                          child: Text(
                            StringConstants.send,
                            style: MyTextStyle.titleStyle18bw,
                          ),
                          showLoading: controller.showLoading.value),
                    );
                  }),

                  SizedBox(
                    height: 20.px,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }));
  }
}
