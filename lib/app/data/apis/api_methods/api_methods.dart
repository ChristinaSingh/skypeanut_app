import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/get_details_notams.dart';
import 'package:skypeanut/app/data/apis/api_models/get_forgot_model.dart';
import 'package:skypeanut/app/data/apis/api_models/get_notam_by_airport_code.dart';
import 'package:skypeanut/app/data/apis/api_models/get_verify_otp.dart';
import 'package:skypeanut/app/data/apis/api_models/get_weather_model.dart';
import 'package:skypeanut/app/data/apis/api_models/password_update_model.dart';
import 'package:skypeanut/app/data/apis/api_models/plan_schema_model.dart';
import 'package:skypeanut/app/data/apis/api_models/support_model.dart';
import 'package:skypeanut/app/data/apis/api_models/update_profile_model.dart';
import '../../../common/http_methods.dart';
import '../api_constants/api_key_constants.dart';
import '../api_constants/api_url_constants.dart';
import '../api_models/CreatePaymentModel.dart';
import '../api_models/city_weather_model.dart';
import '../api_models/get_Referral_Model.dart';
import '../api_models/get_airport_near_by.dart';
import '../api_models/get_airport_nearest.dart';
import '../api_models/get_alerts_model.dart';
import '../api_models/get_find_routes_model.dart';
import '../api_models/get_log_in_model.dart';
import '../api_models/get_privacy_model.dart';
import '../api_models/get_profile_model.dart';
import '../api_models/get_routes_model.dart';
import '../api_models/get_sign_up_model.dart';
import '../api_models/get_upcomming_weather_hourly.dart';
import '../api_models/get_weekly_upcomming_forecast_model.dart';
import '../api_models/nearby_weather_model.dart';
import '../api_models/plan_pakage_model.dart';
import '../api_models/verify_forgot_model.dart';

class ApiMethods {
  /// Send Otp For Login...
  static Future<SignupModel?> register({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    SignupModel? simpleResponseModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfUserSignup,
      checkResponse: checkResponse,
    );
    if (response != null) {
      simpleResponseModel = SignupModel.fromJson(jsonDecode(response.body));
      return simpleResponseModel;
    }
    return null;
  }

  static Future<VerifyModel?> otpVerify({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    VerifyModel? verifyModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfOtpVerify,
      checkResponse: checkResponse,
    );
    if (response != null) {
      verifyModel = VerifyModel.fromJson(jsonDecode(response.body));
      return verifyModel;
    }
    return null;
  }

  static Future<VerifyModel?> resendOtp({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    VerifyModel? verifyModel;
    http.Response? response = await MyHttp.postJsonRawMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfOtpVerify,
      checkResponse: checkResponse,
    );
    if (response != null) {
      verifyModel = VerifyModel.fromJson(jsonDecode(response.body));
      return verifyModel;
    }
    return null;
  }

  /// Send Otp For Login...
  static Future<LoginModel?> login({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    LoginModel? loginModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfLogin,
      checkResponse: checkResponse,
    );
    if (response != null) {
      loginModel = LoginModel.fromJson(jsonDecode(response.body));
      return loginModel;
    }
    return null;
  }

