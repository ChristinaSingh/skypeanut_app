import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_airport_near_by.dart';
import '../../../data/apis/api_models/get_notam_by_airport_code.dart';
import '../../../data/apis/api_models/get_profile_model.dart';

class NotamForBackController extends GetxController {
  var temperature = 24.obs;
  var windSpeed = 4.63.obs;
  var visibility = 56.obs;
  var pressure = 1013.obs;
  var forecast = 56.obs;
  var lat = ''.obs;
  var long = ''.obs;

  Map<String, String?> parameters = Get.parameters;

  var date = 'June 07'.obs;
  var city = 'Paris'.obs;
  var name = 'Johan Wick'.obs;

  RxBool showDetails = false.obs;
  RxBool showDetail2 = false.obs;
  RxBool showDetails3 = false.obs;

  List<Airports>? nearByAirportsList;

  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  void toggleDetails2() {
    showDetail2.value = !showDetail2.value;
  }

  void toggleDetails3() {
    showDetails3.value = !showDetails3.value;
  }

  List<Data>? getNotamData;

  final inAsyncCall = true.obs;

  GetProfileModel? getProfileModelData;
  String userId = '';

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    getCurrentLocation();
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    //getProfileApi();
  }

  Future<void> getCurrentLocation() async {
    // Explicit type for permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Permission Denied.....');
      getCurrentLocation();
    } else {
      print('Permission Granted.....');
      // Explicit type for currentPosition
      Position currentPosition = await Geolocator.getCurrentPosition();
      getNearbyByAirportApiCall(currentPosition.latitude.toString(),
          currentPosition.longitude.toString());
      lat.value = currentPosition.latitude.toString();
      long.value = currentPosition.longitude.toString();
    }
  }



  Future<void> getNotamBYAirportData(String airportCode) async {
    inAsyncCall.value = true;
    NotamModel? notamModel =
    await ApiMethods.getNotamBYAirport(bodyParams: airportCode);
    if (notamModel != null && notamModel.success == true) {
      getNotamData = notamModel.data;
      print("data is plans ${getNotamData?.first.description ?? ''}");
      increment();
    } else {
      CommonWidgets.showMyToastMessage("data is not fetched....");
    }
    inAsyncCall.value = false;
  }

  Future<void> getNearbyByAirportApiCall(String lat, String long) async {
    inAsyncCall.value = true;
    // Explicit type for bodyParameter
    Map<String, dynamic> bodyParameter = {
      ApiKeyConstants.lat: lat,
      ApiKeyConstants.lon: long,
    };
    print("bodyParameter $bodyParameter");

    // Explicit type for getWeatherAppModel
    NearbyAirportModel? nearbyAirportModel =
    await ApiMethods.getNearbyByAirport(bodyParams: bodyParameter);

    if (nearbyAirportModel != null && nearbyAirportModel.status != "0") {
      nearByAirportsList = nearbyAirportModel.airports ?? [];
      getNotamBYAirportData(
          "${nearByAirportsList?.first.icaoCode ?? ''},${nearByAirportsList?[1].icaoCode ?? ''},${nearByAirportsList?[2].icaoCode ?? ''}");

      increment();
    } else {
      inAsyncCall.value = false;
    }
  }

  void increment() => count.value++;
}
