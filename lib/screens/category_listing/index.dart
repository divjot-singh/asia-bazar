import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/quantity_updater.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CategoryListing extends StatefulWidget {
  final String categoryId, categoryName;
  CategoryListing({@required this.categoryId, @required this.categoryName});
  @override
  _CategoryListingState createState() => _CategoryListingState();
}

class _CategoryListingState extends State<CategoryListing> {
  ThemeData theme;
  ScrollController _scrollController = ScrollController();
  bool isFetching = false;
  Debouncer _debouncer = Debouncer();
  var searchQuery = '';
  var scrollHeight = 0;
  TextEditingController _textController = TextEditingController();
  bool showScrollUp = false;
  @override
  void initState() {
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchCategoryListing(categoryId: widget.categoryId));
    _scrollController.addListener(scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _debouncer = null;
    super.dispose();
  }

  scrollListener() {
    setState(() {
      showScrollUp = _scrollController.position.pixels >
          MediaQuery.of(context).size.height;
    });

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true) {
      _fetchMoreItems();
    }
  }

  searchItems(String query) {
    setState(() {
      showScrollUp = false;
    });
    query = query.toLowerCase();
    _debouncer.run(() {
      BlocProvider.of<ItemDatabaseBloc>(context)
          .add(SearchCategoryItem(query: query, categoryId: widget.categoryId));
    });
  }

  _fetchMoreItems() {
    var state =
        BlocProvider.of<ItemDatabaseBloc>(context).state['categoryListing'];
    if (state is CategoryListingFetchedState &&
        state.categoryId == widget.categoryId) {
      var listing = state.categoryItems;
      DocumentSnapshot lastItem = listing[listing.length - 1];
      if (_textController.text.length == 0) {
        BlocProvider.of<ItemDatabaseBloc>(context).add(FetchCategoryListing(
            callback: (listing) {
              setState(() {
                isFetching = false;
              });
              if (listing is List && listing.length == 0) {
                _scrollController.removeListener(scrollListener);
              }
            },
            categoryId: widget.categoryId,
            startAt: lastItem));
        setState(() {
          isFetching = true;
        });
      }
    }
  }

  Future<void> reloadPage() async {
    var route = Constants.CATEGORY_LISTING
        .replaceAll(':categoryId', widget.categoryId)
        .replaceAll(':categoryName', widget.categoryName);
    Navigator.popAndPushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
        var currentState = state['userstate'];
        if (currentState is UserIsUser) {
          var user = currentState.user;
          return Scaffold(
            body: Scaffold(
              backgroundColor: ColorShades.white,
              appBar: MyAppBar(
                hasTransparentBackground: true,
                title: widget.categoryName,
              ),
              body: Container(
                child: BlocBuilder<ItemDatabaseBloc, Map>(
                  builder: (context, state) {
                    var currentState = state['categoryListing'];
                    if (currentState is GlobalFetchingState) {
                      return PageFetchingViewWithLightBg();
                    } else if (currentState is GlobalErrorState) {
                      return PageErrorView();
                    } else if ((currentState is CategoryListingFetchedState ||
                            currentState is PartialFetchingState) &&
                        currentState.categoryId == widget.categoryId) {
                      var listing = currentState.categoryItems;
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: Spacing.space16,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Spacing.space16),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: InputBox(
                                    controller: _textController,
                                    onChanged: (query) {
                                      searchQuery = query;
                                      if (query.length > 2 ||
                                          query.length == 0) {
                                        searchItems(query);
                                      }
                                    },
                                    suffixIcon: _textController.text.length > 0
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: ColorShades.greenBg,
                                            ),
                                            onPressed: () {
                                              searchItems('');
                                              _textController.text = '';
                                            },
                                          )
                                        : null,
                                    hideShadow: true,
                                    hintText: L10n().getStr('category.search',
                                        {'category': widget.categoryName}),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: ColorShades.greenBg,
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: Spacing.space8,
                                // ),
                                //Text(listing.length.toString()),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Spacing.space12,
                          ),
                          if (currentState is PartialFetchingState)
                            Expanded(
                                child: Center(
                                    child: PageFetchingViewWithLightBg()))
                          else if (currentState
                                  is CategoryListingFetchedState &&
                              currentState.categoryItems.length == 0)
                            Expanded(
                                child: SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/no_list.png'),
                                    SizedBox(
                                      height: Spacing.space16,
                                    ),
                                    Text(
                                      L10n().getStr('list.empty'),
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.h4
                                          .copyWith(color: ColorShades.greenBg),
                                    )
                                  ]),
                            ))
                          else
                            Expanded(
                              child: RefreshIndicator(
                                color: ColorShades.greenBg,
                                backgroundColor: ColorShades.smokeWhite,
                                onRefresh: reloadPage,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: listing.length,
                                  itemBuilder: (context, index) {
                                    var item = listing[index].data;
                                    return listItem(
                                        context: context,
                                        item: item,
                                        user: user);
                                  },
                                ),
                              ),
                            ),
                          SizedBox(
                            height: Spacing.space8,
                          ),
                          if (isFetching &&
                              currentState is CategoryListingFetchedState)
                            Padding(
                              padding: EdgeInsets.only(bottom: Spacing.space12),
                              child: ScalingText(L10n().getStr('app.loading'),
                                  style: theme.textTheme.h3
                                      .copyWith(color: ColorShades.greenBg)),
                            ),
                        ],
                      );
                    }
                    return Container();
                  },
                ),
              ),
              floatingActionButton:
                  user['cart'] != null && user['cart'].length > 0
                      ? FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.pushNamed(context, Constants.CART);
                          },
                          backgroundColor: ColorShades.greenBg,
                          icon: Icon(
                            Icons.shopping_cart,
                            color: ColorShades.white,
                          ),
                          label: Text(L10n().getStr('listing.goToCart'),
                              style: theme.textTheme.body1Medium.copyWith(
                                color: ColorShades.white,
                              )))
                      : null,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: showScrollUp
                ? FloatingActionButton(
                    onPressed: () {
                      _scrollController.animateTo(0,
                          duration: Duration(
                            seconds: 1,
                          ),
                          curve: Curves.bounceOut);
                    },
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 24,
                      color: ColorShades.greenBg,
                    ),
                  )
                : null,
          );
        }
        return Container();
      }),
    );
  }
}

