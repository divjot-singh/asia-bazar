import 'package:flutter/material.dart';

abstract class UserDatabaseEvents {}

class CheckIfAdminOrUser extends UserDatabaseEvents {}

class AddUserAddress extends UserDatabaseEvents {
  Map address;
  Function callback;
  AddUserAddress({@required this.address, this.callback});
}
class OnboardUser extends UserDatabaseEvents{
  Map address;
  String username;
  Function callback;
  OnboardUser({@required this.address, @required this.username, this.callback});
}