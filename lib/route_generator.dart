import 'package:asia/main.dart';
import 'package:asia/screens/add_address/index.dart';
import 'package:asia/screens/address_list/index.dart';
import 'package:asia/screens/all_search/index.dart';
import 'package:asia/screens/authentication_screen/authentication_screen.dart';
import 'package:asia/screens/cart/index.dart';
import 'package:asia/screens/category_list/index.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/screens/checkout/index.dart';
import 'package:asia/screens/home/index.dart';
import 'package:asia/screens/onboarding/index.dart';
import 'package:asia/screens/order_details/index.dart';
import 'package:asia/screens/order_details/item_details.dart';
import 'package:asia/screens/order_list/index.dart';
import 'package:asia/screens/paymentScreen/index.dart';
import 'package:asia/screens/redirector/index.dart';
import 'package:asia/screens/update_profile/index.dart';
import 'package:asia/screens/user_is_admin/is_admin.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart' as Fluro;
import 'package:flutter_bloc/flutter_bloc.dart';

class FluroRouter {
  static Fluro.Router router = Fluro.Router();
  static Fluro.Handler getCommonHandler(String route) {
    switch (route) {
      case Constants.AUTHENTICATION_SCREEN:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );
      case Constants.HOME:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return HomeScreen();
          },
        );
      case Constants.EDIT_PROFILE:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return UpdateProfile();
          },
        );
      case Constants.ADMIN_PROFILE:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return IsAdmin();
          },
        );
      case Constants.SEARCH:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            bool listening = (params['listening'][0] == 'true');
            print(listening);
            print(params['listening'][0]);
            print(params['listening'][0] == 'true');
            return SearchItems(
              listening: listening,
            );
          },
        );
      case Constants.CART:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Cart();
          },
        );
      case Constants.ONBOARDING:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Onboarding();
          },
        );
      case Constants.ORDER_LIST:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return OrderList();
          },
        );
      case Constants.ORDER_DETAILS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            var orderId = params['orderId'][0];
            return BlocProvider.value(
                value: BlocHolder().getClubDetailsBloc(orderId),
                child: OrderDetails(orderId: orderId));
          },
        );
      case Constants.ORDER_ITEM_DETAILS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            var orderId = params['orderId'][0];
            String amount = params['amount'][0];
            //var editView = params['editView'][0] == "true";
            return BlocProvider.value(
                value: BlocHolder().getClubDetailsBloc(orderId),
                child: OrderItemDetails(
                  orderId: orderId,
                  editView: false,
                  amount: double.parse(amount),
                ));
          },
        );
      case Constants.CATEGORY_LISTING:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return CategoryListing(
              categoryId: params['categoryId'][0],
              categoryName: params['categoryName'][0],
            );
          },
        );
      case Constants.POST_AUTHENTICATION_REDIRECTOR:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Redirector();
          },
        );
      case Constants.DEPARTMENT_LIST:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return CategoryList();
          },
        );
      default:
        return Fluro.Handler(
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
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.EDIT_PROFILE,
      handler: getCommonHandler(Constants.EDIT_PROFILE),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.HOME,
      handler: getCommonHandler(Constants.HOME),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.ADMIN_PROFILE,
      handler: getCommonHandler(Constants.ADMIN_PROFILE),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.SEARCH,
      handler: getCommonHandler(Constants.SEARCH),
      transitionType: Fluro.TransitionType.inFromBottom,
    );
    router.define(
      Constants.CART,
      handler: getCommonHandler(Constants.CART),
      transitionType: Fluro.TransitionType.inFromBottom,
    );

    router.define(
      Constants.POST_AUTHENTICATION_REDIRECTOR,
      handler: getCommonHandler(Constants.POST_AUTHENTICATION_REDIRECTOR),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.DEPARTMENT_LIST,
      handler: getCommonHandler(Constants.DEPARTMENT_LIST),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.ADD_ADDRESS,
      handler: getCommonHandler(Constants.ADD_ADDRESS),
      transitionType: Fluro.TransitionType.inFromBottom,
    );
    router.define(
      Constants.ORDER_DETAILS,
      handler: getCommonHandler(Constants.ORDER_DETAILS),
      transitionType: Fluro.TransitionType.inFromBottom,
    );
    router.define(
      Constants.CATEGORY_LISTING,
      handler: getCommonHandler(Constants.CATEGORY_LISTING),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.ONBOARDING,
      handler: getCommonHandler(Constants.ONBOARDING),
      transitionType: Fluro.TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ORDER_ITEM_DETAILS,
      handler: getCommonHandler(Constants.ORDER_ITEM_DETAILS),
      transitionType: Fluro.TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ORDER_LIST,
      handler: getCommonHandler(Constants.ORDER_LIST),
      transitionType: Fluro.TransitionType.inFromLeft,
    );
    router.define(
      '/',
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: Fluro.TransitionType.fadeIn,
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
          return AddressList(
              selectView: arguments['selectView'] != null
                  ? arguments['selectView']
                  : false);
        });
      case Constants.CHECKOUT:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return Checkout(
            amount: arguments['amount'],
            areLoyaltyPointsUsed: arguments['areLoyaltyPointsUsed'] ?? false,
            pointsUsed: arguments['pointsUsed'].toDouble() ?? 0,
            actualAmount: arguments['actualAmount'] ?? arguments['amount'],
          );
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
      case Constants.MAKE_PAYMENT:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return PaymentScreen(
            amount: double.parse(arguments['amount'].toString()),
          );
        });
      default:
        return FluroRouter.router.generator(settings);
    }
  }
}
