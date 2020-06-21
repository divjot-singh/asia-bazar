import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/screens/user_is_admin/is_admin.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum UserType { Admin, User, New }

class UserDatabase {
  static DatabaseReference database = FirebaseDatabase.instance.reference();
  static DatabaseReference userDatabase = database.child('users');
  static DatabaseReference adminRef = userDatabase.child('admin');
  static DatabaseReference userRef = userDatabase.child('user');

  Future<UserDatabaseState> checkIfAdminOrUser(
      {@required String userId}) async {
    try {
      var adminData = adminRef.child(userId);
      DataSnapshot snapshot = await adminData.once();
      if (snapshot.value == null) {
        dynamic userSnapshot = await getUser(userId: userId);
        if (userSnapshot == null) {
          await addUser(userId: userId);
          return NewUser(user: userSnapshot);
        } else if (userSnapshot is Map &&
            userSnapshot['address'] is List &&
            userSnapshot['address'].length > 0) {
          return UserIsUser(user: userSnapshot);
        } else {
          return NewUser(user: userSnapshot);
        }
      } else
        return UserIsAdmin(user: snapshot);
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser({@required String userId}) async {
    String phoneNumber = await StorageManager.getItem(KeyNames['phone']);
    String userName = await StorageManager.getItem(KeyNames['userName']);
    userRef
        .child(userId)
        .set({KeyNames['userName']: userName, KeyNames['phone']: phoneNumber});
  }

  Future<dynamic> getUser({@required String userId}) async {
    var userData = userRef.child(userId);
    DataSnapshot userSnapshot = await userData.once();
    return userSnapshot.value;
  }
}
