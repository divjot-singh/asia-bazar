import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

NotificationDetails getNotificationDetails(String title, String body) {
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '1',
    'Tournament notifications',
    'Notifications related to tournament.',
    importance: Importance.Max,
    priority: Priority.Max,
    playSound: true,
    color: Color.fromARGB(0, 255, 94, 100),
    styleInformation: BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      htmlFormatTitle: true,
      contentTitle: "<b>$title</b>",
      htmlFormatContentTitle: true,
      htmlFormatContent: true,
    ),
  );

  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(
    androidPlatformChannelSpecifics,
    iOSPlatformChannelSpecifics,
  );
  // await flutterLocalNotificationsPlugin.show(
  //   0,
  //   notificationData['title'],
  //   notificationData['body'],
  //   platformChannelSpecifics,
  //   payload: 'Default_Sound',
  // );
}

Future showOngoingNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, {
  @required String title,
  @required String body,
  int id = 0,
  Map<String, dynamic> payload,
}) {
  return _showNotification(
    flutterLocalNotificationsPlugin,
    title: title,
    body: body,
    notificationDetails: getNotificationDetails(title, body),
    id: id,
    payload: json.encode(payload),
  );
}

Future _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, {
  @required String title,
  @required String body,
  @required NotificationDetails notificationDetails,
  int id = 0,
  String payload = '',
}) {
  return flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}
