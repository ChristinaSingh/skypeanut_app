import 'package:get/get.dart';

import '../controllers/agreement_screen_controller.dart';

class AgreementScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgreementScreenController>(
      () => AgreementScreenController(),
    );
  }
}
