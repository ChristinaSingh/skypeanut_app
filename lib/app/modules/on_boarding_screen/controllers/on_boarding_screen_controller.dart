import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnBoardingScreenController extends GetxController {
  final count = 0.obs;
  var isLeftActive = false.obs;

  void activateLeft() => isLeftActive.value = true;
  void deactivateLeft() => isLeftActive.value = false;

  final PageController pageController = PageController();
  int currentPage = 0;




  void increment() => count.value++;
}
