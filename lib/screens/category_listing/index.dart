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
import 'package:asia/shared_widgets/item_cart.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/quantity_updater.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/shared_widgets/speech_recognition.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  SpeechRecognition _speech;
  String _currentLocale = 'en_US';
  @override
  void initState() {
    checkForPermissions();
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchCategoryListing(categoryId: widget.categoryId));
    _scrollController.addListener(scrollListener);

    super.initState();
  }

  checkForPermissions() async {
    var status = await Permission.microphone.isGranted;
    if (status) {
      activateSpeechRecognizer();
    } else {
      var isPermanentlyDenied = await Permission.microphone.isPermanentlyDenied;
      if (!isPermanentlyDenied) {
        PermissionStatus newStatus = await Permission.microphone.request();
        if (newStatus == PermissionStatus.granted) {
          activateSpeechRecognizer();
        }
      }
    }
  }

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.activate().then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  void start() => _speech.listen(locale: _currentLocale).then((result) {
        setState(() => _isListening = true);
        startListening();
        print('_MyAppState.start => result $result');
      });

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((result) {
        print(result);
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) {
    if (!result) {
      _speech.cancel();
    }
    setState(() => _speechRecognitionAvailable = result);
  }

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(() => _currentLocale = locale);
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) {
    print(text);
  }

  void onRecognitionComplete(text) {
    if (text.length > 0) {
      _textController.text = text;
      _textController.selection =
          TextSelection.fromPosition(TextPosition(offset: text.length));
      searchItems(text);
    }
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    if (_speech != null) _speech.cancel();
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

  startListening() {
    if (_isListening)
      Future.delayed(Duration(seconds: 3), () {
        stop();
      });
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
                                        : _speechRecognitionAvailable
                                            ? InkWell(
                                                onTap: () {
                                                  if (_isListening) {
                                                    stop();
                                                  } else {
                                                    start();
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.mic,
                                                  color: _isListening
                                                      ? ColorShades.greenBg
                                                      : ColorShades.redOrange,
                                                  size: 24,
                                                ),
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
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Spacing.space20,
                          ),
                          if (_isListening) ...[
                            Text(
                              L10n().getStr('app.listening'),
                              style: theme.textTheme.h2
                                  .copyWith(color: ColorShades.greenBg),
                            ),
                            SizedBox(
                              height: Spacing.space20,
                            ),
                          ],
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
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Spacing.space16),
                                    child: GridView.builder(
                                      controller: _scrollController,
                                      itemCount: listing.length,
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 220,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        var item = listing[index].data;
                                        return Center(
                                            child: ItemCard(item: item));
                                      },
                                    ),
                                  )),
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
                          heroTag: 'cartBtn',
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
                    heroTag: 'scrollBtn',
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
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ColorShades.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: item['image_url'] != null
                  ? FadeInImage.assetNetwork(
                      fit: BoxFit.fill,
                      placeholder: 'assets/images/loader.gif',
                      image: item['image_url'],
                      imageErrorBuilder: (context, object, stackTrace) {
                        return Image.asset(
                            'assets/images/not-available.jpeg');
                      })
                  : Image.asset('assets/images/not-available.jpeg'),
            ),
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
                            ...cart[item['item_id'].toString()]
                          };
                          showCustomLoader(context);
                          BlocProvider.of<UserDatabaseBloc>(context)
                              .add(RemoveCartItem(
                                  itemId: currentCartItem['item_id'].toString(),
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
                                user['cart'][item['item_id'].toString()] ==
                                    null)
                              PrimaryButton(
                                text: L10n().getStr('item.add'),
                                onPressed: () {
                                  var currentCartItem = {
                                    'price': item['cost'],
                                    'cartQuantity': 1,
                                    'category_id':
                                        item['category_id'].toString(),
                                    'item_id': item['item_id'].toString()
                                  };
                                  addItemToCart(currentCartItem);
                                },
                              )
                            else
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: Spacing.space12,
                                      top: Spacing.space8),
                                  child: QuantityUpdater(
                                    addHandler: ({int value}) {
                                      Map currentCartItem = {
                                        ...cart[item['item_id'].toString()]
                                      };

                                      currentCartItem['cartQuantity'] = value !=
                                              null
                                          ? value
                                          : currentCartItem['cartQuantity'] + 1;

                                      addItemToCart(currentCartItem);
                                    },
                                    subtractHandler: () {
                                      Map currentCartItem = {
                                        ...cart[item['item_id'].toString()]
                                      };
                                      if (currentCartItem['cartQuantity'] > 1) {
                                        currentCartItem['cartQuantity'] =
                                            currentCartItem['cartQuantity'] - 1;
                                        addItemToCart(currentCartItem);
                                      } else {
                                        showCustomLoader(context);
                                        BlocProvider.of<UserDatabaseBloc>(
                                                context)
                                            .add(RemoveCartItem(
                                                itemId:
                                                    currentCartItem['item_id']
                                                        .toString(),
                                                callback: (result) {
                                                  Navigator.pop(context);
                                                  if (!result) {
                                                    showCustomSnackbar(
                                                        content: L10n().getStr(
                                                            'profile.address.error'),
                                                        context: context,
                                                        type:
                                                            SnackbarType.error);
                                                  } else {
                                                    if (removeItemHandler !=
                                                        null)
                                                      removeItemHandler(
                                                          currentCartItem);
                                                  }
                                                }));
                                      }
                                    },
                                    quantity: user['cart']
                                            [item['item_id'].toString()]
                                        ['cartQuantity'],
                                  ),
                                ),
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
