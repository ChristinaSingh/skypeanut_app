import 'package:get/get.dart';

import '../../NotificationForNavBar/controllers/notification_for_nav_bar_controller.dart';
import '../../setting_screen/controllers/setting_screen_controller.dart';
import '../controllers/nav_bar_screen_controller.dart';

class NavBarScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavBarScreenController>(
      () => NavBarScreenController(),
    );
    Get.lazyPut<NotificationForNavBarController>(
      () => NotificationForNavBarController(),
    );
    Get.lazyPut<SettingScreenController>(
      () => SettingScreenController(),
    );
  }
}
