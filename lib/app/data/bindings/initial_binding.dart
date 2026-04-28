import 'package:get/get.dart';
import '../services/connectivity_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
  }
}
