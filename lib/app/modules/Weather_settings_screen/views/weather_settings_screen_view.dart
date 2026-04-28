import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/weather_settings_screen_controller.dart';

class WeatherSettingsScreenView
    extends GetView<WeatherSettingsScreenController> {
  const WeatherSettingsScreenView({super.key});

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientPurple1,
                gradientPurple3,
                gradientPurple6,
                gradientPurple7,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      SizedBox(width: 10,),
                      const Text(
                        "Weather Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // WIND
                  _buildToggleRow(
                    title: "Wind",
                    options: const ["Knots", "m/s"],
                    selected: controller.windUnit,
                    onSelect: (val) => controller.toggleUnit(controller.windUnit, val),
                  ),

                  _buildToggleRow(
                    title: "Visibility",
                    options: const ["KM", "SM", "NM"],
                    selected: controller.visibilityUnit,
                    onSelect: (val) => controller.toggleUnit(controller.visibilityUnit, val),
                  ),

                  _buildToggleRow(
                    title: "Temperature",
                    options: const ["°C", "°F"],
                    selected: controller.temperatureUnit,
                    onSelect: (val) => controller.toggleUnit(controller.temperatureUnit, val),
                  ),

                  _buildToggleRow(
                    title: "Dew Point",
                    options: const ["°C", "°F"],
                    selected: controller.dewPointUnit,
                    onSelect: (val) => controller.toggleUnit(controller.dewPointUnit, val),
                  ),

                  _buildToggleRow(
                    title: "Pressure",
                    options: const ["hPA", "inHg"],
                    selected: controller.pressureUnit,
                    onSelect: (val) => controller.toggleUnit(controller.pressureUnit, val),
                  ),


                  const Spacer(),

                  Center(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                        controller.isLoading.value = true;

                        // Simulate saving delay (replace with your actual logic)
                        await Future.delayed(const Duration(seconds: 2));

                        Get.snackbar(
                          "Settings Saved",
                          "Your preferences have been updated.",
                          colorText: Colors.white,
                          backgroundColor: Colors.black54,
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        controller.isLoading.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ),


                  const SizedBox(height: 12),

                  // 🔄 Reset Button
                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.resetSettings();
                        Get.snackbar(
                          "Settings Reset",
                          "All settings have been restored to default.",
                          colorText: Colors.white,
                          backgroundColor: Colors.black54,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reset Settings",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔘 Helper widget for toggle rows
  /// 🔘 Reusable Toggle Section
  Widget _buildToggleRow({
    required String title,
    required List<String> options,
    required RxString selected,
    required Function(String) onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Row(
            children: options.map((opt) {
              final isSelected = selected.value == opt;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
