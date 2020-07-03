import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/repository/item_database.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemDatabaseBloc extends Bloc<ItemDatabaseEvents, Map> {
  @override
  Map get initialState => UserDatabaseState.userstate;
  ItemDatabase itemDatabase = ItemDatabase();

  @override
  Stream<Map> mapEventToState(ItemDatabaseEvents event) async* {
    if (event is FetchAllCategories) {
      state['allCategories'] = GlobalFetchingState();
      yield {...state};
      try {
        var listing = await itemDatabase.fetchAllCategories();
        if (listing != null) {
          var allCategoryState = AllCategoriesFetchedState(categories: listing);
          state['allCategories'] = allCategoryState;
          yield {...state};
        } else {
          state['allCategories'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        state['allCategories'] = GlobalErrorState();
        yield {...state};
      }
    }
    if (event is FetchCategoryListing) {
      if (event.startAt == null) {
        state['categoryListing'] = GlobalFetchingState();
        yield {...state};
      }
      try {
        var listing = await itemDatabase.fetchCategoryListing(
            categoryId: event.categoryId, startAt: event.startAt);

        if (listing != null) {
          if (event.callback != null) {
            event.callback(listing);
          }
          var categoryListingState;
          var currentCategoryId = event.categoryId;
          if (event.startAt != null &&
              state['categoryListing'] is CategoryListingFetchedState &&
              state['categoryListing'].categoryId == currentCategoryId) {
            var newList = [];
            var oldListing = state['categoryListing'].categoryItems;
            newList.addAll(oldListing);
            newList.addAll(listing);
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: newList);
          } else {
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: listing);
          }
          state['categoryListing'] = categoryListingState;
          yield {...state};
        } else {
          state['categoryListing'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['categoryListing'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is SearchCategoryItem) {
      if (event.startAt == null) {
        var currentState = state['categoryListing'];
        if (currentState is CategoryListingFetchedState)
          state['categoryListing'] = PartialFetchingState(
              categoryId: currentState.categoryId,
              categoryItems: currentState.categoryItems);
        else
          state['categoryListing'] = GlobalFetchingState();
        yield {...state};
      }
      try {
        var listing = await itemDatabase.searchCategoryListing(
            categoryId: event.categoryId,
            startAt: event.startAt,
            query: event.query);

        if (listing != null) {
          if (event.callback != null) {
            event.callback(listing);
          }
          var categoryListingState;
          var currentCategoryId = event.categoryId;
          if (event.startAt != null &&
              state['categoryListing'] is CategoryListingFetchedState &&
              state['categoryListing'].categoryId == currentCategoryId) {
            var newList = [];
            var oldListing = state['categoryListing'].categoryItems;
            newList.addAll(oldListing);
            newList.addAll(listing);
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: newList);
          } else {
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: listing);
          }
          state['categoryListing'] = categoryListingState;
          yield {...state};
        } else {
          state['categoryListing'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['categoryListing'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is PlaceOrder) {
      var details = event.orderDetails;
      var userId = await StorageManager.getItem(KeyNames['userId']);
      var status = await itemDatabase.placeOrder(details: details, userId:userId);
    } 
  } 
}
