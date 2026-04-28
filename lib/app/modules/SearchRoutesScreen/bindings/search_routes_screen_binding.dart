import 'package:get/get.dart';

import '../controllers/search_routes_screen_controller.dart';

class SearchRoutesScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchRoutesScreenController>(
      () => SearchRoutesScreenController(),
    );
  }
}
