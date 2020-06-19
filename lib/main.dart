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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your applicationx.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title;
  MyHomePage({this.title});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.title),
    );
  }
}
// void main() {
//   // enable network traffic logging
//   HttpClient.enableTimelineLogging = true;

//   //Crashlytics.instance.enableInDevMode = true;
//   //FlutterError.onError = recordFlutterError;

//   FluroRouter.setupRouter();
//   //runZoned(
//   //() => {
//         runApp(
//           MultiBlocProvider(
//             providers: [
//               BlocProvider<AuthBloc>(
//                 create: (BuildContext context) => AuthBloc(),
//               ),
//             ],
//             child: App(),
//           ),
//         );
//       //};
//   //onError: recordDartError,
//   //);
// }

// class BlocHolder {
//   BlocHolder._internal();
//   static final BlocHolder _inst = BlocHolder._internal();

//   factory BlocHolder() {
//     return _inst;
//   }

//   // ChatBloc chatBloc() {
//   //   if (_inst._chatBloc == null) _inst._chatBloc = ChatBloc();
//   //   return _inst._chatBloc;
//   // }

// }
