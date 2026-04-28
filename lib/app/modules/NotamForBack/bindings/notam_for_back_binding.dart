import 'package:get/get.dart';

import '../controllers/notam_for_back_controller.dart';

class NotamForBackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotamForBackController>(
      () => NotamForBackController(),
    );
  }
}
