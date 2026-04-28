import 'package:get/get.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_privacy_model.dart';

class PrivacyPolicyScreenController extends GetxController {
  // ─── Observables ─────────────────────────────────────────────────────────
  final count = 0.obs;
  final inAsyncCall = true.obs;

  // ─── Data ────────────────────────────────────────────────────────────────
  PrivacyModel? privacyModelData;

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    getPrivacyPolicyApiData();
  }

  void increment() => count.value++;

  // ─── API ─────────────────────────────────────────────────────────────────
  Future<void> getPrivacyPolicyApiData() async {
    inAsyncCall.value = true;
    try {
      final model = await ApiMethods.privacyPolicyApi();
      if (model != null && model.status == '1') {
        privacyModelData = model;
        increment();
      } else {
        CommonWidgets.showMyToastMessage("Failed to load Privacy Policy.");
      }
    } catch (e) {
      CommonWidgets.showMyToastMessage("Something went wrong.");
    } finally {
      inAsyncCall.value = false;
    }
  }
}