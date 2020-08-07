import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/item_database_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/shared_widgets/item_cart.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/speech_recognition.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SearchItems extends StatefulWidget {
  final bool listening;
  SearchItems({this.listening = false});
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
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  SpeechRecognition _speech;
  String _currentLocale = 'en_US';
  Debouncer _debouncer = Debouncer();
  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    searchItems('');

    activateSpeechRecognizer();
    super.initState();
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
      if (widget.listening) {
        _isListening = res;
        if (res) {
          start();
        }
      }
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  @override
  void dispose() {
    _speech.cancel();
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

  void start() => _speech.listen(locale: _currentLocale).then((result) {
        setState(() => _isListening = true);
        startListening();
        print('_MyAppState.start => result ${result}');
      });

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((result) {
        print(result);
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(() => _currentLocale = locale);
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) {
    print(text);
  }

  void onRecognitionComplete(text) {
    print('lll');
    print(text);
    if (text.length > 0) {
      _textController.text = text;
      _textController.selection =
          TextSelection.fromPosition(TextPosition(offset: text.length));
      searchItems(text);
    }
    setState(() => _isListening = false);
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

  startListening() {
    if (_isListening)
      Future.delayed(Duration(seconds: 3), () {
        stop();
      });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
        var currentState = state['userstate'];
        if (currentState is UserIsUser) {
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
                                  setState(() {});
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
                if (_isListening)
                  Text(
                    L10n().getStr('app.listening'),
                    style:
                        theme.textTheme.h2.copyWith(color: ColorShades.greenBg),
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16,
                                  vertical: Spacing.space20,
                                ),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 220,
                                    childAspectRatio: 1,
                                  ),
                                  controller: _scrollController,
                                  itemCount: listing.length,
                                  itemBuilder: (context, index) {
                                    var item = listing[index].data;
                                    return Center(
                                      child: ItemCard(
                                        item: item,
                                      ),
                                    );
                                  },
                                ),
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
