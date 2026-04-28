import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/splash_lite_screen_controller.dart';

class SplashLiteScreenView extends GetView<SplashLiteScreenController> {
  const SplashLiteScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        //backgroundColor: backgroundColor,
        body: Obx(() {
          return Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.all(20.px),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                gradientPurple1, // Dark purple top
                gradientPurple2,
                gradientPurple3,
                gradientPurple4,
                gradientPurple5, // Deep blue bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Sized Box for logo
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  height: controller.animate.value ? 422.px : 222.px,
                  width: controller.animate.value ? 480.px : 160.px,
                  child: CommonWidgets.appIcons(
                    assetName: IconConstants.icSplashGreen,
                  //  color: primary3Color
                  ),
                ),

                // Gap animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: controller.animate.value ? 80.px : 30.px,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
