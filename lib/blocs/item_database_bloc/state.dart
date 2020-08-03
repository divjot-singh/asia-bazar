import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class ItemDatabaseState {
  static Map itemState = {
    'categoryListing': ItemUninitialisedState(),
    'allCategories': ItemUninitialisedState(),
    'searchListing': ItemUninitialisedState(),
    'itemDetails': ItemUninitialisedState(),
    'homeItems': ItemUninitialisedState(),
  };
}

class ItemUninitialisedState extends ItemDatabaseState {}

class AllCategoriesFetchedState {
  List categories;
  AllCategoriesFetchedState({@required this.categories});
}

class CategoryListingFetchedState {
  List categoryItems;
  String categoryId;
  CategoryListingFetchedState(
      {@required this.categoryItems, @required this.categoryId});
}

class SearchListingFetched {
  List searchItems;
  SearchListingFetched({@required this.searchItems});
}

class ItemDetailsFetchedState {
  Map itemDetails;
  String itemId;
  ItemDetailsFetchedState({@required this.itemId, @required this.itemDetails});
}

class PartialFetchingState {
  List categoryItems;
  String categoryId;
  PartialFetchingState({@required this.categoryItems, this.categoryId});
}

class HomeItemsFetched {
  Map data;
  String lastItem;
  HomeItemsFetched({@required this.data, this.lastItem});
}
