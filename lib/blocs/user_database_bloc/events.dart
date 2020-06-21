import 'package:flutter/material.dart';

abstract class UserDatabaseEvents {}

class CheckIfAdminOrUser extends UserDatabaseEvents {}

class AddUserAddress extends UserDatabaseEvents {
  Map address;
  Function callback;
  AddUserAddress({@required this.address, this.callback});
}
