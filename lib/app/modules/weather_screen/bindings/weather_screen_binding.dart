import 'package:get/get.dart';

import '../controllers/weather_screen_controller.dart';

class WeatherScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeatherScreenController>(
      () => WeatherScreenController(),
    );
  }
}
