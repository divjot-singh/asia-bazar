import 'package:asia/repository/user_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ItemDatabase {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference categoryRef = _firestore.collection('categories');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference orderedItems = _firestore.collection('orderItems');
  static UserDatabase userDabase = UserDatabase();
  Future<List> fetchAllCategories() async {
    QuerySnapshot snapshot = await categoryRef.getDocuments();
    return snapshot.documents;
  }

  Future<List> fetchCategoryListing(
      {@required String categoryId,
      @required DocumentSnapshot startAt,
      int limit = 50}) async {
    QuerySnapshot snapshot;
    var returnValue;
    if (startAt == null) {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('quantity')
          .where('quantity', isGreaterThan: 0)
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
    } else {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('quantity')
          .where('quantity', isGreaterThan: 0)
          .startAfterDocument(startAt)
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents == null ? {} : snapshot.documents;
    }

    if (returnValue != null) return [...returnValue];
    return null;
  }

  Future<List> searchCategoryListing(
      {@required String categoryId,
      @required String startAt,
      String query}) async {
    QuerySnapshot snapshot;
    var limit = 50;
    var returnValue;
    if (query.length == 0) {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('item_id')
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
    } else {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('item_id')
          .where('tokens', arrayContains: query)
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
      returnValue = snapshot.documents == null ? {} : snapshot.documents;
    }

    if (returnValue != null) return [...returnValue];
    return null;
  }

  Future<List> searchAllListing(
      {DocumentSnapshot startAt, String query}) async {
    QuerySnapshot snapshot;
    var limit = 50;
    var returnValue;
    if (query.length > 0) {
      if (startAt != null) {
        snapshot = await _firestore
            .collectionGroup('items')
            .orderBy('item_id')
            .where('tokens', arrayContains: query)
            .limit(limit)
            .startAfterDocument(startAt)
            .getDocuments();
      } else {
        snapshot = await _firestore
            .collectionGroup('items')
            .orderBy('item_id')
            .where('tokens', arrayContains: query)
            .limit(limit)
            .getDocuments();
      }
      returnValue = snapshot.documents;
      returnValue = snapshot.documents == null ? {} : snapshot.documents;
      if (returnValue != null) return [...returnValue];
      return null;
    }
    return [];
  }

  Future<dynamic> placeOrder(
      {@required Map details,
      @required String userId,
      @required Function callback}) async {
    var returnItem = {};
    //var transactionWriteArray = [];
    try {
      var cart = details['cart'];
      //var lastKey = cart.keys.toList()[cart.length - 1];
      WriteBatch batchWrite = _firestore.batch();
      //var successful = true;
      cart.forEach((key, item) async {
        var decrementValue = item['cartQuantity'];
        decrementValue *= -1;
        var ref = inventoryRef
            .document(item['category_id'])
            .collection('items')
            .document(key);
        try {
          print('wiriting' + ref.path.toString());
          batchWrite.updateData(
              ref, {'quantity': FieldValue.increment(decrementValue)});
        } catch (e) {
          print('update error');
          print(e);
        }
      });

      batchWrite.commit().then((value) async {
        var itemsOrdered = details['cart'].keys.toList();
        Map cart = {...details['cart']};
        details.remove('cart');
        details['cartItems'] = itemsOrdered;
        var orderId = details['orderId'];
        details['timestamp'] = Timestamp.fromDate(DateTime.now().toUtc());
        await orderRef.document(orderId).setData(details);
        cart.forEach((key, item) async {
          await orderedItems.add(
              {'itemDetails': item, 'orderId': orderId, 'orderRef': orderId});
        });
        if (details['areLoyaltyPointsUsed'] == true &&
            details['pointsUsed'] != null &&
            details['pointsUsed'] > 0) {
          userDabase.updatePoints(
              userId: userId, points: -details['pointsUsed']);
        }
        //userDabase.updatePoints(userId: userId, points: details['points']);
        callback(true);
        return;
      }, onError: (error) {
        print(error.toString());
        print('error in try catch');
        callback(returnItem);
        return;
      });
    } catch (e) {
      //error in try catch block
      print(e.toString());
      print('error in try catch 2');
      callback(false);
      return;
    }
  }

  Future<Map> fetchCartItems({@required Map cartKeys}) async {
    Map items = {};
    try {
      for (var i = 0; i < cartKeys.length; i++) {
        var key = cartKeys.keys.toList()[i];
        var value = cartKeys[key];
        var snapshot = await inventoryRef
            .document(value['category_id'])
            .collection('items')
            .document(value['item_id'])
            .get();
        items[key] = snapshot.data;
      }
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchMyOrders(
      {@required String userId, DocumentSnapshot startAt}) async {
    try {
      var limit = 50;
      QuerySnapshot snapshot;
      var returnValue;
      if (startAt == null) {
        snapshot = await orderRef
            .orderBy('timestamp', descending: true)
            .where('userId', isEqualTo: userId)
            .limit(limit)
            .getDocuments();
        returnValue = snapshot.documents;
      } else {
        snapshot = await orderRef
            .orderBy('timestamp', descending: true)
            .where('userId', isEqualTo: userId)
            .startAfterDocument(startAt)
            .limit(limit)
            .getDocuments();
        returnValue = snapshot.documents == null ? {} : snapshot.documents;
      }

      if (returnValue != null) return [...returnValue];
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> fetchHomeItems({List categories}) async {
    if (categories.length == 0)
      return {
        'data': [],
      };
    var itemLimit = 5;
    Map data = {};
    try {
      for (var i = 0; i < categories.length; i++) {
        var categoryId = categories[i].data;
        QuerySnapshot itemData = await inventoryRef
            .document(categoryId['id'].toString())
            .collection('items')
            .orderBy('quantity')
            .where('quantity', isGreaterThan: 0)
            .limit(itemLimit)
            .getDocuments();
        data[categoryId['name'].toString()] = itemData.documents;
      }

      return {
        'lastItem': categories[categories.length - 1].data['id'],
        'data': data
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map> fetchItemFromBarcode(String code) async {
    try {
      QuerySnapshot itemData = await _firestore
          .collectionGroup('items')
          .orderBy('item_id')
          .where('bar_codes', arrayContains: code)
          .limit(1)
          .getDocuments();
      if (itemData.documents.length > 0) {
        return itemData.documents[0].data;
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
