import 'package:get/get.dart';

import '../modules/AgreementScreen/bindings/agreement_screen_binding.dart';
import '../modules/AgreementScreen/views/agreement_screen_view.dart';
import '../modules/CreditsScreen/bindings/credits_screen_binding.dart';
import '../modules/CreditsScreen/views/credits_screen_view.dart';
import '../modules/FlightMap/bindings/flight_map_binding.dart';
import '../modules/FlightMap/views/flight_map_view.dart';
import '../modules/NOTAMS_details_screen/bindings/n_o_t_a_m_s_details_screen_binding.dart';
import '../modules/NOTAMS_details_screen/views/n_o_t_a_m_s_details_screen_view.dart';
import '../modules/Nav_bar_screen/bindings/nav_bar_screen_binding.dart';
import '../modules/Nav_bar_screen/views/nav_bar_screen_view.dart';
import '../modules/NotamForBack/bindings/notam_for_back_binding.dart';
import '../modules/NotamForBack/views/notam_for_back_view.dart';
import '../modules/NotificationForNavBar/bindings/notification_for_nav_bar_binding.dart';
import '../modules/NotificationForNavBar/views/notification_for_nav_bar_view.dart';
import '../modules/Reg/bindings/reg_binding.dart';
import '../modules/Reg/views/reg_view.dart';
import '../modules/Registration/bindings/registration_binding.dart';
import '../modules/Registration/views/registration_view.dart';
import '../modules/SearchRoutesScreen/bindings/search_routes_screen_binding.dart';
import '../modules/SearchRoutesScreen/views/search_routes_screen_view.dart';
import '../modules/Send_otp_password/bindings/send_otp_password_binding.dart';
import '../modules/Send_otp_password/views/send_otp_password_view.dart';
import '../modules/SettingForBack/bindings/setting_for_back_binding.dart';
import '../modules/SettingForBack/views/setting_for_back_view.dart';
import '../modules/Splash_Lite_screen/bindings/splash_lite_screen_binding.dart';
import '../modules/Splash_Lite_screen/views/splash_lite_screen_view.dart';
import '../modules/Up_comming_forcast_screem/bindings/up_comming_forcast_screem_binding.dart';
import '../modules/Up_comming_forcast_screem/views/up_comming_forcast_screem_view.dart';
import '../modules/Update_password_screen/bindings/update_password_screen_binding.dart';
import '../modules/Update_password_screen/views/update_password_screen_view.dart';
import '../modules/Weather_settings_screen/bindings/weather_settings_screen_binding.dart';
import '../modules/Weather_settings_screen/views/weather_settings_screen_view.dart';
import '../modules/ai_chat_screen/bindings/ai_chat_screen_binding.dart';
import '../modules/ai_chat_screen/views/ai_chat_screen_view.dart';
import '../modules/air_quility/bindings/air_quility_binding.dart';
import '../modules/air_quility/views/air_quility_view.dart';
import '../modules/forgot_password_screen/bindings/forgot_password_screen_binding.dart';
import '../modules/forgot_password_screen/views/forgot_password_screen_view.dart';
import '../modules/get_started_page_screen/bindings/get_started_page_screen_binding.dart';
import '../modules/get_started_page_screen/views/get_started_page_screen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/loader_screen/bindings/loader_screen_binding.dart';
import '../modules/loader_screen/views/loader_screen_view.dart';
import '../modules/login_screen/bindings/login_screen_binding.dart';
import '../modules/login_screen/views/login_screen_view.dart';
import '../modules/map_routes_full_page/bindings/map_routes_full_page_binding.dart';
import '../modules/map_routes_full_page/views/map_routes_full_page_view.dart';
import '../modules/map_routes_page/bindings/map_routes_page_binding.dart';
import '../modules/map_routes_page/views/map_routes_page_view.dart';
import '../modules/notams_screen/bindings/notams_screen_binding.dart';
import '../modules/notams_screen/views/notams_screen_view.dart';
import '../modules/notification_screen/bindings/notification_screen_binding.dart';
import '../modules/notification_screen/views/notification_screen_view.dart';
import '../modules/on_boarding_screen/bindings/on_boarding_screen_binding.dart';
import '../modules/on_boarding_screen/views/on_boarding_screen_view.dart';
import '../modules/otp_verify_screen/bindings/otp_verify_screen_binding.dart';
import '../modules/otp_verify_screen/views/otp_verify_screen_view.dart';
import '../modules/packages_plans_creadit_screen/bindings/packages_plans_creadit_screen_binding.dart';
import '../modules/packages_plans_creadit_screen/views/packages_plans_creadit_screen_view.dart';
import '../modules/privacy_policy_screen/bindings/privacy_policy_screen_binding.dart';
import '../modules/privacy_policy_screen/views/privacy_policy_screen_view.dart';
import '../modules/question_screen/bindings/question_screen_binding.dart';
import '../modules/question_screen/views/question_screen_view.dart';
import '../modules/referral_screen/bindings/referral_screen_binding.dart';
import '../modules/referral_screen/views/referral_screen_view.dart';
import '../modules/routes_screen/bindings/routes_screen_binding.dart';
import '../modules/routes_screen/views/routes_screen_view.dart';
import '../modules/setting_screen/bindings/setting_screen_binding.dart';
import '../modules/setting_screen/views/setting_screen_view.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/successfully_screen/bindings/successfully_screen_binding.dart';
import '../modules/successfully_screen/views/successfully_screen_view.dart';
import '../modules/support_screen/bindings/support_screen_binding.dart';
import '../modules/support_screen/views/support_screen_view.dart';
import '../modules/update_profile_screen/bindings/update_profile_screen_binding.dart';
import '../modules/update_profile_screen/views/update_profile_screen_view.dart';
import '../modules/weather_details_screen/bindings/weather_details_screen_binding.dart';
import '../modules/weather_details_screen/views/weather_details_screen_view.dart';
import '../modules/weather_screen/bindings/weather_screen_binding.dart';
import '../modules/weather_screen/views/weather_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_LITE_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_LITE_SCREEN,
      page: () => const SplashLiteScreenView(),
      binding: SplashLiteScreenBinding(),
    ),
    GetPage(
      name: _Paths.GET_STARTED_PAGE_SCREEN,
      page: () => const GetStartedPageScreenView(),
      binding: GetStartedPageScreenBinding(),
    ),
    GetPage(
      name: _Paths.ON_BOARDING_SCREEN,
      page: () => const OnBoardingScreenView(),
      binding: OnBoardingScreenBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.LOADER_SCREEN,
      page: () => const LoaderScreenView(),
      binding: LoaderScreenBinding(),
    ),
    GetPage(
      name: _Paths.OTP_VERIFY_SCREEN,
      page: () => const OtpVerifyScreenView(),
      binding: OtpVerifyScreenBinding(),
    ),
    GetPage(
      name: _Paths.SUCCESSFULLY_SCREEN,
      page: () => const SuccessfullyScreenView(),
      binding: SuccessfullyScreenBinding(),
    ),
    GetPage(
      name: _Paths.NAV_BAR_SCREEN,
      page: () => const NavBarScreenView(),
      binding: NavBarScreenBinding(),
    ),
    GetPage(
      name: _Paths.WEATHER_SCREEN,
      page: () => const WeatherScreenView(),
      binding: WeatherScreenBinding(),
    ),
    GetPage(
      name: _Paths.NOTAMS_SCREEN,
      page: () => const NotamsScreenView(),
      binding: NotamsScreenBinding(),
    ),
    GetPage(
      name: _Paths.ROUTES_SCREEN,
      page: () => const FlightStatusScreenView(),
      binding: RoutesScreenBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_SCREEN,
      page: () => const SettingScreenView(),
      binding: SettingScreenBinding(),
    ),
    GetPage(
      name: _Paths.MAP_ROUTES_PAGE,
      page: () => const MapRoutesPageView(),
      binding: MapRoutesPageBinding(),
    ),
    GetPage(
      name: _Paths.MAP_ROUTES_FULL_PAGE,
      page: () => const MapRoutesFullPageView(),
      binding: MapRoutesFullPageBinding(),
    ),
    GetPage(
      name: _Paths.REFERRAL_SCREEN,
      page: () => const ReferralScreenView(),
      binding: ReferralScreenBinding(),
    ),
    GetPage(
      name: _Paths.AI_CHAT_SCREEN,
      page: () => const AiChatScreenView(),
      binding: AiChatScreenBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_PROFILE_SCREEN,
      page: () => const UpdateProfileScreenView(),
      binding: UpdateProfileScreenBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY_SCREEN,
      page: () => const PrivacyPolicyScreenView(),
      binding: PrivacyPolicyScreenBinding(),
    ),
    GetPage(
      name: _Paths.SUPPORT_SCREEN,
      page: () => const SupportScreenView(),
      binding: SupportScreenBinding(),
    ),
    GetPage(
      name: _Paths.WEATHER_DETAILS_SCREEN,
      page: () => const WeatherDetailsScreenView(),
      binding: WeatherDetailsScreenBinding(),
    ),
    GetPage(
      name: _Paths.N_O_T_A_M_S_DETAILS_SCREEN,
      page: () => const NOTAMSDetailsScreenView(),
      binding: NOTAMSDetailsScreenBinding(),
    ),
    GetPage(
      name: _Paths.QUESTION_SCREEN,
      page: () => const QuestionScreenView(),
      binding: QuestionScreenBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD_SCREEN,
      page: () => const ForgotPasswordScreenView(),
      binding: ForgotPasswordScreenBinding(),
    ),
    GetPage(
      name: _Paths.SEND_OTP_PASSWORD,
      page: () => const SendOtpPasswordView(),
      binding: SendOtpPasswordBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_PASSWORD_SCREEN,
      page: () => const UpdatePasswordScreenView(),
      binding: UpdatePasswordScreenBinding(),
    ),
    GetPage(
      name: _Paths.UP_COMMING_FORCAST_SCREEM,
      page: () => const UpCommingForcastScreemView(),
      binding: UpCommingForcastScreemBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_ROUTES_SCREEN,
      page: () => const SearchRoutesScreenView(),
      binding: SearchRoutesScreenBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_SCREEN,
      page: () => const NotificationScreenView(),
      binding: NotificationScreenBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGES_PLANS_CREADIT_SCREEN,
      page: () => const PackagesPlansCreaditScreenView(),
      binding: PackagesPlansCreaditScreenBinding(),
    ),
    GetPage(
      name: _Paths.WEATHER_SETTINGS_SCREEN,
      page: () => const WeatherSettingsScreenView(),
      binding: WeatherSettingsScreenBinding(),
    ),
    GetPage(
      name: _Paths.CREDITS_SCREEN,
      page: () => const CreditsScreenView(),
      binding: CreditsScreenBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_FOR_BACK,
      page: () => const SettingForBackView(),
      binding: SettingForBackBinding(),
    ),
    GetPage(
      name: _Paths.NOTAM_FOR_BACK,
      page: () => const NotamForBackView(),
      binding: NotamForBackBinding(),
    ),
    GetPage(
      name: _Paths.REGISTRATION,
      page: () => const RegistrationView(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: _Paths.FLIGHT_MAP,
      page: () => const FlightMapScreen(
        miniSize: false,
      ),
      binding: FlightMapBinding(),
    ),
    GetPage(
      name: _Paths.AGREEMENT_SCREEN,
      page: () => const AgreementScreenView(),
      binding: AgreementScreenBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_FOR_NAV_BAR,
      page: () => const NotificationForNavBarView(),
      binding: NotificationForNavBarBinding(),
    ),
    GetPage(
      name: _Paths.REG,
      page: () => const RegView(),
      binding: RegBinding(),
    ),
    GetPage(
      name: _Paths.AIR_QUILITY,
      page: () => const AirQuilityView(),
      binding: AirQuilityBinding(),
    ),
  ];
}
