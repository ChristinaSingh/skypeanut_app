import 'package:get/get.dart';

import '../controllers/up_comming_forcast_screem_controller.dart';

class UpCommingForcastScreemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpCommingForcastScreemController>(
      () => UpCommingForcastScreemController(),
    );
  }
}
