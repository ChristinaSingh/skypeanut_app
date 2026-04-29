import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'app/common/colors.dart';
import 'app/common/theme_data.dart';
import 'app/data/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message_id::::::::: ${message.messageId}');
/*  try {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> jsonData =
    jsonDecode(sharedPreferences.getString(StringConstants.userData)!);
    if (jsonData != null) {
      LogInModel userData = LogInModel.fromJson(jsonData);
      Map<String, dynamic> queryParamsForGetNotificationCount = {
        ApiKeyConstants.userId: userData.result!.id ?? '',
      };
      NotificationCountModel? notificationCountModel =
      await ApiMethods.getNotificationCountApi(
          queryParameters: queryParamsForGetNotificationCount);
      if (notificationCountModel!.status != "0" ?? false) {
        FlutterAppBadger.updateBadgeCount(notificationCountModel.count ?? 0);
        print('App Badger count:-${notificationCountModel.count ?? '0'}');
      }
    }
  } catch (e) {
    print('Error while getting notification count:- $e');
  }  */
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // CommonMethods.unFocsKeyBoard();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: darkModeBlack,
  ));

  if (Platform.isAndroid) {
    print('Push Notification Android background notification start....');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        /*     onDidReceiveBackgroundNotificationResponse: (details) {
      print('pressed notification....');
      print('the notification is selected 12 ${details.payload}');
    },*/
        onDidReceiveNotificationResponse: (payload) async {
      print('pressed notification....');
      print('the notification is selected 12 ${payload.payload}');
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else {
    print('Push Notification Ios background notification start....');
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  runApp(
    GetMaterialApp(
      title: "Skypeanut",
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: MThemeData.themeData(),
      fallbackLocale: const Locale('en', 'US'),
    ),
  );

  Stripe.publishableKey =
      'YOUR_STRIPE_KEY';
}
