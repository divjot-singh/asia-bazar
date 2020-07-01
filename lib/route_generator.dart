import 'package:asia/screens/add_address/index.dart';
import 'package:asia/screens/address_list/index.dart';
import 'package:asia/screens/authentication_screen/authentication_screen.dart';
import 'package:asia/screens/cart/index.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/screens/home/index.dart';
import 'package:asia/screens/onboarding/index.dart';
import 'package:asia/screens/order_list/index.dart';
import 'package:asia/screens/redirector/index.dart';
import 'package:asia/screens/update_profile/index.dart';
import 'package:asia/screens/user_is_admin/is_admin.dart';
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
      case Constants.HOME:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return HomeScreen();
          },
        );
      case Constants.EDIT_PROFILE:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return UpdateProfile();
          },
        );
      case Constants.ADMIN_PROFILE:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return IsAdmin();
          },
        );
      case Constants.CART:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Cart();
          },
        );
      case Constants.ONBOARDING:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Onboarding();
          },
        );
      case Constants.ORDER_LIST:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return OrderList();
          },
        );
      case Constants.CATEGORY_LISTING:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return CategoryListing(
              categoryId: params['categoryId'][0],
              categoryName: params['categoryName'][0],
            );
          },
        );
      case Constants.POST_AUTHENTICATION_REDIRECTOR:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Redirector();
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
      Constants.AUTHENTICATION_SCREEN,
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.EDIT_PROFILE,
      handler: getCommonHandler(Constants.EDIT_PROFILE),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.HOME,
      handler: getCommonHandler(Constants.HOME),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.ADMIN_PROFILE,
      handler: getCommonHandler(Constants.ADMIN_PROFILE),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.CART,
      handler: getCommonHandler(Constants.CART),
      transitionType: TransitionType.inFromBottom,
    );

    router.define(
      Constants.POST_AUTHENTICATION_REDIRECTOR,
      handler: getCommonHandler(Constants.POST_AUTHENTICATION_REDIRECTOR),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.ADD_ADDRESS,
      handler: getCommonHandler(Constants.ADD_ADDRESS),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      Constants.CATEGORY_LISTING,
      handler: getCommonHandler(Constants.CATEGORY_LISTING),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      Constants.ONBOARDING,
      handler: getCommonHandler(Constants.ONBOARDING),
      transitionType: TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ORDER_LIST,
      handler: getCommonHandler(Constants.ORDER_LIST),
      transitionType: TransitionType.inFromLeft,
    );
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
      case Constants.ADDRESS_LIST:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return AddressList(selectView: arguments['selectView']);
        });
      case Constants.ADD_ADDRESS:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return AddAddress(
            isEdit: arguments['isEdit'],
            first: arguments['first'],
            address: arguments['address'],
          );
        });

      default:
        return FluroRouter.router.generator(settings);
    }
  }
}
