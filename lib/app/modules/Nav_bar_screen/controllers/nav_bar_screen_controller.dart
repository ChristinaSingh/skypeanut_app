import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skypeanut/app/modules/home/views/home_view.dart';
import 'package:skypeanut/app/modules/notams_screen/views/notams_screen_view.dart';
import 'package:skypeanut/app/modules/routes_screen/views/routes_screen_view.dart';
import 'package:skypeanut/app/modules/setting_screen/views/setting_screen_view.dart';
import 'package:skypeanut/app/modules/weather_screen/views/weather_screen_view.dart';

import '../../../common/common_widgets.dart';
import '../../../data/constants/string_constants.dart';
import '../../NotificationForNavBar/views/notification_for_nav_bar_view.dart';


final selectedIndex = 0.obs;
Rx<String> cityOne = "Paris".obs;
Rx<String> userName = "Dear user".obs;

class NavBarScreenController extends GetxController {

  final count = 0.obs;


  onWillPopMethod({required BuildContext context}) {
    if (selectedIndex.value == 0) {
      CommonWidgets.showAlertDialog(
        title: StringConstants.location,
        content: StringConstants.wantedList,
        onPressedYes: () => SystemNavigator.pop(),
      );
    } else {
      selectedIndex.value = 0;
    }
  }

  clickOnTab({required int index}) {
    selectedIndex.value = index;
   increment();
  }



  body() {
    switch (selectedIndex.value) {
      case 0:
        return const HomeView();
      case 1:
        return const WeatherScreenView();
      case 2:
        return const NotamsScreenView();
      case 3:
        return const FlightStatusScreenView();
      case 4:
        return const NotificationForNavBarView();
      case 5:
        return const SettingScreenView();
    }
  }




  void increment() => count.value++;
}
