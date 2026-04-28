import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WeatherSettingsScreenController extends GetxController {
  var windUnit = "Knots".obs;
  var visibilityUnit = "KM".obs;
  var temperatureUnit = "°C".obs;
  var dewPointUnit = "°C".obs;
  var pressureUnit = "hPA".obs;

  RxBool isLoading = false.obs;

 //HomeController homeController = Get.find<HomeController>();

  /// Initialize settings from SharedPreferences
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  /// Load saved preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    windUnit.value = prefs.getString("windUnit") ?? "Knots";
    visibilityUnit.value = prefs.getString("visibilityUnit") ?? "KM";
    temperatureUnit.value = prefs.getString("temperatureUnit") ?? "°C";
    dewPointUnit.value = prefs.getString("dewPointUnit") ?? "°C";
    pressureUnit.value = prefs.getString("pressureUnit") ?? "hPA";
  }

  /// Save all settings
  Future<void> saveSettings() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("windUnit", windUnit.value);
    prefs.setString("visibilityUnit", visibilityUnit.value);
    prefs.setString("temperatureUnit", temperatureUnit.value);
    prefs.setString("dewPointUnit", dewPointUnit.value);
    prefs.setString("pressureUnit", pressureUnit.value);
    // await homeController.getCurrentLocation();
    isLoading.value = false;
  }

  /// Reset to defaults
  Future<void> resetSettings() async {
    windUnit.value = "Knots";
    visibilityUnit.value = "KM";
    temperatureUnit.value = "°C";
    dewPointUnit.value = "°C";
    pressureUnit.value = "hPA";
    await saveSettings();
  }

  /// Generic toggle function
  void toggleUnit(RxString variable, String value) {
    variable.value = value;
    saveSettings();
  }

  final count = 0.obs;



  void increment() => count.value++;
}
