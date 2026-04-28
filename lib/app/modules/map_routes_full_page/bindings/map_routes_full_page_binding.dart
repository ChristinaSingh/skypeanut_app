import 'package:get/get.dart';

import '../controllers/map_routes_full_page_controller.dart';

class MapRoutesFullPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapRoutesFullPageController>(
      () => MapRoutesFullPageController(),
    );
  }
}
