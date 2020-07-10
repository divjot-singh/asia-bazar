import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SearchItems extends StatefulWidget {
  @override
  _SearchItemsState createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  ThemeData theme;
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();
  var scrollHeight = 0;
  bool showScrollUp = false;
  bool isFetching = false;
  Debouncer _debouncer = Debouncer();
  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    searchItems('');
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

  _fetchMoreItems() {
    var state =
        BlocProvider.of<ItemDatabaseBloc>(context).state['searchListing'];
    if (state is SearchListingFetched) {
      var listing = state.searchItems;
      DocumentSnapshot lastItem = listing[listing.length - 1];
      BlocProvider.of<ItemDatabaseBloc>(context).add(SearchAllItems(
          query: _textController.text,
          callback: (listing) {
            setState(() {
              isFetching = false;
            });
            if (listing is List && listing.length == 0) {
              _scrollController.removeListener(scrollListener);
            }
          },
          startAt: lastItem));
      setState(() {
        isFetching = true;
      });
    }
  }

  void searchItems(query) {
    setState(() {
      showScrollUp = false;
    });
    query = query.toLowerCase();
    _debouncer.run(() {
      BlocProvider.of<ItemDatabaseBloc>(context)
          .add(SearchAllItems(query: query));
    });
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
            body: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(boxShadow: [Shadows.cardLight]),
                  child: TextFormField(
                    controller: _textController,
                    style: theme.textTheme.h4.copyWith(
                        color: ColorShades.bastille,
                        fontWeight: FontWeight.normal),
                    onChanged: (query) {
                      setState(() {});
                      if (query.length > 2) searchItems(query);
                    },
                    decoration: InputDecoration(
                        hintText: L10n().getStr('app.search'),
                        hintStyle: theme.textTheme.h4
                            .copyWith(color: theme.colorScheme.disabled),
                        fillColor: ColorShades.white,
                        filled: true,
                        prefixIcon: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            size: 32,
                            color: ColorShades.greenBg,
                          ),
                        ),
                        suffixIcon: _textController.text.length > 0
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: ColorShades.greenBg,
                                ),
                                onPressed: () {
                                  _textController.text = '';
                                },
                              )
                            : null,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Spacing.space32,
                            vertical: Spacing.space20)),
                  ),
                ),
                SizedBox(
                  height: Spacing.space16,
                ),
                BlocBuilder<ItemDatabaseBloc, Map>(builder: (context, state) {
                  var currentState = state['searchListing'];
                  if (currentState is GlobalFetchingState) {
                    return Padding(
                        padding: EdgeInsets.only(top: Spacing.space20),
                        child: PageFetchingViewWithLightBg());
                  } else if (currentState is GlobalErrorState) {
                    return PageErrorView();
                  } else if (currentState is PartialFetchingState ||
                      currentState is SearchListingFetched) {
                    var listing = currentState is PartialFetchingState
                        ? currentState.categoryItems
                        : currentState.searchItems;
                    return Expanded(
                      child: Column(
                        children: <Widget>[
                          if (currentState is PartialFetchingState)
                            Expanded(
                                child: Center(
                                    child: PageFetchingViewWithLightBg()))
                          else if (currentState is SearchListingFetched &&
                              currentState.searchItems.length == 0)
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
                                  var item = listing[index].data;
                                  return listItem(
                                      context: context, item: item, user: user);
                                },
                              ),
                            ),
                          SizedBox(
                            height: Spacing.space8,
                          ),
                          if (isFetching &&
                              currentState is SearchListingFetched)
                            Padding(
                              padding: EdgeInsets.only(bottom: Spacing.space12),
                              child: ScalingText(L10n().getStr('app.loading'),
                                  style: theme.textTheme.h3
                                      .copyWith(color: ColorShades.greenBg)),
                            ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }),
              ],
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
