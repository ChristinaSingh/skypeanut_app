import 'package:get/get.dart';

import '../controllers/credits_screen_controller.dart';

class CreditsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditsScreenController>(
      () => CreditsScreenController(),
    );
  }
}
