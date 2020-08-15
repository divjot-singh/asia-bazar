import 'package:flutter/material.dart';

abstract class GlobalState {
  static Map globalState = {'sellerInfo': GlobalUninitialisedState()};
}

class GlobalErrorState extends GlobalState {
  final String text;
  GlobalErrorState({this.text});
}

class GlobalFetchingState extends GlobalState {}

class GlobalUninitialisedState extends GlobalState {}

class InfoFetchedState extends GlobalState{
  Map sellerInfo;
  InfoFetchedState({@required this.sellerInfo});
}