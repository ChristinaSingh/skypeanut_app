import 'package:get/get.dart';

import '../controllers/weather_settings_screen_controller.dart';

class WeatherSettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherSettingsScreenController>(
      () => WeatherSettingsScreenController(),
    );
  }
}
