import 'package:asia/blocs/order_bloc/state.dart';
import 'package:flutter/material.dart';

abstract class UserDatabaseState {
  static Map userstate = {
    'userstate': UnInitialisedState,
    'ordersstate': UninitialisedState
  };
}

class UserIsAdmin extends UserDatabaseState {
  var user;
  UserIsAdmin({@required this.user});
}

class UserIsUser extends UserDatabaseState {
  var user;
  UserIsUser({@required this.user});
}

class NewUser extends UserDatabaseState {
  var user;
  NewUser({@required this.user});
}

class ErrorState extends UserDatabaseState {}

class UnInitialisedState extends UserDatabaseState {}

class OrdersFetchedState extends UserDatabaseState {
  List orders;
  OrdersFetchedState({@required this.orders});
}
