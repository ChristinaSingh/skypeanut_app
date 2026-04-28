import 'package:get/get.dart';

import '../controllers/update_profile_screen_controller.dart';

class UpdateProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateProfileScreenController>(
      () => UpdateProfileScreenController(),
    );
  }
}
