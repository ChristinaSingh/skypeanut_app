import 'package:get/get.dart';

import '../controllers/splash_lite_screen_controller.dart';

class SplashLiteScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashLiteScreenController>(
      () => SplashLiteScreenController(),
    );
  }
}
