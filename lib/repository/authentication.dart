import 'dart:io';

import 'package:asia/models/user.dart';
import 'package:asia/services/log_printer.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthImport;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum AuthCallbackType { completed, failed, codeSent, timeout }

class AuthRepo {
  static FirebaseAuthImport.FirebaseAuth _auth =
      FirebaseAuthImport.FirebaseAuth.instance;
  static FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final logger = getLogger('AuthRepo');
  static List<String> serverNotificationIds = [];
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
        verificationCompleted:
            ((FirebaseAuthImport.PhoneAuthCredential authCredential) async {
          await _verificationComplete(authCredential);
          callback(AuthCallbackType.completed, authCredential);
        }),
        verificationFailed:
            (FirebaseAuthImport.FirebaseAuthException authException) {
          print(authException.message);
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

  Future<User> _verificationComplete(
      FirebaseAuthImport.PhoneAuthCredential authCredential) async {
    _authCredential = authCredential;
    var authResult = await _auth.signInWithCredential(authCredential);
    logger.i(authResult);
    return await setupUserData(authResult.user);
  }

  Future<User> checkIfUserLoggedIn() async {
    FirebaseAuthImport.User firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    } else {
      User user = await setupUserData(firebaseUser);
      return user;
    }
  }

  Future<User> setupUserData(FirebaseAuthImport.User firebaseUser) async {
    var user;
    try {
      String tokenResult = await firebaseUser.getIdToken(true);
      user = User(
          userId: firebaseUser.uid,
          userName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
          cart: null,
          firebaseToken: tokenResult);
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

  Future<void> setUpFcm({@required String userId}) async {
    var firebaseToken = await _fcm.getToken();

    if (firebaseToken != null) {
      await FirebaseFirestore.instance
          .collection('usersTokens')
          .doc(userId)
          .set({
        'user_id': userId,
        'token': firebaseToken,
        'platform': Platform.isIOS
            ? 'ios'
            : Platform.isAndroid
                ? 'android'
                : 'web'
      });
      await StorageManager.setItem(KeyNames['fcmToken'], firebaseToken);
    }
  }

  Future<User> signInWithSmsCode(String smsCode) async {
    FirebaseAuthImport.AuthCredential authCredential =
        FirebaseAuthImport.PhoneAuthProvider.credential(
      smsCode: smsCode,
      verificationId: _verificationId,
    );
    return await _verificationComplete(authCredential);
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
