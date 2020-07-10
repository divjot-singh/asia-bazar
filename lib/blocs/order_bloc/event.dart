import 'package:flutter/material.dart';

abstract class OrderEvent {}

class FetchOrderDetails extends OrderEvent {
  String orderId;
  bool addListener;
  FetchOrderDetails({@required this.orderId, this.addListener = true});
}

class FetchOrderItems extends OrderEvent {
  String orderId;
  Function callback;
  FetchOrderItems({@required this.orderId, this.callback});
}
