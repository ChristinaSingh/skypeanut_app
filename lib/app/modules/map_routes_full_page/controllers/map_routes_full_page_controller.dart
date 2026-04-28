import 'package:get/get.dart';

class MapRoutesFullPageController extends GetxController {
  var date = 'June 07'.obs;
  var city = 'New York'.obs;
  var name = 'Johan Wick'.obs;

  RxBool showDetails = false.obs;
  RxBool isLoading = true.obs;

  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  final count = 0.obs;




  void increment() => count.value++;
}
