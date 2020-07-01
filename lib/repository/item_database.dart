import 'package:asia/utils/network_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class ItemDatabase {
  static DatabaseReference database = FirebaseDatabase.instance.reference();
  static DatabaseReference categoryRef = database.child('categories');
  static DatabaseReference inventoryRef = database.child('inventory');
  Future<List> fetchAllCategories() async {
    DataSnapshot snapshot = await categoryRef.once();
    return snapshot.value;
  }

  Future<Map> fetchCategoryListing(
      {@required String categoryId, @required String startAt}) async {
    var limit = 50;
    DataSnapshot snapshot;
    var returnValue;
    if (startAt == null) {
      snapshot = await inventoryRef
          .child(categoryId)
          .orderByKey()
          .limitToFirst(limit)
          .once();
      returnValue = snapshot.value;
    } else {
      snapshot = await inventoryRef
          .child(categoryId)
          .orderByKey()
          .startAt(startAt.toString())
          .limitToFirst(limit + 1)
          .once();
      returnValue = snapshot.value == null ? {} : snapshot.value;
      if (returnValue[startAt] != null) {
        returnValue.remove(startAt);
      }
    }

    if (returnValue != null) return {...returnValue};
    return null;
  }

  Future<Map> searchCategoryListing(
      {@required String categoryId,
      @required String startAt,
      String query}) async {
    DataSnapshot snapshot;
    var limit = 50;
    var returnValue;
    if (query.length == 0) {
      snapshot = await inventoryRef
          .child(categoryId)
          .orderByKey()
          .limitToFirst(limit)
          .once();
      returnValue = snapshot.value;
    } else {
      snapshot = await inventoryRef
          .child(categoryId)
          .orderByChild('description')
          .startAt(query)
          .endAt(query + "\uf8ff")
          .once();
      returnValue = snapshot.value == null ? {} : snapshot.value;
    }

    if (returnValue != null) return {...returnValue};
    return null;
  }

  Future<Map> searchCategoryListingApi(
      {@required String categoryId,
      @required String startAt,
      String query}) async {
    var response = await NetworkManager.get(
        url:
            'https://us-central1-asia-bazar-app.cloudfunctions.net/asiaBazarCloudApis/searchCategoryListing',
        isAbsoluteUrl: true,
        data: {'categoryId': categoryId});
    print(response);
    return response;
  }
}
