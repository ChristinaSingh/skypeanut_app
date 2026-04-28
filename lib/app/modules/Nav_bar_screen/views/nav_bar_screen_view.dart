import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/colors.dart';

import '../../../common/common_methods.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/string_constants.dart';
import '../controllers/nav_bar_screen_controller.dart';

class NavBarScreenView extends GetView<NavBarScreenController> {
  const NavBarScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: controller.body(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: darkModeBlack,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.px, vertical: 8.px),
                        child: GNav(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.px, vertical: 4.px),
                          tabs: [
                            button(
                                image: IconConstants.icHome,
                                text: StringConstants.home,
                                index: 0),
                            button(
                                image: IconConstants.icCloud,
                                text: StringConstants.weather,
                                index: 1),
                            button(
                                image: IconConstants.icInfo,
                                text: StringConstants.nOTAMs,
                                index: 2),
                            button(
                                image: IconConstants.icRoutes,
                                text: StringConstants.routes,
                                index: 3),
                            button(
                                image: IconConstants.icNotificationBellIcon,
                                text: StringConstants.notifications,
                                index: 4),
                            button(
                                image: IconConstants.icSetting,
                                text: StringConstants.setting,
                                index: 5),
                          ],
                          selectedIndex: selectedIndex.value,
                          onTabChange: (index) =>
                              controller.clickOnTab(index: index),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  button({required String image, required String text, required int index}) {
    return GButton(
      icon: Icons.add,
      leading: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonMethods.iconLinearGradient(
            assetName: image,
            value: selectedIndex.value == index,
            primaryColor: true,
          ),
          SizedBox(height: 2.px),
          CommonMethods.textViewLinearGradient(
            text: text,
            style: Theme.of(Get.context!)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 8.px),
            value: selectedIndex.value == index,
            primaryColor: true,
          ),
          SizedBox(height: 8.px),
          Container(
            height: 3.px,
            width: 30.px,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3.px),
                  bottomRight: Radius.circular(3.px),
                ),
                color: selectedIndex.value == index
                    ? primaryColor2
                    : Colors.transparent),
          )
        ],
      ),
    );
  }
}
