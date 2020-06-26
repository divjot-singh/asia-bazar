import 'dart:convert';

import 'package:asia/utils/local_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  final Map<String, dynamic> notificationMessage;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String operatingSystem;
  final int notificationId;

  LocalNotification({
    @required this.flutterLocalNotificationsPlugin,
    @required this.notificationMessage,
    @required this.operatingSystem,
    @required this.notificationId,
  });
}

class LocalNotificationAndroid extends LocalNotification {
  LocalNotificationAndroid({
    final Map<String, dynamic> notificationMessage,
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    final String operatingSystem,
    final int notificationId,
  }) : super(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          notificationMessage: notificationMessage,
          operatingSystem: operatingSystem,
          notificationId: notificationId,
        );

  String getTitle() {
    //var notification = notificationMessage["data"];
    return notificationMessage["title"];
  }

  String getBody() {
    var notification = notificationMessage["data"];
    return notificationMessage["body"];
  }

  String getRedirectPath() {
    var notificationData = notificationMessage["data"];
    return notificationMessage["redirect_path"];
  }

  String getServerNotificationId() {
    var notificationData = notificationMessage["data"];
    return notificationData["server_notification_id"];
  }

  bool isAdminNotification() {
    var notificationData = notificationMessage["data"];
    if (notificationData.containsKey("is_admin_notification")) {
      return notificationData["is_admin_notification"] == 'true';
    }
    return false;
  }

  Future<Map<String, dynamic>> getArguments() async {
    var notificationData = notificationMessage["data"];
    if (notificationData.containsKey("arguments")) {
      var arguments = json.decode(notificationData["arguments"]);

      return arguments;
    }
    return {};
  }

  showNotificationOnTray() async {
    showOngoingNotification(
      flutterLocalNotificationsPlugin,
      title: getTitle(),
      body: getBody(),
      id: notificationId,
      payload: {
        // "redirectPath": getRedirectPath(),
        // "serverNotificationId": getServerNotificationId(),
        // "isAdminNotification": isAdminNotification(),
        // "arguments": await getArguments(),
      },
    );
  }
}

class LocalNotificationIos extends LocalNotification {
  LocalNotificationIos({
    final Map<String, dynamic> notificationMessage,
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    final String operatingSystem,
    final int notificationId,
  }) : super(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          notificationMessage: notificationMessage,
          operatingSystem: operatingSystem,
          notificationId: notificationId,
        );

  String getTitle() {
    return notificationMessage["title"];
  }

  String getBody() {
    return notificationMessage["body"];
  }

  String getRedirectPath() {
    return notificationMessage["redirect_path"];
  }

  String getServerNotificationId() {
    return notificationMessage["server_notification_id"];
  }

  bool isAdminNotification() {
    if (notificationMessage.containsKey("is_admin_notification")) {
      return notificationMessage["is_admin_notification"] == 'true';
    }
    return false;
  }

  Future<Map<String, dynamic>> getArguments() async {
    if (notificationMessage.containsKey("arguments")) {
      var arguments = json.decode(notificationMessage["arguments"]);

      return arguments;
    }
    return {};
  }

  showNotificationOnTray() async {
    showOngoingNotification(
      flutterLocalNotificationsPlugin,
      title: getTitle(),
      body: getBody(),
      id: notificationId,
      payload: {
        "redirectPath": getRedirectPath(),
        "serverNotificationId": getServerNotificationId(),
        "isAdminNotification": isAdminNotification(),
        "arguments": await getArguments(),
      },
    );
  }
}

dynamic getLocalNotification({
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
