import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ItemDatabase {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference categoryRef = _firestore.collection('categories');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference activeOrdersRef =
      _firestore.collection('active_orders');
  Future<List> fetchAllCategories() async {
    QuerySnapshot snapshot = await categoryRef.getDocuments();
    return snapshot.documents;
  }

  Future<List> fetchCategoryListing(
      {@required String categoryId, @required DocumentSnapshot startAt}) async {
    var limit = 50;
    QuerySnapshot snapshot;
    var returnValue;
    if (startAt == null) {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('opc')
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
    } else {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('opc')
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
          .orderBy('opc')
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
    } else {
      snapshot = await inventoryRef
          .document(categoryId)
          .collection('items')
          .orderBy('opc')
          .where('tokens', arrayContains: query)
          .limit(limit)
          .getDocuments();
      returnValue = snapshot.documents;
      returnValue = snapshot.documents == null ? {} : snapshot.documents;
    }

    if (returnValue != null) return [...returnValue];
    return null;
  }

  Future<dynamic> placeOrder(
      {@required Map details,
      @required String userId,
      @required Function callback}) async {
    var returnItem = {};
    var transactionWriteArray = [];
    try {
      var cart = details['cart'];
      var lastKey = cart.keys.toList()[cart.length - 1];
      _firestore.runTransaction((transaction) {
        cart.forEach((key, item) {
          var ref = inventoryRef
              .document(item['categoryId'])
              .collection('items')
              .document(key);
          return transaction.get(ref).then((snapshot) {
            var itemData = snapshot.data;
            var quantity = itemData['quantity'];
            if (quantity >= item['cartQuantity']) {
              quantity -= item['cartQuantity'];
              transactionWriteArray.add({
                'ref': ref,
                'data': {'quantity': quantity}
              });
            } else {
              returnItem[itemData['opc']] = itemData;
            }
            if (key == lastKey) {
              transactionWriteArray.forEach((item) async {
                await transaction.update(item['ref'], item['data']);
              });
            }
          }, onError: (e) {
            print('reading error');
            print(ref);
            print(e);
          });
        });
      }, timeout: Duration(seconds: 15)).then((value) async {
        DocumentReference ref = await orderRef.add(details);
        await activeOrdersRef
            .add({'orderId': ref.documentID, 'userId': details['userId']});
        callback(true);
        return;
      }, onError: (e, stack) {
        print('transaction failed');
        print(e);
        print(stack);
        print('returning');
        callback(returnItem);
        return;
      });
    } catch (e) {
      //error in try catch block
      print(e.toString());
      print('error in try catch');
      callback(returnItem);
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
            .document(value['categoryId'])
            .collection('items')
            .document(value['opc'])
            .get();
        items[key] = snapshot.data;
      }
      return items;
    } catch (e) {
      return null;
    }
  }
}
