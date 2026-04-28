import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/image_pick_and_crop.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_profile_model.dart';
import '../../../routes/app_pages.dart';

class SettingForBackController extends GetxController {
  var date = 'June 07'.obs;
  var city = 'Paris'.obs;
  var name = 'Johan Wick'.obs;
  Map<String, String?> parameters = Get.parameters;
  final RxBool inAsyncCall = true.obs; // final RxBool is also valid

  String userId = '';
  GetProfileModel? getProfileModelData;
  final selectImage = Rxn<File>();
  final profileImage = ''.obs;

  RxBool showDetails = false.obs;

  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    print("test :::  ${parameters["fromScreen"] ?? "just for test"}");
    getProfileApi();
  }

  Future<void> pickImages() async {
    selectImage.value = await ImagePickerAndCropper.pickImage(
      color: Colors.deepPurple,
      // Crop toolbar & indicator
      textColor: Colors.white,
      // Dialog text color
      dialogBackgroundColor: Colors.black,
      // Dialog background
      wantCropper: true,
      context: Get.context!,
    );

    print("selected ${selectImage.value}");
    increment();
  }

  Future<void> getProfileApi() async {
    try {
      inAsyncCall.value = true;
      Map<String, dynamic> bodyParameter = {
        ApiKeyConstants.userId: userId,
      };
      GetProfileModel? getProfileModel =
          await ApiMethods.getProfile(bodyParams: bodyParameter);
      if (getProfileModel != null && getProfileModel.status == '1') {
        getProfileModelData = getProfileModel;
        profileImage.value = getProfileModel.profilePhotoUrl ?? '';
        increment();
      }
    } catch (e) {
      print("Get Profile Data $e");
    } finally {
      inAsyncCall.value = false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove user token
    Get.offNamedUntil(Routes.LOGIN_SCREEN, (route) => false);
    print("User logged out successfully.");
  }

  void increment() => count.value++;
}
