class ApiUrlConstants {
  static const String baseUrl = 'https://python.aitechnotech.in/skypeanut-api/';
  static const String baseUrlForGetMethodParams = 'python.aitechnotech.in';

  static const String endPointOfUserSignup = '${baseUrl}register';
  static const String endPointOfOtpVerify = '${baseUrl}verify-otp';
  static const String endPointOfLogin = '${baseUrl}login';
  static const String endPointOfResendOtp = '${baseUrl}resend-otp';
  static const String endPointOfProfile = '${baseUrl}profile';
  static const String endPointOfUpdateProfile = '${baseUrl}update-profile';
  static const String endPointOfForgotPassword = '${baseUrl}forgot-password';
  static const String endPointOfOtpVerifyForgotPassword =
      '${baseUrl}verify-forgot-otp';
  static const String endPointOfUpdatePassword = '${baseUrl}update-password';
  static const String endPointOfPrivacyPolicy = '${baseUrl}privacy-policy';
  static const String endPointOfSupport = '${baseUrl}support';

  static const String endPointOfCreatePayment = '${baseUrl}api/payments/create';

  static const String endPointOfWeather = '/skypeanut-api/weather/realtime';
  static const String endPointOfNearbyWeather = '/skypeanut-api/weather/nearby';
  static const String endPointOfWeatherCityDetails =
      '/skypeanut-api/weather/city-details';
  static const String endPointOfRoutesDetails = 'skypeanut-api-api/routes/details';

  static const String endPointOfUpcomingForecast =
      'skypeanut-api/upcoming_forecast';
  static const String endPointOfUpcomingAlters = 'skypeanut-api/alerts/realtime';

  static const String endPointOfAirportNearestCityDetails =
      'skypeanut-api/airport/nearest';
  static const String endPointOfAirportNearbyCityDetails =
      'skypeanut-api/airport/nearby';
  static const String endPointOfAirportNotamsRealtime =
      'skypeanut-api/notams/realtime';

  static const String endPointOfNotamByAirport = '$baseUrl/notam/route';
  static const String endPointOfRoutesByAirportCode = '${baseUrl}routes/plan';

  static const String endPointOfPlanPackages = '${baseUrl}credits/packages';
  static const String endPointOfReferralStatus = 'skypeanut-api/referral/stats';
  static const String endPointOfPlanSchema =
      '$baseUrl/credits/schema';
}
