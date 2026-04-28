import 'package:get/get.dart';

import '../controllers/notams_screen_controller.dart';

class NotamsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotamsScreenController>(
      () => NotamsScreenController(),
    );
  }
}
