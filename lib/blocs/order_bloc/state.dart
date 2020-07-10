import 'package:flutter/foundation.dart';

abstract class OrderState {
  static Map orderState = {
    'orderState': UninitialisedState(),
    'itemState': UninitialisedState()
  };
}

class UninitialisedState extends OrderState {}

class OrderFetchedState extends OrderState {
  dynamic orderDetails;
  OrderFetchedState({@required this.orderDetails});
}

class ItemFetchedState extends OrderState {
  List orderItems;
  String orderId;
  ItemFetchedState({@required this.orderId, @required this.orderItems});
}
