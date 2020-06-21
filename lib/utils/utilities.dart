import 'package:asia/blocs/auth_bloc/bloc.dart';
import 'package:asia/blocs/auth_bloc/events.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Utilities {
  static bool keyboardIsVisible(BuildContext context) {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  static void logout(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(SignOut(callback: () {
      Navigator.pushNamedAndRemoveUntil(context,
          Constants.AUTHENTICATION_SCREEN, (Route<dynamic> route) => false);
    }));
  }
}
