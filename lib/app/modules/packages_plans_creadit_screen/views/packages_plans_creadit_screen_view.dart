import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/packages_plans_creadit_screen_controller.dart';

class PackagesPlansCreaditScreenView
    extends GetView<PackagesPlansCreaditScreenController> {
  const PackagesPlansCreaditScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gradientPurple3,
      appBar: AppBar(
        title: const Text(
          "Credit Packages",
          style: TextStyle(
            color: primary3Color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: gradientPurple1,
        surfaceTintColor: gradientPurple1,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(10),
          child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icBackRound,
              height: 31.px,
              width: 31.px),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientPurple1,
              gradientPurple1,
              gradientPurple1,
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5,
              gradientPurple6,
              gradientPurple7,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (controller.inAsyncCall.value) {
            // ✅ Shimmer placeholder when API is loading
            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: 3, // Show 3 shimmer cards while loading
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.4),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          gradientPurple6,
                          gradientPurple7,
                          gradientPurple5,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (controller.packageList.isEmpty) {
            return Center(child: CommonWidgets.dataNotFound());
          }

          // ✅ Actual data list when loaded
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.packageList.length,
            itemBuilder: (context, index) {
              final pkg = controller.packageList[index];
              final price = (pkg.priceCents! / 100).toStringAsFixed(2);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      gradientPurple6,
                      gradientPurple7,
                      gradientPurple5,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientPurple7.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.label ?? "",
                        style: const TextStyle(
                          color: primary3Color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${pkg.credits} Credits",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$$price",
                            style: const TextStyle(
                              color: primary3Color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              controller.clickOnNext(pkg.priceCents.toString() ?? "");
                            },
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    liteGreenColor,
                                    primaryColor,
                                    primaryColor2,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 24),
                                child: const Text(
                                  "Buy Now",
                                  style: TextStyle(
                                    color: gradientPurple1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
