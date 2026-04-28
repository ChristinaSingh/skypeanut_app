import 'package:get/get.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/constants/string_constants.dart';
import '../../../routes/app_pages.dart';

class LoaderScreenController extends GetxController {
  Map<String, String?> parameters = Get.parameters;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    String? from = parameters[ApiKeyConstants.from];
    Future.delayed(const Duration(milliseconds: 500), () {
      if (from == ApiKeyConstants.signup) {
        Map<String, String> bodyParams = {
          ApiKeyConstants.from: ApiKeyConstants.signup,
          ApiKeyConstants.email: parameters[ApiKeyConstants.email] ?? '',
        };
        Get.offAndToNamed(Routes.OTP_VERIFY_SCREEN, parameters: bodyParams);
      } else if (from == ApiKeyConstants.password) {
        Map<String, String> bodyParams = {
          ApiKeyConstants.from: parameters[ApiKeyConstants.password] ?? '',
          ApiKeyConstants.email: parameters[ApiKeyConstants.email] ?? '',
        };
        Get.offAndToNamed(Routes.OTP_VERIFY_SCREEN, parameters: bodyParams);
      }
      else if (from == StringConstants.login) {
        Get.offAndToNamed(Routes.NAV_BAR_SCREEN,);
      } else {
        Get.offAndToNamed(Routes.SUCCESSFULLY_SCREEN);
      }
    });
    //manageSession();
  }

  void manageSession() async {
    await Future.delayed(const Duration(seconds: 1));
  }



  void increment() => count.value++;
}
