import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDatabaseRepo {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference orderedItems = _firestore.collection('orderItems');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  Future<dynamic> fetchOrderDetails(
      {@required String orderId,
      @required String userId,
      bool addListener = true}) async {
    var returnValue;
    try {
      DocumentSnapshot snapshot = await orderRef.doc(orderId).get();

      returnValue = snapshot.data;
      if (addListener) {
        Stream<DocumentSnapshot> snapshotStream =
            orderRef.doc(orderId).snapshots();
        returnValue = snapshotStream;
      }
      return returnValue;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchOrderItems({@required String orderId}) async {
    try {
      QuerySnapshot snapshot =
          await orderedItems.where('orderId', isEqualTo: orderId).get();
      List items = await fetchItemsFromOrder(snapshot: snapshot);
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchItemsFromOrder({@required QuerySnapshot snapshot}) async {
    List<Map<String, dynamic>> items = [];
    for (var document in snapshot.docs) {
      DocumentSnapshot itemData = document.data();
      var itemdoc = itemData['itemDetails'];
      DocumentSnapshot itemSnapshot = await inventoryRef
          .doc(itemdoc['category_id'].toString())
          .collection('items')
          .doc(itemdoc['item_id'].toString())
          .get();
      items.add({'orderData': document, 'itemData': itemSnapshot});
    }
    return items;
  }
}
