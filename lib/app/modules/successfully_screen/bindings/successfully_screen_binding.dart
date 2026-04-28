import 'package:get/get.dart';

import '../controllers/successfully_screen_controller.dart';

class SuccessfullyScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuccessfullyScreenController>(
      () => SuccessfullyScreenController(),
    );
  }
}
