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
      {@required Map details, @required String userId}) async {
    var returnItem = {};
    try {
      var cart = details['cart'];
      var transactionWrites = [];
      var transactionResult =
          await _firestore.runTransaction((transaction) async {
        var cartKeys = cart.keys.toList();

        for (var i = 0; i < cart.length; i++) {
          var key = cartKeys[i];
          var item = cart[key];
          var deptName = item['dept_name'];
          DocumentSnapshot itemDocument = await transaction.get(inventoryRef
              .document(deptName)
              .collection('items')
              .document(key));
          var itemData = itemDocument.data;
          var quantity = itemData['quantity'];
          if (quantity >= item['cartQuantity']) {
            quantity -= item['cartQuantity'];
            transactionWrites.add({
              'ref': inventoryRef
                  .document(deptName)
                  .collection('items')
                  .document(key),
              'data': {'quantity': quantity}
            });
          } else {
            returnItem[itemData['opc']] = itemData;
          }
        }
        if (returnItem == null && transactionWrites.length == cart.length) {
          transactionWrites.forEach((item) async {
            await transaction.update(item['ref'], item['data']);
          });
        } else {
          return returnItem;
        }
      });
      if (transactionResult == null) {
        DocumentReference ref = await orderRef.add(details);
        await activeOrdersRef
            .add({'orderId': ref.documentID, 'userId': details['userId']});
        return true;
      } else {
        return transactionResult;
      }
    } catch (e) {
      return returnItem;
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
