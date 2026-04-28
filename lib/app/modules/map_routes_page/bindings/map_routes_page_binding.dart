import 'package:get/get.dart';

import '../controllers/map_routes_page_controller.dart';

class MapRoutesPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapRoutesPageController>(
      () => MapRoutesPageController(),
    );
  }
}
