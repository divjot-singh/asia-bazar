import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  ThemeData theme;
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('drawer.cart'),
        ),
        body: BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, currentState) {
            var userState = currentState['userstate'];
            var cart = userState.user['cart'];
            if (cart == null || cart.length == 0) {
              return Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/empty_cart.png'),
                    SizedBox(
                      height: Spacing.space20,
                    ),
                    Text(
                      L10n().getStr('cart.empty'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg),
                    ),
                  ],
                ),
              );
            } else
              return Container();
          },
        ),
      ),
    );
  }
}
