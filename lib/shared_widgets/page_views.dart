import 'package:flutter/material.dart';
import 'dart:core';
import 'package:asia/theme/style.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

abstract class PageView extends StatelessWidget {}

//PageView has generic views for all states that is rendered in the main area of all screens.
//This can however, be avoided, in preference of a specific view, as may be required for a screen.

class PageUninitializedView extends PageView {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(''));
  }
}

class PageFetchingView extends PageView {
  @override
  Widget build(BuildContext context) {
    final loader = SpinKitChasingDots(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorShades.white,
          ),
        );
      },
    );
    return loader;
  }
}

class PageFetchingViewWithLightBg extends PageView {
  @override
  Widget build(BuildContext context) {
    final loader = TinyLoader();
    return loader;
  }
}

class TinyLoader extends PageView {
  @override
  Widget build(BuildContext context) {
    return SpinKitSquareCircle(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorShades.darkGreenBg,
          ),
        );
      },
    );
  }
}

class PageFetchingViewWithCircularLoader extends PageView {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class PageErrorView extends PageView {
  final error;
  PageErrorView({
    this.error,
  }) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: Spacing.space16, left: Spacing.space16),
      color: Theme.of(context).colorScheme.bg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: error != null ? Text(error) : Text('Error'),
        ),
      ),
    );
  }
}

class PageEmptyView extends PageView {
  final String text;

  PageEmptyView({this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text != null ? text : 'Empty'));
  }
}
