import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/pressure_pain.dart';
import '../../../common/sunrise_custom_painter.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../../Nav_bar_screen/controllers/nav_bar_screen_controller.dart';
import '../controllers/weather_details_screen_controller.dart';

class WeatherDetailsScreenView extends GetView<WeatherDetailsScreenController> {
  const WeatherDetailsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    String formatTemp(double value) {
      return value % 1 == 0
          ? value.toInt().toString() // 25
          : value.toStringAsFixed(1); // 23.8
    }

    double mediaQueryHeight = MediaQuery.sizeOf(context).height;
    double mediaQueryWidth = MediaQuery.sizeOf(context).width;
    print('MediaQuery height :: ${mediaQueryHeight.toString()}');
    print('MediaQuery width :: ${mediaQueryWidth.toString()}');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(body: Obx(() {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        InkWell(
                          child: CommonWidgets.appIconsSvg(
                              assetName: IconConstants.icBackRound,
                              height: 31.px,
                              width: 31.px),
                          onTap: () {
                            Get.back();
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                          color: Colors.black.withOpacity(
                                              0.25), // shadow color
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
                                          color: Colors.black.withOpacity(
                                              0.25), // shadow color
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CommonWidgets.appIcons(
                                assetName: IconConstants.icNotificationTop,
                                height: 26.px,
                                width: 26.px),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                // Get.find<NavBarScreenController>()
                                //     .clickOnTab(index: 4);
                                Get.toNamed(Routes.WEATHER_SETTINGS_SCREEN)
                                    ?.then((_) {
                                  controller.getWeatherApiCalling();
                                });
                              },
                              child: CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icMenuSettingColor,
                                  height: 28.px,
                                  width: 28.px),
                            ),
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
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  controller.inAsyncCall.value
                      ? Shimmer.fromColors(
                          baseColor: gradientPurple1.withOpacity(.2.px),
                          highlightColor: Colors.white.withOpacity(0.4),
                          child: Container(
                            height: 100.px,
                            width: 100.px,
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primary3Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          controller
                              .extractEmoji(controller.emoji.value ?? 'Clear'),
                          style: TextStyle(
                              fontSize: 80.px,
                              shadows: [
                                Shadow(
                                  offset: Offset(5, 5),
                                  blurRadius: 50.0,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ],
                              fontWeight: FontWeight.w700),
                        ),

                  // CommonWidgets.appIcons(
                  //         assetName: IconConstants.icSunNotams,
                  //         height: 140.px,
                  //         width: 140.px),
                  Obx(() {
                    controller.count.value;
                    return controller.inAsyncCall.value
                        ? Shimmer.fromColors(
                            baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                            highlightColor: Colors.white.withOpacity(0.4),
                            child: Container(
                              height: 30,
                              width: 200,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primary3Color,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Text(
                            'H:${controller.highTemperature} ${controller.temperatureUnit.value} | L:${controller.lowTemperature} ${controller.temperatureUnit.value}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: mediaQueryWidth >= 400 ? 25 : 20,
                                fontWeight: FontWeight.w600),
                          );
                  }),
                  Obx(() {
                    controller.count.value;
                    return controller.inAsyncCall.value
                        ? Shimmer.fromColors(
                            baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                            highlightColor: Colors.white.withOpacity(0.4),
                            child: Container(
                              height: 40,
                              width: 200,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primary3Color,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Text(
                            '${formatTemp(controller.temperature.value)} ${controller.temperatureUnit.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: mediaQueryWidth >= 400 ? 50 : 40,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                  }),
                  Obx(() {
                    controller.count.value;
                    return controller.inAsyncCall.value
                        ? Shimmer.fromColors(
                            baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                            highlightColor: Colors.white.withOpacity(0.4),
                            child: Container(
                              height: 30,
                              width: 200,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primary3Color,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Text(
                            controller.fixUtf8(
                                controller.cityNearby.value ?? "Paris"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: mediaQueryWidth >= 400 ? 24 : 20,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                  }),
                  SizedBox(
                    height: 32.px,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.px),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
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
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.wb_sunny_outlined,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text(
                                                "UV INDEX",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${controller.uvIndex}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            controller.uvLevel,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(() {
                                            controller.count.value;
                                            return Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple,
                                                    Colors.pink
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  // Calculate position ratio
                                                  double widthFactor =
                                                      controller.uvIndex.value /
                                                          11;
                                                  double leftOffset =
                                                      constraints.maxWidth *
                                                          widthFactor;

                                                  return Stack(
                                                    children: [
                                                      AnimatedPositioned(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                        curve: Curves.easeInOut,
                                                        left: leftOffset - 4,
                                                        // subtract radius for center alignment
                                                        top: 0,
                                                        // center the circle vertically in the 6px height bar
                                                        child:
                                                            const CircleAvatar(
                                                          radius: 3,
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                        ],
                                      ),
                                    )

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/UV_INDEX_0.png"),
                                    ),
                              ),
                        SizedBox(
                          width: 14.px,
                        ),
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
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
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.wb_twighlight,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text("SUNRISE",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            controller.sunrise.value,
                                            style: TextStyle(
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 25
                                                  : 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Expanded(
                                            child: CustomPaint(
                                              painter: SunPathPainter(
                                                  controller.progress.value),
                                              child: Container(),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Sunset: ${controller.sunset.value}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    )

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/UV_SUNRISE.png"),
                                    ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16.px,
                  ),

                  Obx(() {
                    controller.count.value;
                    final double windSpeedValue = double.tryParse(
                          controller.windSpeed.value
                              .toString()
                              .split(' ')
                              .first,
                        ) ??
                        0.0;

                    // Choose border color based on speed
                    final Color borderColor = windSpeedValue > 20
                        ? Colors.redAccent
                        : Color(0xff45319e);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.px),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          controller.inAsyncCall.value
                              ? Shimmer.fromColors(
                                  baseColor:
                                      Color(0xFF3C3C98).withOpacity(.2.px),
                                  highlightColor: Colors.white.withOpacity(0.4),
                                  child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Neumorphic(
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
                                        Colors.black.withOpacity(0.5),
                                    shadowLightColor:
                                        Colors.white.withOpacity(0.4),
                                  ),
                                  child: Container(
                                      height: 140.px,
                                      width: 140.px,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25.px),
                                        border: Border.all(
                                            width: 1.px, color: borderColor),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1B1142),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                              color: borderColor,
                                              width: 1), // mimic red glow
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.air,
                                                    color: Colors.white70,
                                                    size: 18),
                                                SizedBox(width: 4),
                                                Text("WIND",
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Compass base
                                                  Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.white30,
                                                          width: 1),
                                                    ),
                                                  ),

                                                  // Rotating compass
                                                  Transform.rotate(
                                                    angle: (controller
                                                            .windDirection
                                                            .value) *
                                                        (3.14159265 / 180),
                                                    child: SizedBox(
                                                      width: 100,
                                                      height: 100,
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          // Direction labels
                                                          Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Text('N',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Text('S',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text('W',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text('E',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),

                                                          // Tick marks
                                                          Positioned(
                                                            top: 0,
                                                            child: Container(
                                                                width: 2,
                                                                height: 8,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            child: Container(
                                                                width: 2,
                                                                height: 8,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Positioned(
                                                            left: 0,
                                                            child: Container(
                                                                width: 8,
                                                                height: 2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            child: Container(
                                                                width: 8,
                                                                height: 2,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  // Wind speed in center
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        controller
                                                            .windSpeed.value
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              mediaQueryWidth >=
                                                                      400
                                                                  ? 28
                                                                  : 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      // In the wind compass card, replace the windSpeed Text column with:
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (controller
                                                              .windDirectionLabel
                                                              .value
                                                              .isNotEmpty)
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: primaryColor2
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                border: Border.all(
                                                                    color: primaryColor2
                                                                        .withOpacity(
                                                                            0.5)),
                                                              ),
                                                              child: Text(
                                                                controller
                                                                    .windDirectionLabel
                                                                    .value,
                                                                style:
                                                                    const TextStyle(
                                                                  color:
                                                                      primaryColor2,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  letterSpacing:
                                                                      1,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                      // CommonWidgets.appIcons(
                                      //     assetName: "assets/images/WIND.png"),
                                      ),
                                ),
                          SizedBox(
                            width: 14.px,
                          ),
                          controller.inAsyncCall.value
                              ? Shimmer.fromColors(
                                  baseColor:
                                      Color(0xFF3C3C98).withOpacity(.2.px),
                                  highlightColor: Colors.white.withOpacity(0.4),
                                  child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Neumorphic(
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
                                        Colors.black.withOpacity(0.5),
                                    shadowLightColor:
                                        Colors.white.withOpacity(0.4),
                                  ),
                                  child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.grain,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text("RAINFALL",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "${controller.lastHourRain.value.toStringAsFixed(1)} mm",
                                            style: TextStyle(
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 12
                                                  : 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "in last hour",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: mediaQueryWidth >= 400
                                                    ? 10
                                                    : 10),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${controller.next24hRain.value.toStringAsFixed(1)} mm expected in\nnext 24h.",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: mediaQueryWidth >= 400
                                                    ? 14
                                                    : 10),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/RAINFALL.png"),
                                  ),
                                )
                        ],
                      ),
                    );
                  }),

                  SizedBox(
                    height: 16.px,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.px),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
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
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(25.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.thermostat,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text("FEELS LIKE",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${formatTemp(controller.feelsLikeTemp.value)} ${controller.temperatureUnit.value}",
                                            style: TextStyle(
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 18
                                                  : 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            controller.note.value,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 14
                                                  : 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/FEELS_LIKE.png"),
                                    ),
                              ),
                        SizedBox(
                          width: 14.px,
                        ),
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
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
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(22.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.water_drop,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text("HUMIDITY",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${controller.humidity.value}%",
                                            style: TextStyle(
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 20
                                                  : 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "The dew point is ${controller.dewPoint.value.toStringAsFixed(1)}° right now.",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 14
                                                  : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/HUMIDITY.png"),
                                    ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16.px,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.px),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
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
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                    height: 140.px,
                                    width: 140.px,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(25.px),
                                      border: Border.all(
                                          width: 2.px,
                                          color: Color(0xff45319e)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 180,
                                      height: 180,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1142),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.remove_red_eye,
                                                  color: Colors.white70,
                                                  size: 18),
                                              SizedBox(width: 4),
                                              Text("VISIBILITY",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "${controller.visibilityKm.value} ${controller.visibilityUnit.value}",
                                            style: TextStyle(
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 30
                                                  : 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            controller.description.value,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: mediaQueryWidth >= 400
                                                  ? 14
                                                  : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                    // CommonWidgets.appIcons(
                                    //     assetName: "assets/images/VISIBILITY.png"),
                                    ),
                              ),
                        SizedBox(
                          width: 14.px,
                        ),
                        // PRESSURE CARD - FIXED
                        controller.inAsyncCall.value
                            ? Shimmer.fromColors(
                                baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                                highlightColor: Colors.white.withOpacity(0.4),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Neumorphic(
                                style: NeumorphicStyle(
                                  depth: 10,
                                  intensity: 0.8,
                                  surfaceIntensity: 0.3,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(24)),
                                  lightSource: LightSource.topLeft,
                                  color: Colors.transparent,
                                  shadowDarkColor:
                                      Colors.black.withOpacity(0.5),
                                  shadowLightColor:
                                      Colors.white.withOpacity(0.4),
                                ),
                                child: Container(
                                  height: 140.px,
                                  width: 140.px,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.px),
                                    border: Border.all(
                                        width: 2.px, color: Color(0xff45319e)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B1142),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 20),
                                            Icon(Icons.speed,
                                                color: Colors.white70,
                                                size: 18),
                                            SizedBox(width: 4),
                                            Text(
                                              "PRESSURE",
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Obx(() => CustomPaint(
                                                        painter:
                                                            PressureGaugePainter(
                                                                controller
                                                                    .pressurePercent
                                                                    .value),
                                                        size: Size(97, 97),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // FIXED: Show actual pressure value, not percentage
                                                      Obx(() => Text(
                                                            controller
                                                                .pressure.value,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  mediaQueryWidth >=
                                                                          400
                                                                      ? 16
                                                                      : 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )),
                                                      const SizedBox(height: 2),
                                                      Obx(() => Text(
                                                            controller
                                                                .pressureUnit
                                                                .value,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 10,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                          height: 15),
                                                    ],
                                                  ),
                                                  SizedBox(width: 20)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.px,
                  ),

                  controller.inAsyncCall.value
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Shimmer.fromColors(
                            baseColor: Color(0xFF3C3C98).withOpacity(.2),
                            highlightColor: Colors.white.withOpacity(0.4),
                            child: Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: primary3Color,
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        )
                      : _aqiCard(mediaQueryWidth),

                  // Neumorphic(
                  //   style: NeumorphicStyle(
                  //     depth: 10,
                  //     intensity: 0.8,
                  //     surfaceIntensity: 0.3,
                  //     boxShape:
                  //         NeumorphicBoxShape.roundRect(BorderRadius.circular(24)),
                  //     lightSource: LightSource.topLeft,
                  //     color: Colors.transparent,
                  //     // Background base color
                  //     shadowDarkColor: Colors.black.withOpacity(0.5),
                  //     shadowLightColor: Colors.white.withOpacity(0.1),
                  //   ),
                  //   child: Container(
                  //     width: double.infinity,
                  //     margin: EdgeInsets.symmetric(horizontal: 20.px),
                  //     height: 180,
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [
                  //           Color(0xFF3C3C98).withOpacity(0.2),
                  //           Color(0xFF4B40C5).withOpacity(0.2),
                  //         ],
                  //       ),
                  //       borderRadius: BorderRadius.circular(24),
                  //     ),
                  //     padding: const EdgeInsets.all(20),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'Turbulence Forecast',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 20.px,
                  //             fontWeight: FontWeight.w700,
                  //           ),
                  //         ),
                  //         SizedBox(height: 20),
                  //         Row(
                  //           children: [
                  //             CommonWidgets.appIcons(
                  //                 assetName: IconConstants.icCloudWithRain,
                  //                 width: 67.px,
                  //                 height: 74.px),
                  //             SizedBox(
                  //               width: 15.px,
                  //             ),
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   'Rainfall 1.8 mm',
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 16.px,
                  //                     fontWeight: FontWeight.w700,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   'Turbulence Forecast: 60%  \n chance in 30 min.',
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 10.px,
                  //                     fontWeight: FontWeight.w700,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   'Due to wind shear (9 kt).',
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 10.px,
                  //                     fontWeight: FontWeight.w700,
                  //                   ),
                  //                 ),
                  //               ],
                  //             )
                  //           ],
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Stack(
                  //   children: [
                  //     Container(
                  //       height: 140.px,
                  //       width: MediaQuery.sizeOf(context).width,
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           begin: Alignment.topRight,
                  //           end: Alignment.bottomLeft,
                  //           colors: [
                  //             gradientPurple7.withOpacity(0.2),
                  //             gradientPurple6.withOpacity(0.2),
                  //           ],
                  //         ),
                  //         borderRadius: BorderRadius.circular(22.px),
                  //         border: Border.all(width: 2.px, color: Color(0xff45319e)),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.1),
                  //             blurRadius: 12,
                  //             spreadRadius: 2,
                  //             offset: Offset(0, -4),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //
                  //     // Inner glow simulation (top-left)
                  //     Positioned.fill(
                  //       child: ClipRRect(
                  //         borderRadius: BorderRadius.circular(22.px),
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topLeft,
                  //               end: Alignment.center,
                  //               colors: [
                  //                 Colors.black.withOpacity(0.2), // Light glow on top-left
                  //                 Colors.transparent,
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  SizedBox(
                    height: 40.px,
                  ),
                ],
              ),
            ),
          ),
        );
      })),
    );
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00cc00); // Good - green
    if (aqi <= 100) return const Color(0xFFEBC240); // Moderate - yellow
    if (aqi <= 140) return const Color(0xFFFF8C00); // Sensitive - orange
    if (aqi <= 200) return const Color(0xFFEA4658); // Unhealthy - red
    if (aqi <= 300) return const Color(0xFF9B2335); // Very Unhealthy - dark red
    return const Color(0xFF7E0023); // Hazardous - maroon
  }

  String _aqiFace(int aqi) {
    if (aqi <= 50) return '😊';
    if (aqi <= 100) return '😐';
    if (aqi <= 140) return '😷';
    if (aqi <= 200) return '🤢';
    return '☠️';
  }

  Widget _aqiCard(double mediaQueryWidth) {
    return Obx(() {
      final aqi = controller.aqiUs.value;
      final category = controller.aqiCategory.value;
      final pm25 = controller.aqiPm25.value;
      final pm10 = controller.aqiPm10.value;
      final color = _aqiColor(aqi);
      final face = _aqiFace(aqi);

      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(width: 1.5, color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 10,
            intensity: 0.8,
            surfaceIntensity: 0.3,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(24)),
            lightSource: LightSource.topLeft,
            color: Colors.transparent,
            shadowDarkColor: Colors.black.withOpacity(0.5),
            shadowLightColor: Colors.white.withOpacity(0.4),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1142),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: AQI badge + category + face ──
                Row(
                  children: [
                    // AQI number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$aqi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: mediaQueryWidth >= 400 ? 28 : 22,
                            ),
                          ),
                          Text(
                            'US AQI⁺',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Category text
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontSize: mediaQueryWidth >= 400 ? 18 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Face emoji
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: color.withOpacity(0.6), width: 1.5),
                        color: color.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          face,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withOpacity(0.6),
                      Colors.transparent,
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Bottom row: PM2.5 + PM10 ──
                Row(
                  children: [
                    _aqiPollutantChip(
                      label: 'PM2.5',
                      value: '${pm25.toStringAsFixed(1)} μg/m³',
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    _aqiPollutantChip(
                      label: 'PM10',
                      value: '${pm10.toStringAsFixed(1)} μg/m³',
                      color: color.withOpacity(0.7),
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

  Widget _aqiPollutantChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main pollutant',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
