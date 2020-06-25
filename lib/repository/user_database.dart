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

  Future<void> onboardUser(
      {@required String userId,
      @required String username,
      @required Map address}) async {
    await addAddress(userId: userId, address: address);
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      await userRef.child(userId).update({KeyNames['userName']: username});
    }
  }

  Future<void> updateAddress(
      {@required Map address,
      @required String timestamp,
      @required String userId}) async {
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      List addressList;
      if (snapshot.value[KeyNames['address']] is List) {
        addressList = [...snapshot.value[KeyNames['address']]];
      } else {
        addressList = [];
      }

      int index = addressList
          .indexWhere((item) => item['timestamp'].toString() == timestamp);
      if (index > -1) {
        addressList[index] = address;
        await userRef.child(userId).update({KeyNames['address']: addressList});
      }
    }
  }

  Future<void> deleteAddress(
      {@required String timestamp, @required String userId}) async {
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      List addressList;
      if (snapshot.value[KeyNames['address']] is List) {
        addressList = [...snapshot.value[KeyNames['address']]];
      } else {
        addressList = [];
      }
      addressList
          .removeWhere((item) => item['timestamp'].toString() == timestamp);
      await userRef.child(userId).update({KeyNames['address']: addressList});
    }
  }

  Future<void> setDefault(
      {@required String timestamp, @required String userId}) async {
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      List addressList;
      if (snapshot.value[KeyNames['address']] is List) {
        addressList = [...snapshot.value[KeyNames['address']]];
      } else {
        addressList = [];
      }
      addressList.forEach((item) {
        if (item['timestamp'].toString() == timestamp) {
          item['is_default'] = true;
        } else
          item['is_default'] = false;
      });
      await userRef.child(userId).update({KeyNames['address']: addressList});
    }
  }

  Future<void> updateUsername(
      {@required String userId, @required String username}) async {
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      await userRef.child(userId).update({KeyNames['userName']: username});
    }
  }

  Future<void> addAddress(
      {@required String userId, @required Map address}) async {
    DataSnapshot snapshot = await userRef.child(userId).once();
    if (snapshot.value != null) {
      List addressList;
      if (snapshot.value[KeyNames['address']] is List) {
        addressList = [...snapshot.value[KeyNames['address']]];
      } else {
        addressList = [];
      }
      address['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      addressList.add(address);
      await userRef.child(userId).update({KeyNames['address']: addressList});
    }
  }

  Future<void> addUser({@required String userId}) async {
    String phoneNumber = await StorageManager.getItem(KeyNames['phone']);
    String userName = await StorageManager.getItem(KeyNames['userName']);
    userRef.child(userId).set({
      KeyNames['userName']: userName,
      KeyNames['phone']: phoneNumber,
      KeyNames['address']: []
    });
  }

  Future<dynamic> getUser({@required String userId}) async {
    var userData = userRef.child(userId);
    DataSnapshot userSnapshot = await userData.once();
    return userSnapshot.value;
  }
}
