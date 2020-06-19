import 'package:asia/screens/authentication_screen/authentication_screen.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class FluroRouter {
  static Router router = Router();
  static Handler getCommonHandler(String route) {
    switch (route) {
      case Constants.AUTHENTICATION_SCREEN:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );

      default:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );
    }
  }

  static void setupRouter() {
    router.define(
      '/',
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: TransitionType.fadeIn,
    );
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    String routeName = settings.name;
    switch (routeName) {
      // case Constants.EDITPROFILE:
      //   return MaterialPageRoute(
      //       builder: (_) => EditProfile(userData: settings.arguments));

      default:
        return FluroRouter.router.generator(settings);
    }
  }
}
