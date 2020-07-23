import 'dart:convert';
import 'dart:io';

import 'package:asia/utils/local_notifications.dart';
import 'package:asia/utils/navigator_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ConfigureNotification {
  static FirebaseMessaging _fcm = FirebaseMessaging();
  static int notificationId = 0;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void configureNotifications() {
    final androidInitializationSettings = AndroidInitializationSettings(
      '@drawable/launch_background',
    );
    final iosInitializationSettings = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      androidInitializationSettings,
      iosInitializationSettings,
    );
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onForegroundNotificationClick,
    );
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        onForegroundNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch');
        await onBackgroundNotificationClick(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume');
        await onBackgroundNotificationClick(message);
      },
    );
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(
        const IosNotificationSettings(
          sound: true,
          badge: true,
          alert: true,
          provisional: true,
        ),
      );
      _fcm.onIosSettingsRegistered.listen(
        (IosNotificationSettings settings) {
          print("Settings registered: $settings");
        },
      );
    }
  }

  static Future<void> onForegroundNotificationClick(String payload) async {
    if (payload != null) {
      var payloadJson = json.decode(payload);

      var redirectPath = payloadJson['redirectPath'];
      //var arguments = payloadJson['arguments'];
      locator<NavigationService>().navigateTo(redirectPath);
    }
  }

  static void onForegroundNotification(Map<String, dynamic> message) {
    print(message);
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      print("Operating system not supported!");
      return;
    }

    localNotification.showNotificationOnTray();
    notificationId += 1;
  }

  static Future<void> onBackgroundNotificationClick(
    Map<String, dynamic> message,
  ) async {
    print('inside bg click');
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      print("Operating system not supported!");
      return;
    }

    notificationId += 1;
    var redirectPath = localNotification.getRedirectPath();
    //var arguments = await localNotification.getArguments();
    locator<NavigationService>().navigateTo(redirectPath);
  }

  static dynamic getLocalNotification({
    Map<String, dynamic> notificationMessage,
    BuildContext context,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String operatingSystem,
    int notificationId,
  }) {
    if (operatingSystem == 'android') {
      return LocalNotificationAndroid(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        notificationMessage: notificationMessage,
        operatingSystem: operatingSystem,
        notificationId: notificationId,
      );
    } else if (operatingSystem == 'ios') {
      return LocalNotificationIos(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        notificationMessage: notificationMessage,
        operatingSystem: operatingSystem,
        notificationId: notificationId,
      );
    }
    return null;
  }
}
