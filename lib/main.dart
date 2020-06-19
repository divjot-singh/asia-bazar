//add all the imports here

import 'dart:async';
import 'dart:io';

import 'package:asia/blocs/auth_bloc/bloc.dart';
import 'package:asia/index.dart';
import 'package:asia/route_generator.dart';
import 'package:asia/services/error_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:logger/logger.dart';

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
                create: (BuildContext context) => AuthBloc(),
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
  BlocHolder._internal();
  static final BlocHolder _inst = BlocHolder._internal();

  factory BlocHolder() {
    return _inst;
  }

  // ChatBloc chatBloc() {
  //   if (_inst._chatBloc == null) _inst._chatBloc = ChatBloc();
  //   return _inst._chatBloc;
  // }

}
