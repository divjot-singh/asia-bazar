import 'package:flutter/foundation.dart';

abstract class OrderState {
  static Map orderState = {'orderState': UninitialisedState()};
}

class UninitialisedState extends OrderState {}

class OrderPlacedState extends OrderState {
  Map orderDetails;
  OrderPlacedState({@required this.orderDetails});
}

class OrderApproved extends OrderState {
  Map orderDetails;
  OrderApproved({@required this.orderDetails});
}

class OrderDispatched extends OrderState {
  Map orderDetails;
  OrderDispatched({@required this.orderDetails});
}

class OrderDelivered extends OrderState {
  Map orderDetails;
  OrderDelivered({@required this.orderDetails});
}

class OrderCancelled extends OrderState {
  Map orderDetails;
  OrderCancelled({@required this.orderDetails});
}

class OrderReturnRequested extends OrderState {
  Map orderDetails;
  OrderReturnRequested({@required this.orderDetails});
}

class OrderReturnApproved extends OrderState {
  Map orderDetails;
  OrderReturnApproved({@required this.orderDetails});
}

class OrderReturnRejected extends OrderState {
  Map orderDetails;
  OrderReturnRejected({@required this.orderDetails});
}

class OrderReturned extends OrderState {
  Map orderDetails;
  OrderReturned({@required this.orderDetails});
}
