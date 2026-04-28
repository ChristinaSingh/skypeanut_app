import 'package:get/get.dart';

import '../controllers/get_started_page_screen_controller.dart';

class GetStartedPageScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetStartedPageScreenController>(
      () => GetStartedPageScreenController(),
    );
  }
}
