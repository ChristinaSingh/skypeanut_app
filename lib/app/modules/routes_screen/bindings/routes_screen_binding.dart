import 'package:get/get.dart';

import '../../../common/app_theme_controller.dart';
import '../../FlightMap/controllers/flight_map_controller.dart';
import '../controllers/routes_screen_controller.dart';

class RoutesScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlightStatusScreenController>(
      () => FlightStatusScreenController(),
    );
    Get.lazyPut<FlightController>(
      () => FlightController(),
    );
    Get.lazyPut<AppThemeController>(
      () => AppThemeController(),
    );
  }
}
