import 'package:asia/utils/network_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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

  Future<void> placeOrder(
      {@required Map details, @required String userId}) async {
    try {
      var cart = details['cart'];
      cart.forEach((key, item) {
        var deptName = item['dept_name'];
        _firestore.runTransaction((transaction) async {
          DocumentSnapshot itemDocument = await inventoryRef
              .document(deptName)
              .collection('items')
              .document(key)
              .get();
          var itemData = itemDocument.data;
          var quantity = itemData['quantity'];
          if (quantity >= item['cartQuantity']) {
            quantity -= item['cartQuantity'];
          }
          itemData['quantity'] = quantity;
          await inventoryRef
              .document(deptName)
              .collection('items')
              .document(key)
              .setData({'quantity': quantity}, merge: true);
        });
      });

      DocumentReference ref = await orderRef.add(details);
      await activeOrdersRef
          .add({'orderId': ref.documentID, 'userId': details['userId']});
      return true;
    } catch (e) {
      return false;
    }
  }
}
