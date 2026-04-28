import 'package:get/get.dart';

import '../controllers/packages_plans_creadit_screen_controller.dart';

class PackagesPlansCreaditScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackagesPlansCreaditScreenController>(
      () => PackagesPlansCreaditScreenController(),
    );
  }
}
