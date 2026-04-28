import 'package:get/get.dart';

import '../controllers/update_password_screen_controller.dart';

class UpdatePasswordScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdatePasswordScreenController>(
      () => UpdatePasswordScreenController(),
    );
  }
}
