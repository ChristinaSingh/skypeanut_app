import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

class PushNotificationService {
  FirebaseMessaging fcm = FirebaseMessaging.instance;

  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  }

  static Future<String?> getToken() async {
    try {
      print("========== FCM TOKEN START ==========");

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      /// ANDROID
      if (Platform.isAndroid) {
        print("Platform: ANDROID");

        String? token = await messaging.getToken();

        print("FCM Token (Android): $token");
        print("========== FCM TOKEN END ==========");

        return token;
      }

      /// IOS
      else if (Platform.isIOS) {
        print("Platform: IOS");

        /// Request notification permission
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        print("Permission Status: ${settings.authorizationStatus}");

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          print("❌ Notification permission denied");
          return null;
        }

        /// Wait for APNS token
        String? apnsToken;

        int retry = 0;

        while (apnsToken == null && retry < 10) {
          print("Waiting for APNS Token... Attempt: $retry");

          apnsToken = await messaging.getAPNSToken();

          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 1));
            retry++;
          }
        }

        print("APNS Token: $apnsToken");

        if (apnsToken == null) {
          print("❌ Failed to get APNS Token");
          return null;
        }

        /// Get FCM Token
        String? token = await messaging.getToken();

        print("Firebase FCM Token (iOS): $token");

        print("========== FCM TOKEN END ==========");

        return token;
      }

      /// OTHER PLATFORM
      else {
        print("Unsupported platform");
        return null;
      }
    } catch (e, stack) {
      print("❌ FCM TOKEN ERROR");
      print("Error: $e");
      print("StackTrace: $stack");
      return null;
    }
  }
}
