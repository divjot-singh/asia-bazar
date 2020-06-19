import 'package:asia/models/user.dart';
import 'package:asia/services/log_printer.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthCallbackType { completed, failed, codeSent, timeout }

class AuthRepo {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static final logger = getLogger('AuthRepo');
  var _verificationId = '';
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
          callback(AuthCallbackType.completed, authException);
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
          firebaseToken: tokenResult.token);
    } catch (error) {
      user = User(
        userId: firebaseUser.uid,
        userName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
      );
    } finally {
      await StorageManager.setItem(
          PersistentStorageKeys["userId"], user.userId);
      await StorageManager.setItem(
          PersistentStorageKeys["userName"], user.userName);
      await StorageManager.setItem(
          PersistentStorageKeys["phoneNumber"], user.phoneNumber);
      await StorageManager.setItem(
          PersistentStorageKeys["token"], user.firebaseToken);
    }
    return user;
  }

  Future<User> signInWithSmsCode(String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
      smsCode: smsCode,
      verificationId: _verificationId,
    );
    return await _verificationComplete(authCredential);
  }
}