import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:skypeanut/app/data/apis/api_models/plan_pakage_model.dart';

import '../../../common/common_widgets.dart';
import '../../../data/apis/api_methods/api_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_models/CreatePaymentModel.dart';

class PackagesPlansCreaditScreenController extends GetxController {
  final packages = <String, dynamic>{}.obs;
  final inAsyncCall = true.obs;

  Map<String, dynamic>? paymentIntent;
  final showLoading = false.obs;
  String userId = '';

  RxList<Starter10> packageList = <Starter10>[].obs;

  List<Packages>? getNotamData;

  final count = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString(ApiKeyConstants.userId) ?? '';
    loadPackagesApi();
  }

  void loadPackages() {
    // Simulating API or local data
    packages.value = {
      "starter_10": {
        "credits": 10,
        "price_cents": 500,
        "label": "10 credits for \$5"
      },
      "monthly_50": {
        "credits": 50,
        "price_cents": 2000,
        "label": "50 credits for \$20"
      },
      "bulk_100": {
        "credits": 100,
        "price_cents": 3500,
        "label": "100 credits for \$35"
      }
    };
  }

  void buyPackage(String packageKey) {
    Get.snackbar(
      "Purchase",
      "You bought $packageKey",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xff2AB1FB).withOpacity(0.8),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  Future<void> loadPackagesApi() async {
    try {
      inAsyncCall.value = true;

      PlanPackagesModel? planPackagesModel =
          await ApiMethods.getPlanPackagesApi();

      if (planPackagesModel != null && planPackagesModel.status == "1") {
        final packages = planPackagesModel.packages;
        if (packages != null) {
          // ✅ Convert all available packages into a list
          packageList.clear();

          if (packages.starter10 != null) {
            packageList.add(packages.starter10!);
          }
          if (packages.monthly50 != null) {
            packageList.add(packages.monthly50!);
          }
          if (packages.bulk100 != null) {
            packageList.add(packages.bulk100!);
          }

          inAsyncCall.value = false;

          print("✅ Loaded ${packageList.length} packages");
          print("First label: ${packageList.first.label}");
        } else {
          inAsyncCall.value = false;
          CommonWidgets.showMyToastMessage("No packages found");
        }
      } else {
        inAsyncCall.value = false;
        CommonWidgets.showMyToastMessage("Data not fetched...");
      }
    } catch (e) {
      CommonWidgets.showMyToastMessage("Error: $e");
    } finally {
      inAsyncCall.value = false;
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
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
      print('Payment Intent Body: ${response.body.toString()}');
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
        String created =
            (paymentIntentDetails['created'] ?? 0).toString(); // epoch
        String paymentMethod = paymentIntentDetails['payment_method'] ?? '';
        String receiptUrl = ""; // fallback if not found

        // Get receipt_url from the `charges` object (nested)
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
          // subscriptionType if you have
          paymentMethod,
          paymentIntentDetails['customer'] ?? '',
          // stripeCustomerId
          paymentIntentDetails['subscription'] ?? '', // subscriptionId
        );
      }

      print('payment_intents: $paymentIntentDetails');
    } catch (e) {
      print('Error retrieving payment intent details: $e');
    }
  }

  displayPaymentSheet() async {
    try {
      // "Display payment sheet";
      await Stripe.instance.presentPaymentSheet();
      // Show when payment is done
      // Displaying snackbar for it
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      print("payment datails::::$paymentIntent");

      await getPaymentIntentDetails(paymentIntent!['id']);

      paymentIntent = null;
    } on StripeException catch (e) {
      // If any error comes during payment
      // so payment will be cancelled
      print('Error: $e');

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
    } catch (e) {
      showLoading.value = false;
      print("Error in displaying");
      print('$e');
    }
  }

  void clickOnNext(String priceCents) async {
    //Get.toNamed(Routes.PACKAGES_PLANS_CREADIT_SCREEN);
    await makePayment(priceCents);
  }

  Future<void> makePayment(String priceCents) async {
    try {
      // Create payment intent data
      paymentIntent = await createPaymentIntent(priceCents, 'USD');
      if (paymentIntent == null) return;
      // initialise the payment sheet setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Client secret key from payment data
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              // Currency and country code is accourding to India
              testEnv: true,
              currencyCode: "USD",
              merchantCountryCode: "US"),
          // Merchant Name
          merchantDisplayName: 'Flutterwings',
          // return URl if you want to add
          // returnURL: 'flutterstripe://redirect',
        ),
      );
      // Display payment sheet
      displayPaymentSheet();
    } catch (e) {
      showLoading.value = false;
      print("exception $e");

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

      print("Check data :-- $bodyParams");

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

  void increment() => count.value++;
}
