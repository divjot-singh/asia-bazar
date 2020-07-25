import 'package:asia/screens/category_list/index.dart';
import 'package:asia/screens/home/home_view.dart';
import 'package:flutter/material.dart';

class TabView extends StatefulWidget {
  final bool isFetching;
  final TabController tabController;
  TabView({this.isFetching = false, @required this.tabController});
  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: <Widget>[
        HomeView(isFetching: widget.isFetching),
        CategoryBody(),
      ],
    );
  }
}
