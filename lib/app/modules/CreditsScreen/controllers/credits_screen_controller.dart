import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/routes/app_pages.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import '../../../data/apis/api_models/CreatePaymentModel.dart';
import '../../../data/apis/api_models/get_Referral_Model.dart';
import '../../../data/apis/api_models/get_profile_model.dart';

class CreditsScreenController extends GetxController {
  Map<String, dynamic>? paymentIntent;

  ReferralModel? referralModel;
  final showLoading = false.obs;
  final inAsyncCallForLoadReward = true.obs;
  final inAsyncCall = true.obs;
  String userId = '';
  RxString userName = ''.obs;

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
      print("No data found or error occurred ${referralModel?.status}");
      inAsyncCallForLoadReward.value = false;
    }
  }

  void increment() => count.value++;

  void clickOnNext() async {
    Get.toNamed(Routes.PACKAGES_PLANS_CREADIT_SCREEN)?.then((_) async {
      getProfileApi();
      getStatusReward();
    });
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey =
          "";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body.toString());
    } catch (err) {
      showLoading.value = false;
      print('Error charging user: ${err.toString()}');
    }
  }

  getPaymentIntentDetails(String paymentIntentId) async {
    try {
      var secretKey =
          "";
      var response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $secretKey',
        },
      );

      var paymentIntentDetails = jsonDecode(response.body);
      if (paymentIntentDetails != null && paymentIntentDetails['id'] != null) {
        String paymentId = paymentIntentDetails['id'];
        String amount =
            ((paymentIntentDetails['amount_received'] ?? 0) / 100).toString();
        String currency =
            (paymentIntentDetails['currency'] ?? 'USD').toUpperCase();
        String status = paymentIntentDetails['status'] ?? '';
        String created = (paymentIntentDetails['created'] ?? 0).toString();
        String paymentMethod = paymentIntentDetails['payment_method'] ?? '';
        String receiptUrl = "";

        if (paymentIntentDetails['charges'] != null &&
            paymentIntentDetails['charges']['data'] != null &&
            paymentIntentDetails['charges']['data'].isNotEmpty) {
          var charge = paymentIntentDetails['charges']['data'][0];
          receiptUrl = charge['receipt_url'] ?? '';
        }

        await createPaymentApiCalling(
          amount,
          paymentId,
          currency,
          status,
          created,
          receiptUrl,
          'shop now',
          paymentMethod,
          paymentIntentDetails['customer'] ?? '',
          paymentIntentDetails['subscription'] ?? '',
        );
      }
    } catch (e) {
      print('Error retrieving payment intent details: $e');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      await getPaymentIntentDetails(paymentIntent!['id']);
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
    } catch (e) {
      showLoading.value = false;
      print('$e');
    }
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'AUD');
      if (paymentIntent == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              testEnv: true, currencyCode: "AUD", merchantCountryCode: "AU"),
          merchantDisplayName: 'Flutterwings',
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      showLoading.value = false;
      if (e is StripeConfigException) {
        print("Stripe exception ${e.message}");
      } else {
        print("exception $e");
      }
    }
  }

  createPaymentApiCalling(
    String amount,
    String paymentId,
    String currency,
    String status,
    String created,
    String receiptUrl,
    String subscriptionType,
    String paymentMethod,
    String stripeCustomerId,
    String subscriptionId,
  ) async {
    showLoading.value = true;

    if (await CommonWidgets.internetConnectionCheckerMethod()) {
      Map<String, String> bodyParams = {
        ApiKeyConstants.userId: userId,
        ApiKeyConstants.paymentIntentId: paymentId,
        ApiKeyConstants.amount: amount,
        ApiKeyConstants.currency: currency,
        ApiKeyConstants.status: status,
        ApiKeyConstants.created: created,
        ApiKeyConstants.receiptUrl: receiptUrl,
        ApiKeyConstants.subscriptionType: subscriptionType,
        ApiKeyConstants.paymentMethod: paymentMethod,
        ApiKeyConstants.stripeCustomerId: stripeCustomerId,
        ApiKeyConstants.subscriptionId: subscriptionId,
      };

      try {
        PaymentsCreateModel? paymentsCreateModel =
            await ApiMethods.paymentCreate(bodyParams: bodyParams);

        if (paymentsCreateModel != null && paymentsCreateModel.status != "0") {
          increment();
        } else {
          CommonWidgets.showMyToastMessage(paymentsCreateModel?.message ?? '');
        }
      } catch (e) {
        CommonWidgets.showMyToastMessage(
            'Enter unique ConfirmPass and phone number...');
      }
    } else {
      CommonWidgets.snackBarView(
          title: 'Please Check Your Internet Connection', success: false);
    }

    showLoading.value = false;
  }
}
