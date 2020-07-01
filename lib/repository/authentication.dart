import 'dart:convert';
import 'dart:io';

import 'package:asia/models/user.dart';
import 'package:asia/services/log_printer.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/local_notifications.dart';
import 'package:asia/utils/navigator_service.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum AuthCallbackType { completed, failed, codeSent, timeout }

class AuthRepo {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseDatabase db = FirebaseDatabase.instance;
  static Firestore _firestore = Firestore.instance;
  static FirebaseMessaging _fcm = FirebaseMessaging();
  static final logger = getLogger('AuthRepo');
  static List<String> serverNotificationIds = [];
  static CollectionReference cartRef = _firestore.collection('cart');
  int notificationId = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static List<String> onClickServerNotificationIds = [];
  var _verificationId = '';
  var _authCredential;
  void verifyPhoneNumber(
      {@required String phoneNumber, @required Function callback}) {
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: ((AuthCredential authCredential) async {
          await _verificationComplete(authCredential);
          callback(AuthCallbackType.completed, authCredential);
        }),
        verificationFailed: (AuthException authException) {
          callback(AuthCallbackType.failed, authException);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          _verificationId = verificationId;
          callback(AuthCallbackType.codeSent);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          callback(AuthCallbackType.timeout);
        });
  }

  Future<User> _verificationComplete(AuthCredential authCredential) async {
    _authCredential = authCredential;
    var authResult = await _auth.signInWithCredential(authCredential);
    logger.i(authResult);
    return await setupUserData(authResult.user);
  }

  Future<User> checkIfUserLoggedIn() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      return null;
    } else {
      User user = await setupUserData(firebaseUser);
      return user;
    }
  }

  Future<User> setupUserData(FirebaseUser firebaseUser) async {
    var user;
    try {
      IdTokenResult tokenResult = await firebaseUser.getIdToken(refresh: true);
      user = User(
          userId: firebaseUser.uid,
          userName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
          cart: null,
          firebaseToken: tokenResult.token);
    } catch (error) {
      user = User(
        userId: firebaseUser.uid,
        userName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        cart: null,
      );
    } finally {
      setUpFcm(userId: firebaseUser.uid);
      await StorageManager.setItem(KeyNames["userId"], user.userId);
      await StorageManager.setItem(KeyNames["userName"], user.userName);
      await StorageManager.setItem(KeyNames["phone"], user.phoneNumber);
      await StorageManager.setItem(KeyNames["token"], user.firebaseToken);
    }
    return user;
  }

  Future<void> onForegroundNotificationClick(String payload) async {
    if (payload != null) {
      var payloadJson = json.decode(payload);
      if (checkIfDuplicateNotificationOnClick(
        payloadJson['serverNotificationId'],
      )) {
        return;
      }
      var redirectPath = payloadJson['redirectPath'];
      var arguments = payloadJson['arguments'];
      locator<NavigationService>()
          .navigateTo(redirectPath, arguments: arguments);
    }
  }

  bool checkIfDuplicateNotificationOnClick(String serverNotificationId) {
    if (onClickServerNotificationIds.contains(serverNotificationId)) {
      return true;
    }
    onClickServerNotificationIds.add(serverNotificationId);
    return false;
  }

  void onForegroundNotification(Map<String, dynamic> message) {
    print(message);
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      logger.i("Operating system not supported!");
      return;
    }
    // if (checkIfDuplicateNotification(localNotification)) {
    //   return;
    // }

    localNotification.showNotificationOnTray();
    notificationId += 1;
  }

  bool checkIfDuplicateNotification(dynamic localNotification) {
    var serverNotificationId = localNotification.getServerNotificationId();
    if (serverNotificationIds.contains(serverNotificationId)) {
      return true;
    }
    serverNotificationIds.add(serverNotificationId);
    return false;
  }

  Future<void> onBackgroundNotificationClick(
    Map<String, dynamic> message,
  ) async {
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      logger.i("Operating system not supported!");
      return;
    }
    if (checkIfDuplicateNotification(localNotification)) {
      return;
    }

    notificationId += 1;
    var redirectPath = localNotification.getRedirectPath();
    var arguments = await localNotification.getArguments();
    locator<NavigationService>().navigateTo(redirectPath, arguments: arguments);
  }

  Future<void> setUpFcm({@required String userId}) async {
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
        try {
          var notification = message['notification'];
          notification = notification.cast<String, dynamic>();
          print(notification);
          onForegroundNotification(notification);
        } catch (e) {
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        var notification = message['notification'];
        await onBackgroundNotificationClick(notification);
      },
      onResume: (Map<String, dynamic> message) async {
        var notification = message['notification'];
        await onBackgroundNotificationClick(notification);
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
          logger.i("Settings registered: $settings");
        },
      );
    }

    var firebaseToken = await _fcm.getToken();

    if (firebaseToken != null) {
      await Firestore.instance.collection('users').document(userId).setData({
        'user_id': userId,
        'token': firebaseToken,
        'platform':
            Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web'
      });
      await StorageManager.setItem(KeyNames['fcmToken'], firebaseToken);
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

  Future<User> signInWithSmsCode(String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
      smsCode: smsCode,
      verificationId: _verificationId,
    );
    return await _verificationComplete(authCredential);
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
