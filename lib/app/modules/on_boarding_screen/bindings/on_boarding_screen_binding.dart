import 'package:get/get.dart';

import '../controllers/on_boarding_screen_controller.dart';

class OnBoardingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardingScreenController>(
      () => OnBoardingScreenController(),
    );
  }
}
