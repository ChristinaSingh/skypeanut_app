import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skypeanut/app/common/common_widgets.dart';
import 'package:skypeanut/app/data/constants/icons_constant.dart';
import 'package:skypeanut/app/modules/Nav_bar_screen/controllers/nav_bar_screen_controller.dart';

import '../../../common/colors.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_models/get_alerts_model.dart';
import '../../../data/apis/api_models/get_notam_by_airport_code.dart';
import '../../../routes/app_pages.dart';
import '../../Weather_settings_screen/controllers/weather_settings_screen_controller.dart';
import '../../notams_screen/controllers/notams_screen_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<WeatherSettingsScreenController>(
      () => WeatherSettingsScreenController(),
    );
    Get.lazyPut<NotamsScreenController>(
      () => NotamsScreenController(),
    );
    return Obx(() {
      controller.count.value;
      var children = [
        SizedBox(width: 10),
        InkWell(
          onTap: () {
            Get.toNamed(Routes.AI_CHAT_SCREEN);
          },
          child: CommonWidgets.appIconsSvg(
            assetName: IconConstants.icAiSetting,
            height: 32.px,
            color: primary3Color,
            width: 32.px,
          ),
        ),
        // SizedBox(width: 10),
        // InkWell(
        //   onTap: () {
        //     Get.toNamed(Routes.NOTIFICATION_SCREEN);
        //   },
        //   child: CommonWidgets.appIcons(
        //       assetName: IconConstants.icNotificationTop,
        //       height: 26.px,
        //       width: 26.px),
        // ),
      ];
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Obx(() {
                controller.count.value; // reactive trigger

                final isLoading = controller.inAsyncCall.value;
                final imagePath = controller.isNightTime.value
                    ? 'assets/images/night_city_view.png'
                    : 'assets/images/city_view_bg.png';

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient purple background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            gradientPurple4, // Dark purple top
                            gradientPurple5,
                            gradientPurple6,
                          ],
                        ),
                      ),
                    ),

                    // Image fades in smoothly
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      opacity: isLoading ? 0.0 : 1.0,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                );
              }),
            ),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: controller.refetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
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
                                      return controller.inAsyncCall.value
                                          ? Shimmer.fromColors(
                                              baseColor: Color(0xFF3C3C98)
                                                  .withOpacity(.2.px),
                                              highlightColor:
                                                  Colors.white.withOpacity(0.4),
                                              child: Container(
                                                height: 20,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  color: primary3Color,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      blurRadius: 5,
                                                      spreadRadius: 0,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Text(
                                              userName.value,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(0, 4),
                                                    blurRadius: 10.0,
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                  ),
                                                ],
                                                fontSize: 20.px,
                                              ),
                                            );
                                    }),
                                    SizedBox(
                                      height: 5.px,
                                    ),
                                    Obx(() {
                                      controller.count.value;
                                      return controller.inAsyncCall.value
                                          ? Shimmer.fromColors(
                                              baseColor: Color(0xFF3C3C98)
                                                  .withOpacity(.2.px),
                                              highlightColor:
                                                  Colors.white.withOpacity(0.4),
                                              child: Container(
                                                height: 20,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: primary3Color,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      blurRadius: 5,
                                                      spreadRadius: 0,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Text(
                                              cityOne.value,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16.px,
                                                fontWeight: FontWeight.w400,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(0, 4),
                                                    blurRadius: 10.0,
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                  ),
                                                ],
                                              ),
                                            );
                                    }),
                                    SizedBox(
                                      height: 6.px,
                                    ),
                                    Obx(() => controller.isOffline.value
                                        ? Container(
                                            padding: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 3,
                                                bottom: 3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              color: greenColor,
                                            ),
                                            child: Text(
                                              "Offline Mode: Data Cached",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        : const SizedBox.shrink()),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: children,
                                ),
                                SizedBox(
                                  height: 15.px,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.WEATHER_SETTINGS_SCREEN)
                                        ?.then((_) {
                                      controller.fetchHomeData();
                                    });
                                  },
                                  child: CommonWidgets.appIconsSvg(
                                      assetName:
                                          IconConstants.icMenuSettingColor,
                                      color: primary3Color,
                                      height: 25.px,
                                      width: 25.px),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Obx(() {
                          controller.count.value;
                          return controller.inAsyncCall.value
                              ? Shimmer.fromColors(
                                  baseColor:
                                      Color(0xFF3C3C98).withOpacity(.2.px),
                                  highlightColor: Colors.white.withOpacity(0.4),
                                  child: Container(
                                    height: 30,
                                    width: 150,
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primary3Color,
                                      borderRadius: BorderRadius.circular(24),
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
                                  controller.date.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                        }),
                      ),
                      controller.inAsyncCall.value
                          ? Shimmer.fromColors(
                              baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
                              highlightColor: Colors.white.withOpacity(0.4),
                              child: Container(
                                height: 20,
                                width: 180,
                                decoration: BoxDecoration(
                                  color: primary3Color,
                                  borderRadius: BorderRadius.circular(24),
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() {
                                  controller.count.value;
                                  return Text(
                                    'Updated',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.px,
                                        fontWeight: FontWeight.w300),
                                  );
                                }),
                                SizedBox(
                                  width: 4.px,
                                ),
                                Obx(() {
                                  controller.count.value; // reactive trigger
                                  return Text(
                                    controller.rawDate.value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.px,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  );
                                }),
                              ],
                            ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          controller.inAsyncCall.value
                              ? Shimmer.fromColors(
                                  baseColor:
                                      Color(0xFF3C3C98).withOpacity(.2.px),
                                  highlightColor: Colors.white.withOpacity(0.4),
                                  child: Container(
                                    height: 40.px,
                                    width: 40.px,
                                    margin: const EdgeInsets.only(right: 20),
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
                                  controller.extractEmoji(
                                      controller.weather?.condition ?? 'Clear'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 60.px,
                                      fontWeight: FontWeight.w700),
                                ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              Obx(() {
                                controller.count.value;
                                return controller.inAsyncCall.value
                                    ? Shimmer.fromColors(
                                        baseColor: Color(0xFF3C3C98)
                                            .withOpacity(.2.px),
                                        highlightColor:
                                            Colors.white.withOpacity(0.4),
                                        child: Container(
                                          height: 30,
                                          width: 80,
                                          margin: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: primary3Color,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                blurRadius: 5,
                                                spreadRadius: 0,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : controller
                                                .fixEncoding(controller
                                                        .weather?.condition ??
                                                    'Clear')
                                                .length >=
                                            6
                                        ? Text(
                                            controller.fixEncoding(
                                                controller.weather?.condition ??
                                                    'Clear'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.px,
                                                fontWeight: FontWeight.w700),
                                          )
                                        : Text(
                                            controller.fixEncoding(
                                                controller.weather?.condition ??
                                                    'Clear'),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30.px,
                                                fontWeight: FontWeight.w700),
                                          );
                              }),
                              Obx(() {
                                controller.count.value;
                                return controller.inAsyncCall.value
                                    ? Shimmer.fromColors(
                                        baseColor: Color(0xFF3C3C98)
                                            .withOpacity(.2.px),
                                        highlightColor:
                                            Colors.white.withOpacity(0.4),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: primary3Color,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                blurRadius: 5,
                                                spreadRadius: 0,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : controller
                                                .fixEncoding(controller
                                                        .weather?.condition ??
                                                    'Clear')
                                                .length >=
                                            6
                                        ? Text(
                                            controller.settings.temperatureUnit
                                                        .value ==
                                                    "°F"
                                                ? '${double.parse(controller.temperature.value.toString()).toStringAsFixed(1)}°F'
                                                : '${double.parse(controller.temperature.value.toString()).toStringAsFixed(1)}°C',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40.px,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : Text(
                                            controller.settings.temperatureUnit
                                                        .value ==
                                                    "°F"
                                                ? '${controller.temperature.value}°F'
                                                : '${controller.temperature.value}°C',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 60.px,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                              }),
                            ],
                          ),
                        ],
                      ),
                      aqiSection(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _weatherIcon(
                              IconConstants.icHumidity,
                              'Visibility',
                              controller.visibility.value,
                              controller.settings.visibilityUnit),
                          _weatherRed(
                              IconConstants.icWind,
                              'Wind',
                              controller.windSpeed.value,
                              controller.settings.windUnit),
                          _weatherIcon(
                            IconConstants.icTemp,
                            'Temperature',
                            double.parse(
                                    controller.temperature.value.toString())
                                .toStringAsFixed(1),
                            controller.settings.temperatureUnit,
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _weatherIcon(
                              IconConstants.icCloudHome,
                              'Dew',
                              '${controller.due.value}%',
                              controller.settings.dewPointUnit),
                          _weatherIcon(
                              IconConstants.icPressureHome,
                              'Pressure',
                              controller.pressure.value,
                              controller.settings.pressureUnit),
                          _weatherIcon(
                              IconConstants.icForecastHome,
                              'Forecast',
                              controller.forecast.value,
                              controller.settings.temperatureUnit),
                        ],
                      ),
                      SizedBox(height: 35.px),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        child: Column(
                          children: [
                            SizedBox(height: 30.px),
                            controller.alertsListNew.isEmpty
                                ? SizedBox.shrink()
                                : Obx(() {
                                    if (controller.inAsyncCallForAlert.value) {
                                      return _shimmerCard();
                                    }

                                    if (controller.alertsListNew.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      children: [
                                        _textSeeAll("Alerts", "See All"),
                                        const SizedBox(height: 23),
                                        SizedBox(
                                          height: 200,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: PageView.builder(
                                                  controller:
                                                      controller.pageController,
                                                  itemCount: controller
                                                      .alertsListNew.length,
                                                  onPageChanged: (index) {
                                                    controller.currentPage
                                                        .value = index;
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    final alert = controller
                                                        .alertsListNew[index];
                                                    return _alertCard(alert);
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Obx(() => Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: List.generate(
                                                      controller
                                                          .alertsListNew.length,
                                                      (index) => Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4),
                                                        width: controller
                                                                    .currentPage
                                                                    .value ==
                                                                index
                                                            ? 12
                                                            : 8,
                                                        height: controller
                                                                    .currentPage
                                                                    .value ==
                                                                index
                                                            ? 12
                                                            : 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: controller
                                                                      .currentPage
                                                                      .value ==
                                                                  index
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            InkWell(
                                onTap: () {
                                  Map<String, String> bodyParams = {
                                    ApiKeyConstants.lat: controller.lat.value,
                                    ApiKeyConstants.lon: controller.long.value,
                                    ApiKeyConstants.city: cityOne.value,
                                  };
                                  Get.toNamed(Routes.UP_COMMING_FORCAST_SCREEM,
                                      parameters: bodyParams);
                                },
                                child:
                                    _textSeeAll("Upcoming Forcast", "See All")),
                            controller.inAsyncCallForForecast.value
                                ? Shimmer.fromColors(
                                    baseColor:
                                        Color(0xFF3C3C98).withOpacity(.2.px),
                                    highlightColor:
                                        Colors.white.withOpacity(0.4),
                                    child: Container(
                                      height: 150.px,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.px),
                                      decoration: BoxDecoration(
                                        color: primary3Color,
                                        border: Border.all(
                                            width: 2.px, color: borderColor),
                                        borderRadius:
                                            BorderRadius.circular(24.px),
                                      ),
                                    ),
                                  )
                                : _upcomingForecast(),
                            SizedBox(height: 20),
                            InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.NOTAM_FOR_BACK,
                                      parameters: {
                                        ApiKeyConstants.lat:
                                            controller.lat.value,
                                        ApiKeyConstants.lon:
                                            controller.long.value,
                                        ApiKeyConstants.mobileType: "back"
                                      });
                                },
                                child: _textSeeAll("NOTAM Area", "View all")),
                            SizedBox(height: 20),
                            _notamArea(),
                            SizedBox(height: 40.px),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color getTemperatureColor(double temp) {
    if (temp <= 15) {
      return Colors.blue; // Cold
    } else if (temp >= 30) {
      return Colors.amber; // Hot
    } else {
      return Colors.white; // Normal
    }
  }

  Widget _weatherIcon(
    String icon,
    String label,
    String value,
    RxString temperatureUnit,
  ) {
    String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    double tempValue = double.tryParse(cleanValue) ?? 0;

    return controller.inAsyncCall.value
        ? Shimmer.fromColors(
            baseColor: Color(0xFF3C3C98).withOpacity(.2),
            highlightColor: Colors.white.withOpacity(0.4),
            child: Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                color: primary3Color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          )
        : Column(
            children: [
              AnimatedScale(
                scale: 1.2,
                duration: Duration(seconds: 2),
                child: CommonWidgets.appIconsSvg(
                  assetName: icon,
                  height: 30,
                  width: 30,
                ),
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              /// 🌡️ TEMPERATURE CASE (UPDATED)
              label == "Temperature"
                  ? Text(
                      temperatureUnit.value == "°F" ? '$value °F' : '$value °C',
                      style: TextStyle(
                        color: getTemperatureColor(tempValue), // 🔥 MAIN CHANGE
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )

                  /// PRESSURE
                  : label == "Pressure"
                      ? Text(
                          temperatureUnit.value == "inHg"
                              ? '$value inHg'
                              : '$value hPA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )

                      /// DEW
                      : label == "Dew"
                          ? Text(
                              temperatureUnit.value == "°F"
                                  ? '$cleanValue °F'
                                  : '$cleanValue °C',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )

                          /// FORECAST
                          : label == "Forecast"
                              ? Text(
                                  value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )

                              /// VISIBILITY
                              : label == "Visibility"
                                  ? Text(
                                      temperatureUnit.value == "KM"
                                          ? "$value KM"
                                          : temperatureUnit.value == "SM"
                                              ? "$value SM"
                                              : "$value ${temperatureUnit.value}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
            ],
          );
  }

  Widget _weatherRed(
    String icon,
    String label,
    String value,
    RxString temperatureUnit,
  ) {
    double windSpeed = 0;
    final isHighWind = windSpeed > 20;

    return controller.inAsyncCall.value
        ? Shimmer.fromColors(
            baseColor: const Color(0xFF3C3C98).withOpacity(.2),
            highlightColor: Colors.white.withOpacity(0.4),
            child: Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(
                color: primary3Color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          )
        : Column(
            children: [
              AnimatedScale(
                scale: 1.2,
                duration: const Duration(seconds: 2),
                child: CommonWidgets.appIconsSvg(
                  assetName: icon,
                  height: 30.px,
                  width: 30.px,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: primary3Color, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  final dir = controller.windDirection.value;
                  final dirPrefix = dir.isNotEmpty ? '$dir ' : '';
                  final displayVal = temperatureUnit.value == "Knots"
                      ? '$dirPrefix$value Knots'
                      : '$dirPrefix$value m/s';
                  return Text(
                    displayVal,
                    style: TextStyle(
                      color: isHighWind ? redG : primary3Color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
            ],
          );
  }

// Use this on your Home page
  Widget aqiSection() {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: controller.inAsyncCall.value
            ? const _AqiShimmerCard(key: ValueKey('aqi_shimmer'))
            : (controller.aqiUs.value == 0
                ? const SizedBox.shrink()
                : GestureDetector(
                    key: const ValueKey('aqi_card'),
                    onTap: () {
                      Get.toNamed(
                        Routes.AIR_QUILITY,
                        arguments: {
                          'aqi_us': controller.aqiUs.value,
                          'category': controller.aqiCategory.value,
                          'pm25': controller.aqiPm25.value,
                          'pm10': controller.weather?.airQuality?.pm10 ?? 0.0,
                          'city': cityOne.value,
                          'temperature': controller.temperature.value,
                          'humidity': controller.weather?.humidity ?? '',
                          'wind_speed': controller.windSpeed.value,
                          'wind_direction': controller.windDirection.value,
                          'condition': controller.weather?.condition ?? '',
                        },
                      );
                    },
                    child: _AqiCard(
                      aqi: controller.aqiUs.value,
                      category: controller.aqiCategory.value,
                      pm25: controller.aqiPm25.value,
                    ),
                  )),
      );
    });
  }

  Widget _alertCard(AlertsAirport alert) {
    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: liteAction,
        border: Border.all(width: 2, color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CommonWidgets.appIcons(
              assetName: IconConstants.icCyclone,
              height: 200,
              width: 128,
              borderRadius: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  alert.title ?? "Cyclone Alert",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  alert.description ?? "Cyclone Alert",
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),
                Text(
                  "Airport Icao Code :: ${alert.airport ?? "Cyclone Alert"} | \n | Source At :: ${alert.source ?? ""}",
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF3C3C98).withOpacity(.2),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: primary3Color,
          border: Border.all(width: 2, color: borderColor),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _upcomingForecast() {
    return Obx(() {
      if (controller.inAsyncCallForForecast.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.forecastList.isEmpty) {
        return const Center(child: Text("No forecast data"));
      }

      final forecasts = controller.forecastList.take(4).toList();

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: liteAction,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: const Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: forecasts.map((forecast) {
            String temp =
                "${forecast.temperature?.day?.toStringAsFixed(0) ?? "--"}${controller.temperatureUnit.value}";
            String wind =
                "${forecast.windSpeed ?? "--"} ${controller.windUnit.value}";

            return Column(
              children: [
                Text(
                  DateHelper.formatTimestampToDayDate(forecast.timestamp ?? 0),
                  style: TextStyle(
                    fontSize: 14.px,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.extractEmoji(forecast.condition ?? "Clear"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.px,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 10.0,
                        color: gradientPurple6.withOpacity(0.8),
                      ),
                    ],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  temp,
                  style: TextStyle(
                    fontSize: 16.px,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wind,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _textSeeAll(
    String title,
    String label,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30.px,
        ),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20.px,
                color: textColorLite)),
        Spacer(),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.px,
                color: primaryColor2)),
        SizedBox(
          width: 30.px,
        ),
      ],
    );
  }

  Color _critColor(String? c) {
    switch ((c ?? '').toLowerCase()) {
      case 'critical':
        return const Color(0xFFEA4658);
      case 'high':
        return const Color(0xFFEBC240);
      default:
        return const Color(0xff23F8A1);
    }
  }

  IconData _critIcon(String? c) {
    switch ((c ?? '').toLowerCase()) {
      case 'critical':
        return Icons.warning_rounded;
      case 'high':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _notamArea() {
    return Obx(() {
      controller.count.value;

      if (controller.inAsyncCall.value) {
        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.px),
            itemCount: 3,
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: const Color(0xFF3C3C98).withOpacity(0.45),
              highlightColor: Colors.white.withOpacity(0.25),
              child: Container(
                width: 220.px,
                margin: EdgeInsets.only(right: 12.px),
                decoration: BoxDecoration(
                  color: const Color(0xff2B2B6E),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      }

      final data = controller.getNotamData;
      if (data == null || data.isEmpty) {
        return Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            "No NOTAMs available",
            style: TextStyle(color: Colors.white38, fontSize: 13.px),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.px),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _notamCard(data[index], index);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _notamCard(Data item, int index) {
    final crit = item.criticality ?? 'low';
    final critColor = _critColor(crit);
    final location = item.location ?? '';
    final description = item.description ?? '';

    final preview = description.length > 80
        ? '${description.substring(0, 80)}...'
        : description;

    String timeLabel = '';
    if (item.startTime != null && item.startTime!.isNotEmpty) {
      try {
        final dt = DateTime.parse(item.startTime!).toLocal();
        timeLabel =
            "${_p(dt.day)}/${_p(dt.month)} ${_p(dt.hour)}${_p(dt.minute)}Z";
      } catch (_) {
        timeLabel = '';
      }
    }

    return GestureDetector(
      onTap: () {
        Map<String, String> params = {
          ApiKeyConstants.airportCode: location,
          ApiKeyConstants.warnings: crit,
        };
        Get.toNamed(Routes.N_O_T_A_M_S_DETAILS_SCREEN, parameters: params);
      },
      child: Container(
        width: 220.px,
        margin: EdgeInsets.only(right: 12.px),
        decoration: BoxDecoration(
          color: const Color(0xffAAA5A5).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: critColor.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: critColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.px, vertical: 10.px),
              decoration: BoxDecoration(
                color: critColor.withOpacity(0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.px, vertical: 4.px),
                    decoration: BoxDecoration(
                      color: critColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: critColor, width: 0.8),
                    ),
                    child: Text(
                      location.isEmpty ? '---' : location,
                      style: TextStyle(
                        color: critColor,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(4.px),
                    decoration: BoxDecoration(
                      color: critColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _critIcon(crit),
                      color: critColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.px),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: critColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: critColor.withOpacity(0.4), width: 0.8),
                      ),
                      child: Text(
                        crit.toUpperCase(),
                        style: TextStyle(
                          color: critColor,
                          fontSize: 9.px,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.px),
                    Expanded(
                      child: Text(
                        preview.isEmpty ? 'No description' : preview,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 10.5.px,
                          height: 1.5,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    SizedBox(height: 6.px),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (timeLabel.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  color: Colors.white38, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9.px,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          "Details →",
                          style: TextStyle(
                            color: primaryColor2,
                            fontSize: 10.px,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryColor2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _p(int v) => v.toString().padLeft(2, '0');
}

class Forecast {
  final String day;
  final String icon;
  final String temp;
  final String wind;

  Forecast({
    required this.day,
    required this.icon,
    required this.temp,
    required this.wind,
  });
}

class _AqiCard extends StatelessWidget {
  const _AqiCard({
    super.key,
    required this.aqi,
    required this.category,
    required this.pm25,
  });

  final int aqi;
  final String category;
  final double pm25;

  @override
  Widget build(BuildContext context) {
    // Keep your base color
    const Color aqiColor = primary3Color;

    final IconData moodIcon = switch (aqi) {
      <= 50 => Icons.sentiment_very_satisfied_rounded,
      <= 100 => Icons.sentiment_satisfied_rounded,
      <= 150 => Icons.sentiment_neutral_rounded,
      <= 200 => Icons.sentiment_dissatisfied_rounded,
      _ => Icons.sick_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: _GlassCard(
        borderColor: aqiColor.withOpacity(0.55),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                _AqiPill(value: aqi),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'US AQI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: [
                          Row(
                            children: [
                              _ChipLabel(
                                text: category,
                                color: aqiColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                'Updated just now',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: aqiColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: aqiColor.withOpacity(0.35), width: 1),
                  ),
                  child: Icon(moodIcon, color: Colors.white, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Gauge
            _AqiGauge(
              aqi: aqi,
              baseColor: aqiColor,
            ),

            const SizedBox(height: 10),

            // PM2.5 row
            Row(
              children: [
                Icon(Icons.blur_on_rounded,
                    size: 16, color: Colors.white.withOpacity(0.75)),
                const SizedBox(width: 6),
                Text(
                  'PM2.5',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${pm25.toStringAsFixed(1)} μg/m³',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap for details',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
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

class _AqiGauge extends StatelessWidget {
  const _AqiGauge({required this.aqi, required this.baseColor});

  final int aqi;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    // Clamp into 0..300 display range (you can change to 500)
    final clamped = aqi.clamp(0, 300);
    final progress = clamped / 300.0;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Air quality level',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$clamped/300',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: Colors.white.withOpacity(0.10),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                height: 10,
                width: MediaQuery.of(context).size.width * progress,
                // ok inside card
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      baseColor.withOpacity(0.35),
                      baseColor.withOpacity(0.90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AqiShimmerCard extends StatelessWidget {
  const _AqiShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF3C3C98).withOpacity(.2.px),
      highlightColor: Colors.white.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary3Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 70, color: primary3Color),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 140, color: primary3Color),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary3Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                  height: 10, width: double.infinity, color: primary3Color),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(height: 12, width: 170, color: primary3Color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AqiPill extends StatelessWidget {
  const _AqiPill({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary3Color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primary3Color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          height: 1,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.borderColor,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.transparent,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}
