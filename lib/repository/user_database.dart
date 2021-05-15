import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum UserType { Admin, User, New }

class UserDatabase {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference userDatabase = _firestore.collection('users');
  static DocumentReference userRef =
      _firestore.collection('users').doc('user');
  static DocumentReference adminRef =
      _firestore.collection('users').doc('admin');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  Future<UserDatabaseState> checkIfAdminOrUser(
      {@required String userId}) async {
    try {
      var adminData = adminRef.collection('entries').doc(userId);
      DocumentSnapshot snapshot = await adminData.get();
      if (snapshot.data == null) {
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
    DocumentSnapshot snapshot =
        await userRef.collection('entries').doc(userId).get();
    if (snapshot.data != null) {
      await userRef
          .collection('entries')
          .doc(userId)
          .updateData({KeyNames['userName']: username});
    }
  }

  Future<void> updateAddress(
      {@required Map address,
      @required String timestamp,
      @required String userId}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      List addressList;
      if (snapshot.data[KeyNames['address']] is List) {
        addressList = [...snapshot.data[KeyNames['address']]];
      } else {
        addressList = [];
      }

      int index = addressList
          .indexWhere((item) => item['timestamp'].toString() == timestamp);
      if (index > -1) {
        addressList[index] = address;
        await userRef
            .collection('entries')
            .document(userId)
            .updateData({KeyNames['address']: addressList});
      }
    }
  }

  Future<void> deleteAddress(
      {@required String timestamp, @required String userId}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      List addressList;
      if (snapshot.data[KeyNames['address']] is List) {
        addressList = [...snapshot.data[KeyNames['address']]];
      } else {
        addressList = [];
      }
      addressList
          .removeWhere((item) => item['timestamp'].toString() == timestamp);
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['address']: addressList});
    }
  }

  Future<void> setDefault(
      {@required String timestamp, @required String userId}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      List addressList;
      if (snapshot.data[KeyNames['address']] is List) {
        addressList = [...snapshot.data[KeyNames['address']]];
      } else {
        addressList = [];
      }
      addressList.forEach((item) {
        if (item['timestamp'].toString() == timestamp) {
          item['is_default'] = true;
        } else
          item['is_default'] = false;
      });
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['address']: addressList});
    }
  }

  Future<void> updateUsername(
      {@required String userId, @required String username}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['userName']: username});
    }
  }

  Future<void> updatePoints(
      {@required String userId, @required double points}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['points']: FieldValue.increment(points)});
    }
  }

  Future<void> addAddress(
      {@required String userId, @required Map address}) async {
    DocumentSnapshot snapshot =
        await userRef.collection('entries').document(userId).get();
    if (snapshot.data != null) {
      List addressList;
      if (snapshot.data[KeyNames['address']] is List) {
        addressList = [...snapshot.data[KeyNames['address']]];
      } else {
        addressList = [];
      }
      address['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      addressList.add(address);
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['address']: addressList});
    }
  }

  Future<void> addUser({@required String userId}) async {
    String phoneNumber = await StorageManager.getItem(KeyNames['phone']);
    userRef.collection('entries').document(userId).setData({
      KeyNames['userName']: phoneNumber,
      KeyNames['phone']: phoneNumber,
      KeyNames['address']: [],
      KeyNames['cart']: {},
      KeyNames['points']: 0,
    });
  }

  Future<dynamic> getUser({@required String userId}) async {
    var userData = userRef.collection('entries').document(userId);
    DocumentSnapshot userSnapshot = await userData.get();
    return userSnapshot.data;
  }

  Future<dynamic> addItemToCart(
      {@required Map item, @required String userId}) async {
    DocumentSnapshot userData =
        await userRef.collection('entries').document(userId).get();
    try {
      DocumentSnapshot itemSnapshot = await inventoryRef
          .document(item['category_id'])
          .collection('items')
          .document(item['item_id'])
          .get();
      if (itemSnapshot.data['quantity'] >= item['cartQuantity']) {
        if (userData.data != null) {
          var cart = userData.data['cart'];
          if (cart == null) {
            cart = {};
          }
          cart[item['item_id']] = item;
          await userRef
              .collection('entries')
              .document(userId)
              .updateData({KeyNames['cart']: cart});
          return true;
        }
        return false;
      }
      return {'error': 'ITEM_OUT_OF_STOCK'};
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> removeCartItem(
      {@required String itemId, @required String userId}) async {
    DocumentSnapshot userData =
        await userRef.collection('entries').document(userId).get();
    if (userData.data != null) {
      var cart = userData.data['cart'];
      if (cart == null) {
        cart = {};
      }
      cart.remove(itemId);
      await userRef
          .collection('entries')
          .document(userId)
          .updateData({KeyNames['cart']: cart});
    }
    return false;
  }

  Future<bool> emptyCart({@required String userId}) async {
    try {
      DocumentSnapshot userData =
          await userRef.collection('entries').document(userId).get();
      if (userData.data != null) {
        await userRef
            .collection('entries')
            .document(userId)
            .updateData({KeyNames['cart']: {}});
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
