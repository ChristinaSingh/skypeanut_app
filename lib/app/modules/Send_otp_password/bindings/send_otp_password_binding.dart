import 'package:get/get.dart';

import '../controllers/send_otp_password_controller.dart';

class SendOtpPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendOtpPasswordController>(
      () => SendOtpPasswordController(),
    );
  }
}
