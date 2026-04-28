import 'package:get/get.dart';

import '../controllers/air_quility_controller.dart';

class AirQuilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AirQuilityController>(
      () => AirQuilityController(),
    );
  }
}
