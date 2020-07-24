import 'package:asia/blocs/auth_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/order_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  Future<dynamic> navigateTo(String routeName, {Map arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateAndRemoveUntilTo(String routeName,
      {Map arguments, @required Function predicate}) {
    return navigatorKey.currentState
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  Future<dynamic> navigateReplacementTo(String routeName, {Map arguments}) {
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> addAuthBlocEvent(event) async {
    BlocProvider.of<AuthBloc>(navigatorKey.currentContext).add(event);
  }

  Future<dynamic> addGlobalBlocEvent(event) async {
    BlocProvider.of<GlobalBloc>(navigatorKey.currentContext).add(event);
  }

  Future<dynamic> addItemBlocEvent(event) async {
    BlocProvider.of<ItemDatabaseBloc>(navigatorKey.currentContext).add(event);
  }

  Future<dynamic> addUserBlocEvent(event) async {
    BlocProvider.of<UserDatabaseBloc>(navigatorKey.currentContext).add(event);
  }

  Future<dynamic> addOrderBlocEvent(event) async {
    BlocProvider.of<OrderDetailsBloc>(navigatorKey.currentContext).add(event);
  }
}
