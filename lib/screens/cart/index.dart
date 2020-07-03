import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/custom_dialog.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/secondary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  ThemeData theme;
  var cart;
  double totalCost = 0;
  @override
  void initState() {
    super.initState();
  }

  Widget emptyState() {
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
            style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(
        builder: (context, currentState) {
          var userState = currentState['userstate'];
          cart = userState.user['cart'];
          if (cart != null) {
            totalCost = 0;
            cart.forEach((key, item) {
              if (item['cost'] == null ||
                  (item['cost'] is String) && item['cost'].trim().length == 0) {
                item['cost'] = 0;
              }
              var cost = item['cost'] * item['cartQuantity'];
              totalCost += cost;
            });
          }
          totalCost = ((totalCost * 100).ceil() / 100);
          return Scaffold(
            appBar: MyAppBar(
              hasTransparentBackground: true,
              title: L10n().getStr('drawer.cart'),
              rightAction: cart == null || cart.keys.toList().length == 0
                  ? null
                  : {
                      'icon': Icon(Icons.delete, color: ColorShades.greenBg),
                      'onTap': () {
                        showCustomDialog(
                          context: context,
                          heading: '',
                          child: Padding(
                            padding: EdgeInsets.all(Spacing.space8),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  L10n().getStr('cart.empty.confirmation'),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.h4
                                      .copyWith(color: ColorShades.greenBg),
                                ),
                                SizedBox(
                                  height: Spacing.space20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Spacing.space8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SecondaryButton(
                                        hideShadow: true,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Spacing.space16,
                                            vertical: Spacing.space12),
                                        noWidth: true,
                                        text: L10n().getStr('confirmation.yes'),
                                        onPressed: () {
                                          showCustomLoader(context);
                                          BlocProvider.of<UserDatabaseBloc>(
                                                  context)
                                              .add(
                                                  EmptyCart(callback: (result) {
                                            if (result) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            } else {
                                              showCustomSnackbar(
                                                  context: context,
                                                  type: SnackbarType.error,
                                                  content: L10n().getStr(
                                                      'profile.address.error'));
                                            }
                                          }));
                                        },
                                      ),
                                      PrimaryButton(
                                        text: L10n()
                                            .getStr('confirmation.cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    },
            ),
            backgroundColor: ColorShades.white,
            body: cart == null || cart.keys.toList().length == 0
                ? emptyState()
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.keys.length,
                          itemBuilder: (context, index) {
                            var item = cart[cart.keys.toList()[index]];
                            return listItem(
                                context: context,
                                item: item,
                                user: userState.user,
                                cartItem: true);
                          },
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: cart == null ||
                    (cart is Map && cart.length == 0)
                ? BottomAppBar()
                : Container(
                    height: 60,
                    color: ColorShades.greenBg,
                    padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              L10n().getStr('cart.total') + ' : ',
                              style: theme.textTheme.h4
                                  .copyWith(color: ColorShades.white),
                            ),
                            Text(
                              '\$ ${totalCost.toStringAsFixed(2)}',
                              style: theme.textTheme.h4
                                  .copyWith(color: ColorShades.white),
                            )
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              PrimaryButton(
                                text: 'Check out',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Constants.CHECKOUT,
                                      arguments: {'amount': totalCost});
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
