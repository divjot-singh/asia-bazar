import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class ItemDatabaseEvents {}

class FetchAllCategories extends ItemDatabaseEvents {}

class FetchCategoryListing extends ItemDatabaseEvents {
  String categoryId;
  DocumentSnapshot startAt;
  Function callback;
  FetchCategoryListing(
      {@required this.categoryId, this.startAt, this.callback});
}

class SearchAllItems extends ItemDatabaseEvents {
  String query;
  int startAt;
  Function callback;
  SearchAllItems({@required this.query, this.startAt, this.callback});
}

class SearchCategoryItem extends ItemDatabaseEvents {
  String query, categoryId;
  String startAt;
  Function callback;
  SearchCategoryItem(
      {@required this.query,
      @required this.categoryId,
      this.startAt,
      this.callback});
}

class GetItemDetails extends ItemDatabaseEvents {
  String itemId, categoryId;
  GetItemDetails({@required this.itemId, this.categoryId});
}

class PlaceOrder extends ItemDatabaseEvents {
  Map orderDetails;
  Function callback;
  PlaceOrder({@required this.orderDetails, this.callback});
}

