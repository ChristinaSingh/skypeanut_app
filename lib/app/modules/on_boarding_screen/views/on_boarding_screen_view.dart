import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/modules/on_boarding_screen/controllers/on_boarding_screen_controller.dart';
import 'package:skypeanut/app/routes/app_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../common/responsive_size.dart';
import '../../../common/text_styles.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../data/constants/image_constants.dart';
import '../../../data/constants/string_constants.dart';

class OnBoardingScreenView extends GetView<OnBoardingScreenController> {
  const OnBoardingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: PageView(
            controller: controller.pageController,
            onPageChanged: (index) {
              controller.currentPage = index;
              controller.increment();
            },
            children: [
              buildPage(
                  indexInt: controller.currentPage,
                  title: "Perfect AI tool",
                  description: "for all weather information online and offline",
                  image: ImageConstants.imgOnboard1,
                  context: context),
              buildPage(
                indexInt: controller.currentPage,
                title: "Real-time flight tracking",
                description:
                    "Real-time flight tracking with live weather updates, ensuring you stay informed about your journey",
                image: ImageConstants.imgOnboard2,
                context: context,
              ),
              buildPage2(
                indexInt: controller.currentPage,
                title: "Explore Global Flight Routes, Weather & NOTAM Updates",
                description:
                    "Plan your flights more efficiently with real-time aviation insights. Instantly check global flight routes, weather conditions, and NOTAM updates in seconds for safer and smarter journey planning.",
                image: ImageConstants.imgOnboard3,
                context: context,
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widget buildPage(
  //     {required String title,
  //     required String description,
  //     required String image,
  //     required int indexInt,
  //     required BuildContext context}) {
  //   return Stack(
  //     children: [
  //       CommonWidgets.appIcons(
  //           height: MediaQuery.sizeOf(context).height,
  //           width: MediaQuery.sizeOf(context).width,
  //           fit: BoxFit.cover,
  //           assetName: image),
  //       Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           margin: EdgeInsets.only(bottom: 60.px),
  //           height: MediaQuery.sizeOf(context).height / 2.7,
  //           width: MediaQuery.sizeOf(context).width - 48,
  //           padding: EdgeInsets.all(15.px),
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(18.px),
  //               color: darkModeBlack),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(height: ResponsiveSize.height(context, 20.px)),
  //               Text(
  //                 title,
  //                 textAlign: TextAlign.start,
  //                 style: TextStyle(
  //                   fontSize: indexInt == 2 ? 20.px : 24.px,
  //                   fontWeight: FontWeight.w600,
  //                   color: textColorLite,
  //                 ),
  //               ),
  //               SizedBox(height: 12),
  //               Text(
  //                 description,
  //                 maxLines: 2,
  //                 softWrap: true,
  //                 textAlign: TextAlign.start,
  //                 style: TextStyle(
  //                   fontSize: 14.px,
  //                   fontWeight: FontWeight.w400,
  //                   color: textColorLite,
  //                 ),
  //               ),
  //               indexInt == 2
  //                   ? SizedBox()
  //                   : SizedBox(height: ResponsiveSize.height(context, 40.px)),
  //               indexInt == 2
  //                   ? SizedBox()
  //                   : SmoothPageIndicator(
  //                       controller: controller.pageController,
  //                       count: 3,
  //                       effect: ExpandingDotsEffect(
  //                         dotHeight: 8,
  //                         dotWidth: 8,
  //                         activeDotColor: primaryColor2,
  //                         dotColor: Colors.grey.shade400,
  //                       ),
  //                     ),
  //               SizedBox(height: ResponsiveSize.height(context, 40.px)),
  //               CommonWidgets.commonElevatedButton(
  //                 height: 55.px,
  //                 borderRadius: 17.px,
  //                 buttonColor: primaryColor2,
  //                 onPressed: () {},
  //                 child: Text(
  //                   StringConstants.continueText,
  //                   style: MyTextStyle.titleStyle18bw,
  //                 ),
  //               ),
  //               SizedBox(height: ResponsiveSize.height(context, 20.px)),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget buildPage({
    required int indexInt,
    required String title,
    required String description,
    required String image,
    required BuildContext context,
  }) {
    return AnimatedBuilder(
      animation: controller.pageController,
      builder: (context, child) {
        double pageOffset = 0.0;
        try {
          pageOffset = controller.pageController.page ??
              controller.pageController.initialPage.toDouble();
        } catch (_) {}

        double opacity = (1 - (indexInt - pageOffset).abs()).clamp(0.0, 1.0);
        double offsetY = (1 - opacity) * 50; // Slide a little up/down

        return Stack(
          children: [
            CommonWidgets.appIcons(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                fit: BoxFit.cover,
                assetName: image),
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 100.px),
                    height: MediaQuery.sizeOf(context).height / 2.9,
                    width: MediaQuery.sizeOf(context).width - 48,
                    padding: EdgeInsets.all(15.px),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.px),
                        color: darkModeBlack),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveSize.height(context, 20.px)),
                        Text(
                          title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: indexInt == 2 ? 20.px : 20.px,
                            fontWeight: FontWeight.w600,
                            color: textColorLite,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          description,
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.px,
                            fontWeight: FontWeight.w400,
                            color: textColorLite,
                          ),
                        ),
                        indexInt == 2
                            ? SizedBox()
                            : SizedBox(
                                height: ResponsiveSize.height(context, 30.px)),
                        indexInt == 2
                            ? SizedBox()
                            : SmoothPageIndicator(
                                controller: controller.pageController,
                                count: 3,
                                effect: ExpandingDotsEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: primaryColor2,
                                  dotColor: Colors.grey.shade400,
                                ),
                              ),
                        SizedBox(height: ResponsiveSize.height(context, 40.px)),
                        CommonWidgets.commonElevatedButton(
                          height: 55.px,
                          borderRadius: 17.px,
                          buttonColor: primaryColor2,
                          onPressed: () {
                            controller.pageController.nextPage(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            StringConstants.continueText,
                            style: MyTextStyle.titleStyle18bw,
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.height(context, 20.px)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPage2(
      {required String title,
      required String description,
      required String image,
      required int indexInt,
      required BuildContext context}) {
    return AnimatedBuilder(
      animation: controller.pageController,
      builder: (context, child) {
        double pageOffset = 0.0;
        try {
          pageOffset = controller.pageController.page ??
              controller.pageController.initialPage.toDouble();
        } catch (_) {}

        double opacity = (1 - (indexInt - pageOffset).abs()).clamp(0.0, 1.0);
        double offsetY = (1 - opacity) * 50; // Slide a little up/down

        return Stack(
          children: [
            CommonWidgets.appIcons(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                fit: BoxFit.cover,
                assetName: image),
            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 60.px),
                    height: MediaQuery.sizeOf(context).height / 3,
                    width: MediaQuery.sizeOf(context).width - 48,
                    padding: EdgeInsets.all(15.px),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.px),
                        color: darkModeBlack),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveSize.height(context, 20.px)),
                        Text(
                          title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18.px,
                            fontWeight: FontWeight.w600,
                            color: textColorLite,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          description,
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.px,
                            fontWeight: FontWeight.w400,
                            color: textColorLite,
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.height(context, 40.px)),
                        CommonWidgets.commonElevatedButton(
                          height: 55.px,
                          borderRadius: 17.px,
                          buttonColor: primaryColor2,
                          onPressed: () {
                            Get.offAllNamed(Routes.LOGIN_SCREEN);
                          },
                          child: Text(
                            StringConstants.continueText,
                            style: MyTextStyle.titleStyle18bw,
                          ),
                        ),
                        SizedBox(height: ResponsiveSize.height(context, 20.px)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    //   Stack(
    //   children: [
    //     CommonWidgets.appIcons(
    //         height: MediaQuery.sizeOf(context).height,
    //         width: MediaQuery.sizeOf(context).width,
    //         fit: BoxFit.cover,
    //         assetName: image),
    //     Align(
    //       alignment: Alignment.bottomCenter,
    //       child: Container(
    //         margin: EdgeInsets.only(bottom: 60.px),
    //         height: MediaQuery.sizeOf(context).height / 2.7,
    //         width: MediaQuery.sizeOf(context).width - 48,
    //         padding: EdgeInsets.all(15.px),
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(18.px),
    //             color: darkModeBlack),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             SizedBox(height: ResponsiveSize.height(context, 20.px)),
    //             Text(
    //               title,
    //               textAlign: TextAlign.start,
    //               style: TextStyle(
    //                 fontSize: 20.px,
    //                 fontWeight: FontWeight.w600,
    //                 color: textColorLite,
    //               ),
    //             ),
    //             SizedBox(height: 12),
    //             Text(
    //               description,
    //               maxLines: 2,
    //               softWrap: true,
    //               textAlign: TextAlign.start,
    //               style: TextStyle(
    //                 fontSize: 14.px,
    //                 fontWeight: FontWeight.w400,
    //                 color: textColorLite,
    //               ),
    //             ),
    //             SizedBox(height: ResponsiveSize.height(context, 40.px)),
    //             CommonWidgets.commonElevatedButton(
    //               height: 55.px,
    //               borderRadius: 17.px,
    //               buttonColor: primaryColor2,
    //               onPressed: () {},
    //               child: Text(
    //                 StringConstants.continueText,
    //                 style: MyTextStyle.titleStyle18bw,
    //               ),
    //             ),
    //             SizedBox(height: ResponsiveSize.height(context, 20.px)),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget buildPage3(
      {required String title,
      required String description,
      required String image,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          IconConstants.icSplashLogoDark,
          height: ResponsiveSize.height(context, 245.px),
          width: ResponsiveSize.width(context, 245.px),
          fit: BoxFit.cover,
        ),
        SvgPicture.asset(image,
            height: ResponsiveSize.height(context, 222.px),
            width: ResponsiveSize.width(context, 370.px)),
        SizedBox(height: ResponsiveSize.height(context, 45.px)),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: primaryColor2,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60),
          child: Text(
            description,
            maxLines: 2,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: primaryColor2,
            ),
          ),
        ),
      ],
    );
  }
}
