import 'package:get/get.dart';

import '../controllers/ai_chat_screen_controller.dart';

class AiChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiChatScreenController>(
      () => AiChatScreenController(),
    );
  }
}
