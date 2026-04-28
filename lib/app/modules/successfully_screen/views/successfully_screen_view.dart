import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/colors.dart';
import 'package:skypeanut/app/routes/app_pages.dart';

import '../../../common/common_widgets.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/image_constants.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/successfully_screen_controller.dart';

class SuccessfullyScreenView extends GetView<SuccessfullyScreenController> {
  const SuccessfullyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkModeBlack,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.px),
          child: Column(
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
                height: 100.px,
              ),
              Center(
                child: Image.asset(
                  ImageConstants.imgSignSuccess,
                  height: 200.px,
                  width: 200.px,
                ),
              ),
              SizedBox(
                height: 60.px,
              ),
              Text(
                StringConstants.signSignUp.tr,
                textAlign: TextAlign.center,
                style: MyTextStyle.titleStyle20gr,
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.px),
                child: CommonWidgets.commonElevatedButton(
                  buttonColor: primaryColor2,
                  onPressed: () {
                    Get.toNamed(Routes.NAV_BAR_SCREEN);
                  },
                  child: Text(
                    StringConstants.skip.tr,
                    style: MyTextStyle.titleStyle18bw,
                  ),
                ),
              ),
              SizedBox(
                height: 80.px,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
