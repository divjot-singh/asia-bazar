import 'package:asia/blocs/user_database_bloc/bloc.dart';
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
