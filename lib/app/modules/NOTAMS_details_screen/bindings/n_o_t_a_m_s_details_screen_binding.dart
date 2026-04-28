import 'package:get/get.dart';

import '../controllers/n_o_t_a_m_s_details_screen_controller.dart';

class NOTAMSDetailsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NOTAMSDetailsScreenController>(
      () => NOTAMSDetailsScreenController(),
    );
  }
}
