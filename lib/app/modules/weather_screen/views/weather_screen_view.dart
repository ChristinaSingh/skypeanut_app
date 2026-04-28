import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypeanut/app/data/constants/image_constants.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';
import '../../Up_comming_forcast_screem/controllers/up_comming_forcast_screem_controller.dart';
import '../controllers/weather_screen_controller.dart';

class WeatherScreenView extends GetView<WeatherScreenController> {
  const WeatherScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<WeatherScreenController>(
          () => WeatherScreenController(),
    );
    Get.lazyPut<UpCommingForcastScreemController>(
          () => UpCommingForcastScreemController(),
    );
    return Scaffold(body: Obx(() {
      controller.count.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, // or .dark
        child: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonWidgets.appIcons(
                              assetName: IconConstants.icLocationLite,
                              height: 31.px,
                              width: 31.px),
                          SizedBox(width: 3.px),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                controller.count.value;
                                return Text(
                                  userName.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 4),
                                        // horizontal and vertical offset
                                        blurRadius: 10.0,
                                        color: Colors.black
                                            .withOpacity(0.25), // shadow color
                                      ),
                                    ],
                                    fontSize: 20.px,
                                  ),
                                );
                              }),
                              Obx(() {
                                controller.count.value;
                                return Text(
                                  cityOne.value,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16.px,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 4),
                                        // horizontal and vertical offset
                                        blurRadius: 10.0,
                                        color: Colors.black
                                            .withOpacity(0.25), // shadow color
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     // Get.find<NavBarScreenController>()
                          //     //     .clickOnTab(index: 4);
                          //     Get.toNamed(Routes.NOTIFICATION_SCREEN,
                          //         parameters: {"fromScreen": "button"});
                          //   },
                          //   child: CommonWidgets.appIcons(
                          //       assetName: IconConstants.icNotificationTop,
                          //       height: 26.px,
                          //       width: 26.px),
                          // ),
                          // SizedBox(width: 10),
                          // CommonWidgets.appIcons(
                          //     assetName: IconConstants.icMenuSetting,
                          //     height: 32.px,
                          //     width: 32.px),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.AI_CHAT_SCREEN);
                            },
                            child: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icAiSetting,
                                height: 32.px,
                                width: 32.px,
                                color: primary3Color),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.px,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30.px,
                    ),
                    Text("Weather",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18.px,
                            color: textColorLite)),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            // Get.find<NavBarScreenController>()
                            //     .clickOnTab(index: 4);
                            Get.toNamed(Routes.WEATHER_SETTINGS_SCREEN)
                                ?.then((_) {
                              controller.getWeatherApiCalling(
                                  controller.lat.value, controller.long.value);
                            });
                          },
                          child: CommonWidgets.appIconsSvg(
                              assetName: IconConstants.icMenuSettingColor,
                              height: 28.px,
                              width: 28.px),
                        ),
                        SizedBox(width: 10),
                        // CommonWidgets.appIcons(
                        //     assetName: IconConstants.icUploadMenu,
                        //     height: 32.px,
                        //     width: 32.px),
                        // SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Get.find<UpCommingForcastScreemController>()
                                .isSearchVisible
                                .value = true;
                            Map<String, String> bodyParams = {
                              ApiKeyConstants.lat: controller.lat.value,
                              ApiKeyConstants.lon: controller.long.value,
                              ApiKeyConstants.city: cityOne.value,
                            };
                            Get.toNamed(Routes.UP_COMMING_FORCAST_SCREEM,
                                parameters: bodyParams);
                          },
                          child: CommonWidgets.appIcons(
                              assetName: IconConstants.icSearchMenu,
                              height: 32.px,
                              width: 32.px),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 30.px,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.px,
                ),
                controller.inAsyncCall.value
                    ? Expanded(
                  child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Color(0xffaaa5a5b2).withOpacity(0.5),
                        highlightColor: Colors.white.withOpacity(0.4),
                        child: Container(
                          height: 151,
                          width: 164,
                          // padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primary3Color,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : controller.getCitiesData.isNotEmpty
                    ? Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.getCurrentLocation(),
                    child: ListView.builder(
                      itemCount: controller.getCitiesData.length,
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                      final data = controller.getCitiesData[index];
                      return InkWell(
                        onTap: () {
                          Map<String, String> bodyParameter = {
                            ApiKeyConstants.city: controller
                                .fixUtf8(data.name ?? "Paris"),
                          };
                          Get.toNamed(Routes.WEATHER_DETAILS_SCREEN,
                              parameters: bodyParameter);
                        },
                        child: Neumorphic(
                          margin: EdgeInsets.all(16),
                          style: NeumorphicStyle(
                            depth: 10,
                            intensity: 0.8,
                            surfaceIntensity: 0.3,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(24)),
                            lightSource: LightSource.topLeft,
                            color: Colors.transparent,
                            // Background base color
                            shadowDarkColor:
                            Colors.white.withOpacity(0.4),
                            shadowLightColor:
                            Colors.red.withOpacity(0.1),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xffaaa5a5b2)
                                  .withOpacity(0.5),
                              // purplish background
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                // Left side content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.fixUtf8(
                                            data.name ?? "Paris"),
                                        style: TextStyle(
                                          fontSize: 24.px,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 10.0,
                                              color: Colors.black
                                                  .withOpacity(0.25),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        controller.extractCondition(
                                            data.condition ??
                                                'Clear'),
                                        style: TextStyle(
                                          fontSize: 16.px,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Visibility Row
                                      Row(
                                        children: [
                                          const Text(
                                            "Visibility:",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${data.visibility ?? "--"} ${controller.visibilityUnit.value}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),

                                      // Wind Row
                                      Row(
                                        children: [
                                          const Text(
                                            "Wind:",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Colors.yellow),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${data.wind ?? "--"} ${controller.windUnit.value}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          Map<String, String>
                                          bodyParameter = {
                                            ApiKeyConstants.city:
                                            data.name ?? "",
                                          };
                                          Get.toNamed(
                                              Routes
                                                  .WEATHER_DETAILS_SCREEN,
                                              parameters:
                                              bodyParameter);
                                        },
                                        child: const Text(
                                          "Show Details",
                                          style: TextStyle(
                                            color: Colors.white,
                                            decoration: TextDecoration
                                                .underline,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side image
                                Column(
                                  children: [
                                    Text(
                                      controller.extractEmoji(
                                          data.condition ?? 'Clear'),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 60.px,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(5, 5),
                                              blurRadius: 50.0,
                                              color: gradientPurple6
                                                  .withOpacity(0.5),
                                            ),
                                          ],
                                          fontWeight:
                                          FontWeight.w700),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.temperature
                                              ?.toStringAsFixed(
                                              1) ??
                                              '--',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 40.px,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          controller
                                              .temperatureUnit.value,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.px,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ),
                )
                    : Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.getCurrentLocation(),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 50.h,
                        child: Center(
                          child: CommonWidgets.dataNotFound(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }
}