  static Future<GetWeatherAppModel?> getWeatherApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    GetWeatherAppModel getWeatherAppModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfWeather,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      getWeatherAppModel =
          GetWeatherAppModel.fromJson(jsonDecode(response.body));
      return getWeatherAppModel;
    }
    return null;
  }

  static Future<NearbyWeatherModel?> getNearbyWeatherApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    NearbyWeatherModel nearbyWeatherModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfNearbyWeather,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      nearbyWeatherModel =
          NearbyWeatherModel.fromJson(jsonDecode(response.body));
      return nearbyWeatherModel;
    }
    return null;
  }

  static Future<CityWeatherModel?> getCityWeatherApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    CityWeatherModel cityWeatherModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfWeatherCityDetails,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      cityWeatherModel = CityWeatherModel.fromJson(jsonDecode(response.body));
      return cityWeatherModel;
    }
    return null;
  }

  static Future<NotamModel?> getNotamBYAirport(
      {void Function(int)? checkResponse, required String bodyParams}) async {
    NotamModel notamModel;
    http.Response? response = await MyHttp.getMethod(
      url: "${ApiUrlConstants.endPointOfNotamByAirport}/$bodyParams",
      checkResponse: checkResponse,
    );
    if (response != null) {
      notamModel = NotamModel.fromJson(jsonDecode(response.body));
      return notamModel;
    }
    return null;
  }

  static Future<NearestAirportModel?> getNearestByAirport({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    NearestAirportModel notamModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfAirportNearestCityDetails,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      notamModel = NearestAirportModel.fromJson(jsonDecode(response.body));
      return notamModel;
    }
    return null;
  }


  // ── In your ApiMethods class ─────────────────────────────────────────────────

  /// DELETE /delete-account
  /// Body: user_id, password  (x-www-form-urlencoded)
  static Future<Map<String, dynamic>?> deleteAccountApi({
    required String userId,
    required String password,
  }) async {
    try {
      // Build the URL
      final uri = Uri.parse(
        '${ApiUrlConstants.baseUrl}}/delete-account',
      );

      debugPrint('deleteAccountApi URL: $uri');
      debugPrint('deleteAccountApi body: user_id=$userId');

      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiKeyConstants.token) ?? '';

      // Send DELETE request with form-urlencoded body
      final request = http.Request('DELETE', uri)
        ..headers.addAll({
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        })
        ..bodyFields = {
          'user_id': userId,
          'password': password,
        };

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('deleteAccountApi status: ${response.statusCode}');
      debugPrint('deleteAccountApi body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      // Non-200 – still try to parse error message
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'status': '0',
          'message': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('deleteAccountApi error: $e');
      return null;
    }
  }

  static Future<NearbyAirportModel?> getNearbyByAirport(
      {void Function(int)? checkResponse,
      required Map<String, dynamic> bodyParams}) async {
    NearbyAirportModel nearbyAirportModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfAirportNearbyCityDetails,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      nearbyAirportModel =
          NearbyAirportModel.fromJson(jsonDecode(response.body));
      return nearbyAirportModel;
    }
    return null;
  }

  static Future<NotamAirportModel?> getDetailsNotamsApi(
      {void Function(int)? checkResponse,
      required Map<String, dynamic> bodyParams}) async {
    NotamAirportModel notamAirportModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfAirportNotamsRealtime,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      notamAirportModel = NotamAirportModel.fromJson(jsonDecode(response.body));
      return notamAirportModel;
    }
    return null;
  }

  static Future<RoutesAirportModel?> getRoutesApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    RoutesAirportModel routesAirportModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfRoutesDetails,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      routesAirportModel =
          RoutesAirportModel.fromJson(jsonDecode(response.body));
      return routesAirportModel;
    }
    return null;
  }

  static Future<GetProfileModel?> getProfile(
      {void Function(int)? checkResponse,
      required Map<String, dynamic> bodyParams}) async {
    GetProfileModel getProfileModel;
    http.Response? response = await MyHttp.postMethod(
        url: ApiUrlConstants.endPointOfProfile,
        bodyParams: bodyParams,
        checkResponse: checkResponse);
    if (response != null) {
      getProfileModel = GetProfileModel.fromJson(jsonDecode(response.body));
      return getProfileModel;
    }
    return null;
  }

  static Future<ForgotPasswordModel?> forGotPasswordApi(
      {void Function(int)? checkResponse,
      required Map<String, dynamic> bodyParams}) async {
    ForgotPasswordModel forgotPasswordModel;
    http.Response? response = await MyHttp.postMethod(
        url: ApiUrlConstants.endPointOfForgotPassword,
        bodyParams: bodyParams,
        checkResponse: checkResponse);
    if (response != null) {
      forgotPasswordModel =
          ForgotPasswordModel.fromJson(jsonDecode(response.body));
      return forgotPasswordModel;
    }
    return null;
  }

  static Future<ForgotVerifyModel?> otpForgotVerify({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    ForgotVerifyModel? forgotVerifyModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfOtpVerifyForgotPassword,
      checkResponse: checkResponse,
    );
    if (response != null) {
      forgotVerifyModel = ForgotVerifyModel.fromJson(jsonDecode(response.body));
      return forgotVerifyModel;
    }
    return null;
  }

  static Future<PasswordUpdateModel?> updatePassword({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    PasswordUpdateModel? passwordUpdateModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfUpdatePassword,
      checkResponse: checkResponse,
    );
    if (response != null) {
      passwordUpdateModel =
          PasswordUpdateModel.fromJson(jsonDecode(response.body));
      return passwordUpdateModel;
    }
    return null;
  }

  static Future<SupportModel?> supportApi({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    SupportModel? supportModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfSupport,
      checkResponse: checkResponse,
    );
    if (response != null) {
      supportModel = SupportModel.fromJson(jsonDecode(response.body));
      return supportModel;
    }
    return null;
  }

  static Future<PrivacyModel?> privacyPolicyApi({
    void Function(int)? checkResponse,
  }) async {
    try {
      http.Response? response = await MyHttp.getMethod(
        url: ApiUrlConstants.endPointOfPrivacyPolicy,
        checkResponse: checkResponse,
      );

      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PrivacyModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('privacyPolicyApi error: $e');
    }
    return null;
  }

  static Future<ProfileUpdateModel?> updateProfileApi({
    void Function(int)? checkResponse,
    Map<String, dynamic>? bodyParams,
    File? image,
  }) async {
    ProfileUpdateModel? logInModel;
    http.Response? response = await MyHttp.multipart(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfUpdateProfile,
      image: image,
      imageKey: 'profile_photo',
      checkResponse: checkResponse,
    );

    if (response != null) {
      logInModel = ProfileUpdateModel.fromJson(jsonDecode(response.body));
      return logInModel;
    }
    return null;
  }

  static Future<PaymentsCreateModel?> paymentCreate({
    void Function(int)? checkResponse,
    dynamic bodyParams,
  }) async {
    PaymentsCreateModel? paymentsCreateModel;
    http.Response? response = await MyHttp.postMethod(
      bodyParams: bodyParams,
      url: ApiUrlConstants.endPointOfCreatePayment,
      checkResponse: checkResponse,
    );
    if (response != null) {
      paymentsCreateModel =
          PaymentsCreateModel.fromJson(jsonDecode(response.body));
      return paymentsCreateModel;
    }
    return null;
  }

  static Future<UpcomingForecastWeeklyModel?> upcomingForecastApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    UpcomingForecastWeeklyModel upcomingForecastWeeklyModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfUpcomingForecast,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      upcomingForecastWeeklyModel =
          UpcomingForecastWeeklyModel.fromJson(jsonDecode(response.body));
      return upcomingForecastWeeklyModel;
    }
    return null;
  }

  static Future<UpcomingForecastHourlyModel?> upcomingForecastHourlyApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    UpcomingForecastHourlyModel upcomingForecastHourlyModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfUpcomingForecast,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      upcomingForecastHourlyModel =
          UpcomingForecastHourlyModel.fromJson(jsonDecode(response.body));
      return upcomingForecastHourlyModel;
    }
    return null;
  }

  static Future<UpcomingForecastWeeklyModel?> upcomingForecastWeeklyApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    UpcomingForecastWeeklyModel upcomingForecastWeeklyModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfUpcomingForecast,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      upcomingForecastWeeklyModel =
          UpcomingForecastWeeklyModel.fromJson(jsonDecode(response.body));
      return upcomingForecastWeeklyModel;
    }
    return null;
  }

  static Future<AlertsModel?> upcomingAlertsApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    AlertsModel alertsModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfUpcomingAlters,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      alertsModel = AlertsModel.fromJson(jsonDecode(response.body));
      return alertsModel;
    }
    return null;
  }

  static Future<FindRoutesModel?> routesPlanFind(
      {void Function(int)? checkResponse,
      required Map<String, dynamic> bodyParams}) async {
    FindRoutesModel findRoutesModel;
    http.Response? response = await MyHttp.postJsonRawMethod(
        url: ApiUrlConstants.endPointOfRoutesByAirportCode,
        bodyParams: bodyParams,
        checkResponse: checkResponse);
    if (response != null) {
      findRoutesModel = FindRoutesModel.fromJson(jsonDecode(response.body));
      return findRoutesModel;
    }
    return null;
  }

  static Future<ReferralModel?> referralApi({
    void Function(int)? checkResponse,
    required Map<String, dynamic> bodyParams,
  }) async {
    ReferralModel referralModel;
    http.Response? response = await MyHttp.getMethodParams(
      baseUri: ApiUrlConstants.baseUrlForGetMethodParams,
      endPointUri: ApiUrlConstants.endPointOfReferralStatus,
      queryParameters: bodyParams,
      checkResponse: checkResponse,
    );
    if (response != null) {
      referralModel = ReferralModel.fromJson(jsonDecode(response.body));
      return referralModel;
    }
    return null;
  }

  static Future<PlanSchemaModel?> planSchemaModel({
    void Function(int)? checkResponse,
  }) async {
    PlanSchemaModel planSchemaModel;
    http.Response? response = await MyHttp.getMethod(
      url: ApiUrlConstants.endPointOfPlanSchema,
      checkResponse: checkResponse,
    );
    if (response != null) {
      planSchemaModel = PlanSchemaModel.fromJson(jsonDecode(response.body));
      return planSchemaModel;
    }
    return null;
  }

  static Future<PlanPackagesModel?> getPlanPackagesApi({
    void Function(int)? checkResponse,
  }) async {
    PlanPackagesModel planPackagesModel;
    http.Response? response = await MyHttp.getMethod(
      url: ApiUrlConstants.endPointOfPlanPackages,
      checkResponse: checkResponse,
    );
    if (response != null) {
      planPackagesModel = PlanPackagesModel.fromJson(jsonDecode(response.body));
      return planPackagesModel;
    }
    return null;
  }

  static Future<LoginModel?> googleLogin({
    required Map<String, dynamic> bodyParams,
  }) async {
    try {
      final Map<String, dynamic>? response = await MyHttp.postMethodJson(
        url: 'https://python.aitechnotech.in/skypeanut-api/login/google',
        bodyParams: bodyParams,
      );
      if (response == null) return null;
      return LoginModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) print("googleLogin error: $e");
      return null;
    }
  }

  static Future<LoginModel?> facebookLogin({
    required Map<String, dynamic> bodyParams,
  }) async {
    try {
      final Map<String, dynamic>? response = await MyHttp.postMethodJson(
        url: 'https://python.aitechnotech.in/skypeanut-api/login/facebook',
        bodyParams: bodyParams,
      );
      if (response == null) return null;
      return LoginModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) print("facebookLogin error: $e");
      return null;
    }
  }
}
