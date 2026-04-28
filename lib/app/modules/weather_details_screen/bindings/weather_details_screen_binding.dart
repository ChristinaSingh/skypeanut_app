import 'package:get/get.dart';

import '../controllers/weather_details_screen_controller.dart';

class WeatherDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherDetailsScreenController>(
      () => WeatherDetailsScreenController(),
    );
  }
}
