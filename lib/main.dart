//add all the imports here

import 'dart:io';

import 'package:asia/blocs/auth_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/index.dart';
import 'package:asia/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  // enable network traffic logging
  HttpClient.enableTimelineLogging = true;

  //Crashlytics.instance.enableInDevMode = true;
  //FlutterError.onError = recordFlutterError;

  FluroRouter.setupRouter();
  //runZoned(
  //() => {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => BlocHolder().authBloc(),
        ),
        BlocProvider<UserDatabaseBloc>(
          create: (BuildContext context) => BlocHolder().userDbBloc(),
        ),
      ],
      child: App(),
    ),
  );
  //};
  //onError: recordDartError,
  //);
}

class BlocHolder {
  AuthBloc _authBloc;
  UserDatabaseBloc _userDbBloc;
  BlocHolder._internal();
  static final BlocHolder _inst = BlocHolder._internal();

  factory BlocHolder() {
    return _inst;
  }
  AuthBloc authBloc() {
    if (_inst._authBloc == null) _inst._authBloc = AuthBloc();
    return _inst._authBloc;
  }

  UserDatabaseBloc userDbBloc() {
    if (_inst._userDbBloc == null) _inst._userDbBloc = UserDatabaseBloc();
    return _inst._userDbBloc;
  }
  // ChatBloc chatBloc() {
  //   if (_inst._chatBloc == null) _inst._chatBloc = ChatBloc();
  //   return _inst._chatBloc;
  // }

}
