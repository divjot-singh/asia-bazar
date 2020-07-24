import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class UserDatabaseEvents {}

class CheckIfAdminOrUser extends UserDatabaseEvents {}

class AddUserAddress extends UserDatabaseEvents {
  Map address;
  Function callback;
  AddUserAddress({@required this.address, this.callback});
}

class OnboardUser extends UserDatabaseEvents {
  Map address;
  String username;
  Function callback;
  OnboardUser({@required this.address, @required this.username, this.callback});
}

class UpdateUserAddress extends UserDatabaseEvents {
  Map address;
  String timestamp;
  Function callback;
  UpdateUserAddress(
      {@required this.address, @required this.timestamp, this.callback});
}

class DeleteUserAddress extends UserDatabaseEvents {
  String timestamp;
  Function callback;
  DeleteUserAddress({@required this.timestamp, this.callback});
}

class SetDefaultAddress extends UserDatabaseEvents {
  String timestamp;
  Function callback;
  SetDefaultAddress({@required this.timestamp, this.callback});
}

class UpdateUsername extends UserDatabaseEvents {
  String username;
  Function callback;
  UpdateUsername({@required this.username, this.callback});
}

class AddItemToCart extends UserDatabaseEvents {
  Map item;
  Function callback;
  AddItemToCart({@required this.item, this.callback});
}

class RemoveCartItem extends UserDatabaseEvents {
  String itemId;
  Function callback;
  RemoveCartItem({@required this.itemId, this.callback});
}

class EmptyCart extends UserDatabaseEvents {
  Function callback;
  EmptyCart({this.callback});
}

class FetchCartItems extends UserDatabaseEvents {
  Function callback;
  FetchCartItems({this.callback});
}

class FetchMyOrders extends UserDatabaseEvents {
  Function callback;
  DocumentSnapshot startAt;
  FetchMyOrders({this.callback, this.startAt});
}

class RefreshUser extends UserDatabaseEvents {}