Widget listItem(
    {@required BuildContext context,
    @required Map item,
    @required Map user,
    Function removeItemHandler,
    bool cartItem = false}) {
  ThemeData theme = Theme.of(context);
  if (item['cost'] == null ||
      item['cost'] is String && item['cost'].trim().length == 0) {
    item['cost'] = 0;
  }

  addItemToCart(cartItem) {
    showCustomLoader(context);
    BlocProvider.of<UserDatabaseBloc>(context).add(AddItemToCart(
        item: cartItem,
        callback: (result) {
          Navigator.pop(context);
          if (result is Map && result['error'] != null || result == false) {
            var errorMessage = result is Map && result['error'] != null
                ? 'error.' + result['error']
                : 'profile.address.error';
            showCustomSnackbar(
                content: L10n().getStr(errorMessage),
                context: context,
                type: SnackbarType.error);
          }
        }));
  }

  showPickerNumber(BuildContext context, {@required Map cartItem}) {
    cartItem = {...cartItem};
    var initValue = cartItem['cartQuantity'];
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
            begin: 1,
            initValue: initValue,
            end: 50,
          ),
        ]),
        hideHeader: true,
        title: Text(L10n().getStr('item.selectQuantity')),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          cartItem['cartQuantity'] = value[0] + 1;
          addItemToCart(cartItem);
        }).showDialog(context);
  }

  var cart = user['cart'];
  var cost = item['cost'] is String
      ? double.parse(item['cost'])
      : item['cost'].toDouble();
  bool outOfStock = item['quantity'] < 1;
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: Spacing.space16, vertical: Spacing.space4),
    child: Container(
      margin: EdgeInsets.only(
        bottom: Spacing.space8,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space12),
      decoration: BoxDecoration(
        color: ColorShades.white,
        boxShadow: !cartItem ? [Shadows.cardLight] : null,
        border: cartItem
            ? Border(bottom: BorderSide(color: ColorShades.grey200))
            : null,
        borderRadius: !cartItem ? BorderRadius.circular(10) : null,
      ),
      child: Row(
        children: <Widget>[
          Image.network(
            item['image_url'] != null
                ? item['image_url']
                : 'https://dummyimage.com/600x400/ffffff/000000.png&text=Image+not+available',
            height: 100,
            width: 100,
          ),
          SizedBox(
            width: Spacing.space12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item['description'],
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.bastille),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (outOfStock && cartItem)
                      GestureDetector(
                        onTap: () {
                          Map currentCartItem = {
                            ...cart[item['opc'].toString()]
                          };
                          showCustomLoader(context);
                          BlocProvider.of<UserDatabaseBloc>(context)
                              .add(RemoveCartItem(
                                  itemId: currentCartItem['opc'].toString(),
                                  callback: (result) {
                                    Navigator.pop(context);
                                    if (!result) {
                                      showCustomSnackbar(
                                          content: L10n()
                                              .getStr('profile.address.error'),
                                          context: context,
                                          type: SnackbarType.error);
                                    } else {
                                      if (removeItemHandler != null)
                                        removeItemHandler(currentCartItem);
                                    }
                                  }));
                        },
                        child: Icon(
                          Icons.delete,
                          color: ColorShades.redOrange,
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: Spacing.space4,
                ),
                Text(
                  item['dept_name'],
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.grey300),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: Spacing.space4,
                ),
                if (outOfStock)
                  Padding(
                    padding: EdgeInsets.only(top: Spacing.space8),
                    child: Text(
                      L10n().getStr('item.outOfStock'),
                      style: theme.textTheme.body1Regular.copyWith(
                          color: ColorShades.red, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Row(
                    children: <Widget>[
                      if (cartItem)
                        Text(
                          '  \$ ' +
                              ((cost * item['cartQuantity'] * 100).ceil() / 100)
                                  .toString(),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (!cartItem && item['normal_price'] != null)
                        Text(
                          '\$ ' + item['normal_price'].toString(),
                          style: theme.textTheme.body1Regular.copyWith(
                              color: ColorShades.grey300,
                              decoration: TextDecoration.lineThrough),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(
                        width: Spacing.space4,
                      ),
                      if (!cartItem)
                        Text(
                          '  \$ ' + cost.toString(),
                          style: theme.textTheme.body1Regular.copyWith(
                            color: ColorShades.grey300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            if (user['cart'] == null ||
                                user['cart'][item['opc'].toString()] == null)
                              PrimaryButton(
                                text: L10n().getStr('item.add'),
                                onPressed: () {
                                  var currentCartItem = {
                                    'price': item['cost'],
                                    'cartQuantity': 1,
                                    'categoryId': item['categoryId'].toString(),
                                    'opc': item['opc'].toString()
                                  };
                                  addItemToCart(currentCartItem);
                                },
                              )
                            else
                              QuantityUpdater(
                                addHandler: ({int value}) {
                                  Map currentCartItem = {
                                    ...cart[item['opc'].toString()]
                                  };

                                  currentCartItem['cartQuantity'] =
                                      value != null
                                          ? value
                                          : currentCartItem['cartQuantity'] + 1;

                                  addItemToCart(currentCartItem);
                                },
                                subtractHandler: () {
                                  Map currentCartItem = {
                                    ...cart[item['opc'].toString()]
                                  };
                                  if (currentCartItem['cartQuantity'] > 1) {
                                    currentCartItem['cartQuantity'] =
                                        currentCartItem['cartQuantity'] - 1;
                                    addItemToCart(currentCartItem);
                                  } else {
                                    showCustomLoader(context);
                                    BlocProvider.of<UserDatabaseBloc>(context)
                                        .add(RemoveCartItem(
                                            itemId: currentCartItem['opc']
                                                .toString(),
                                            callback: (result) {
                                              Navigator.pop(context);
                                              if (!result) {
                                                showCustomSnackbar(
                                                    content: L10n().getStr(
                                                        'profile.address.error'),
                                                    context: context,
                                                    type: SnackbarType.error);
                                              } else {
                                                if (removeItemHandler != null)
                                                  removeItemHandler(
                                                      currentCartItem);
                                              }
                                            }));
                                  }
                                },
                                quantity: user['cart'][item['opc'].toString()]
                                    ['cartQuantity'],
                              ),
                          ],
                        ),
                      )
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
