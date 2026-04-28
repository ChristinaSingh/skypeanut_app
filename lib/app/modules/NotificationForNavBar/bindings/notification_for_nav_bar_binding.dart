import 'package:get/get.dart';

import '../controllers/notification_for_nav_bar_controller.dart';

class NotificationForNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationForNavBarController>(
      () => NotificationForNavBarController(),
    );
  }
}
