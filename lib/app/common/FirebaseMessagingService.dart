
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class MyLocalNotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initializeSettings(BuildContext context) {
    var androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializeIOSSettings = const DarwinInitializationSettings();

    LinuxInitializationSettings initializeLinuxSettings =
        const LinuxInitializationSettings(
            defaultActionName: 'Open notification');

    var initializeSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: initializeIOSSettings,
        linux: initializeLinuxSettings);

    flutterLocalNotificationsPlugin.initialize(initializeSettings,
        onDidReceiveNotificationResponse: (details) {
      Get.toNamed(Routes.NOTIFICATION_SCREEN);
      print("On Did Received notification:::::::::::::::::::::::::::");
    }, onDidReceiveBackgroundNotificationResponse:
            (NotificationResponse details) {
      print(
          "On Did Background Received notification:::::::::::::::::::::::::::");
    });

    // That's all for the platform setting's to be initialize .
  }

  // Now it's time to show the notification .

  /*
  void showSimpleNotification() {
    // Here you have to set the detail's that will be displayed on all of the app's .

    var androidNotificationDetails = const AndroidNotificationDetails(
        // The channel id must be unique for all of the notification's .
        // Required for Android 8.0 or newer.
        "channel_Id_1",
        // channel name
        // Required for Android 8.0 or newer.
        "notification_channel_Name",

        //  The priority is the enum that is used to set the priority of the notification .
        // /// Priority for notifications on Android 7.1 and lower.
        priority: Priority.max,
        //  For detailed information about these topics kindly read it from the official documentation .
        importance: Importance.max,
        // Whether the notification sound will be played when the notification received .
        // Indicates if a sound should be played when the notification is displayed.

// For Android 8.0 or newer, this is tied to the specified channel and cannot be changed after the channel has been created for the first time.
        playSound: true,

        // Specifies if the notification should automatically dismissed upon tapping on it.
        autoCancel: false,

        // Category property is used to set the category of the notification which mean's that it belong's to which category like it is alrm notification , call notification , email or message etc .
        // For detailed information or categories kindly read the android notification category enum
        // https://pub.dev/documentation/flutter_local_notifications/latest/flutter_local_notifications/AndroidNotificationCategory.html

        // category: AndroidNotificationCategory.message  ,

        // color: Colors.red

        channelDescription: "channel_description");

    //  In the same way you have to add the detail's for the other platform's .

    var iosNotificationDetails = const DarwinNotificationDetails();

    // Now set all of the platform notification detail's in notification details class .
    //
    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails
        // In the same way you have to add the notification for all of the platform you want's notification .
        );

    flutterLocalNotificationsPlugin.show(
        0, "notification_title", "notifications _ body", notificationDetails,
        payload: "Data received using payload of notification");
  }*/
}
