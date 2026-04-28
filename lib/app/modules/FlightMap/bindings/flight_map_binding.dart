import 'package:get/get.dart';

import '../controllers/flight_map_controller.dart';

class FlightMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlightController>(
      () => FlightController(),
    );
  }
}
