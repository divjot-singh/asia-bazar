import 'package:asia/repository/user_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

abstract class UserDatabaseState {}

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
