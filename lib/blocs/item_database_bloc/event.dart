import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:flutter/material.dart';

abstract class ItemDatabaseEvents {}

class FetchAllCategories extends ItemDatabaseEvents {}

class FetchCategoryListing extends ItemDatabaseEvents {
  String categoryId;
  String startAt;
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
