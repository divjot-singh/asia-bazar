import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/models/user.dart';
import 'package:asia/repository/user_database.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/deboucer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

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
  bool showScrollUp = false;
  @override
  void initState() {
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchCategoryListing(categoryId: widget.categoryId));
    _scrollController.addListener(scrollListener);

    super.initState();
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
    _debouncer.run(() {
      print('here');
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
      var lastKey = listing.keys.toList()[listing.length - 1];
      if (searchQuery.length == 0) {
        BlocProvider.of<ItemDatabaseBloc>(context).add(FetchCategoryListing(
            callback: (listing) {
              setState(() {
                isFetching = false;
              });
              if (listing == null) {
                _scrollController.removeListener(scrollListener);
              }
            },
            categoryId: widget.categoryId,
            startAt: lastKey));
        setState(() {
          isFetching = true;
        });
      }
    }
  }

  Widget listItem({@required Map item, @required Map user}) {
    var cart = user['cart'];
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
          boxShadow: [Shadows.cardLight],
          borderRadius: BorderRadius.circular(10),
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
                  Text(
                    item['description'],
                    style: theme.textTheme.h4
                        .copyWith(color: ColorShades.bastille),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  Row(
                    children: <Widget>[
                      if (item['normal_price'] != null)
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
                      Text(
                        '  \$ ' + item['cost'].toString(),
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
                                  var cartItem = item;
                                  cartItem['quantity'] = 1;
                                  showCustomLoader(context);
                                  BlocProvider.of<UserDatabaseBloc>(context)
                                      .add(AddItemToCart(
                                          item: cartItem,
                                          callback: (_) {
                                            Navigator.pop(context);
                                          }));
                                },
                              )
                            else
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () {
                                        showCustomLoader(context);
                                        var cartItem =
                                            cart[item['opc'].toString()];
                                        if (cartItem['quantity'] > 1) {
                                          cartItem['quantity'] =
                                              cartItem['quantity'] - 1;
                                          BlocProvider.of<UserDatabaseBloc>(
                                                  context)
                                              .add(AddItemToCart(
                                                  item: cartItem,
                                                  callback: (_) {
                                                    Navigator.pop(context);
                                                  }));
                                        } else {
                                          BlocProvider.of<UserDatabaseBloc>(
                                                  context)
                                              .add(RemoveCartItem(
                                                  itemId: cartItem['opc']
                                                      .toString(),
                                                  callback: (_) {
                                                    Navigator.pop(context);
                                                  }));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ColorShades
                                                    .pinkBackground)),
                                        child: Icon(
                                          Icons.remove,
                                          color: ColorShades.pinkBackground,
                                          size: 20,
                                        ),
                                      )),
                                  Container(
                                    height: 24,
                                    width: 24,
                                    child: Center(
                                      child: Text(
                                        user['cart'][item['opc'].toString()]
                                                ['quantity']
                                            .toString(),
                                        style: theme.textTheme.h4.copyWith(
                                            color: ColorShades.bastille),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        var cartItem =
                                            cart[item['opc'].toString()];
                                        cartItem['quantity'] =
                                            cartItem['quantity'] + 1;
                                        showCustomLoader(context);
                                        BlocProvider.of<UserDatabaseBloc>(
                                                context)
                                            .add(AddItemToCart(
                                                item: cartItem,
                                                callback: (_) {
                                                  Navigator.pop(context);
                                                }));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ColorShades.greenBg)),
                                        child: Icon(
                                          Icons.add,
                                          color: ColorShades.greenBg,
                                          size: 20,
                                        ),
                                      )),
                                ],
                              )
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

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
        var currentState = state['userstate'];
        if (currentState is UserIsUser) {
          var user = currentState.user;
          return Scaffold(
            backgroundColor: ColorShades.white,
            appBar: MyAppBar(
              hasTransparentBackground: true,
              title: widget.categoryName,
              rightAction: user['cart'] != null
                  ? {
                      'icon': Icon(Icons.shopping_cart),
                      'onTap': () {
                        Navigator.pushNamed(context, Constants.CART);
                      }
                    }
                  : null,
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
                          padding:
                              EdgeInsets.symmetric(horizontal: Spacing.space16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: InputBox(
                                  onChanged: (query) {
                                    if (query.length > 3 || query.length == 0) {
                                      searchQuery = query;
                                      searchItems(query);
                                    }
                                  },
                                  hideShadow: true,
                                  hintText: L10n().getStr('category.search',
                                      {'category': widget.categoryName}),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: ColorShades.greenBg,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Spacing.space8,
                              ),
                              Text(listing.length.toString()),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        if (currentState is PartialFetchingState)
                          Expanded(
                              child:
                                  Center(child: PageFetchingViewWithLightBg()))
                        else if (currentState is CategoryListingFetchedState &&
                            currentState.categoryItems.keys.length == 0)
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
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: listing.length,
                              itemBuilder: (context, index) {
                                var key = listing.keys.toList()[index];
                                var item = listing[key];
                                return listItem(item: item, user: user);
                              },
                            ),
                          ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        if (isFetching &&
                            currentState is CategoryListingFetchedState)
                          PageFetchingViewWithLightBg(),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
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
