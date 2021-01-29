import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/events.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/screens/home/appbar.dart';
import 'package:asia/screens/home/tabview.dart';
import 'package:asia/shared_widgets/app_drawer.dart';
import 'package:asia/shared_widgets/firebase_notification_configuration.dart';
import 'package:asia/theme/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  ThemeData theme;
  DocumentSnapshot lastItem;
  bool isFetching = false;
  int currentTabIndex = 0;
  TabController _controller;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _controller = TabController(vsync: this, length: 2);
    //_controller.addListener(tabChangeListener);
    ConfigureNotification.configureNotifications();
    BlocProvider.of<ItemDatabaseBloc>(context).add(FetchHomeItems());
    BlocProvider.of<ItemDatabaseBloc>(context).add(FetchAllCategories());
    _scrollController.addListener(scrollListener);
    BlocProvider.of<GlobalBloc>(context).add(FetchSellerInfo());
    super.initState();
  }

  // void tabChangeListener() {
  //   if (_controller.index == 1) {
  //     var previousIndex = _controller.previousIndex;
  //     var result = Navigator.pushNamed(context, Constants.SEARCH);
  //     result.then((_) {
  //       _controller.animateTo(previousIndex);
  //     });
  //   }
  // }

  scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true &&
        _controller.index == 0) {
      fetchMoreItems();
    }
  }

  fetchMoreItems() {
    setState(() {
      isFetching = true;
    });
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchHomeItems(callback: (data) {
      setState(() {
        isFetching = false;
      });
      if (data is Map && data.length == 0) {
        _scrollController.removeListener(scrollListener);
      }
    }));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.grey50,
        drawer: AppDrawer(),
        body: NestedScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          headerSliverBuilder: (context, boxIsScrolled) {
            return [
              HomeAppBar(tabController: _controller, isScrolled: boxIsScrolled)
            ];
          },
          body: TabView(isFetching: isFetching, tabController: _controller),
        ),
      ),
    );
  }
}
