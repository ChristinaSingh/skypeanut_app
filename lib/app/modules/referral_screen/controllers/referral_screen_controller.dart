import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/get_Referral_Model.dart';
import '../../../data/apis/api_models/get_profile_model.dart';

class ReferralScreenController extends GetxController {
  ReferralModel? referralModel;

  final inAsyncCallForLoadReward = true.obs;
  final inAsyncCall = true.obs;
  String userId = '';
  RxString userName = ''.obs;

  String shareText =
      "Check out this awesome app! 🚀 Join and get 5 points: https://python.aitechnotech.in/skypeanut-api/skypeanut/register?referral_code=TUMLPP";

  GetProfileModel? getProfileModelData;

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    getProfileApi();
    getStatusReward();
  }



  // ─── Share Methods ──────────────────────────────────────────────────────────

  void shareViaFacebook() async {
    String fbUrl =
        "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareText)}";
    if (await canLaunchUrl(Uri.parse(fbUrl))) {
      await launchUrl(Uri.parse(fbUrl));
    } else {
      Get.snackbar("Error", "Could not share on Facebook");
    }
  }

  void shareApp() async {
    try {
      await Share.share(
        shareText,
        subject: 'Check this out!',
      );
    } catch (e) {
      Get.snackbar("Error", "Unable to share: $e");
    }
  }

  void shareViaTwitter() async {
    String twitterUrl =
        "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(shareText)}";
    if (await canLaunchUrl(Uri.parse(twitterUrl))) {
      await launchUrl(Uri.parse(twitterUrl));
    } else {
      Get.snackbar("Error", "Could not share on Twitter");
    }
  }

  void shareGeneral() {
    Share.share(shareText);
  }

  // ─── API Calls ──────────────────────────────────────────────────────────────

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
        userName.value = getProfileModel.fullName ?? '';
      }
    } catch (e) {
      print("Get Profile Data $e");
    } finally {
      inAsyncCall.value = false;
    }
  }

  Future<void> getStatusReward() async {
    inAsyncCallForLoadReward.value = true;
    Map<String, dynamic> bodyParameter = {
      ApiKeyConstants.userId: userId,
    };

    referralModel = await ApiMethods.referralApi(bodyParams: bodyParameter);

    if (referralModel != null && referralModel?.status == '1') {
      inAsyncCallForLoadReward.value = false;
    } else {
      print("No alerts found or error occurred ${referralModel?.status}");
      inAsyncCallForLoadReward.value = false;
    }
  }

  void increment() => count.value++;

  /// Navigate to Credits screen
  void goToCredits() {
    Get.toNamed(Routes.CREDITS_SCREEN);
  }
}