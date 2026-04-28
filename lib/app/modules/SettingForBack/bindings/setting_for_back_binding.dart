import 'package:get/get.dart';

import '../controllers/setting_for_back_controller.dart';

class SettingForBackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingForBackController>(
      () => SettingForBackController(),
    );
  }
}
