import 'package:get/get.dart';

import '../controllers/loader_screen_controller.dart';

class LoaderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoaderScreenController>(
      () => LoaderScreenController(),
    );
  }
}
