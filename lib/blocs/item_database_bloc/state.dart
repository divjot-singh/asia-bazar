import 'package:flutter/material.dart';

abstract class ItemDatabaseState {
  static Map itemState = {
    'categoryListing': ItemUninitialisedState(),
    'allCategories': ItemUninitialisedState(),
    'searchListing': ItemUninitialisedState(),
    'itemDetails': ItemUninitialisedState(),
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
  PartialFetchingState(
      {@required this.categoryItems, @required this.categoryId});
}
