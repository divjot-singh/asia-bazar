import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/events.dart';
import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/category_listing/index.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/custom_dialog.dart';
import 'package:asia/shared_widgets/page_views.dart';
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
  double grandTotal = 0;
  double totalCost = 0;
  double packagingCharges = 0;
  double otherCharges = 0;
  double deliveryCharges = 0;
  bool useLoyaltyPoints = false;
  double usablePoints = 0;
  double pointsThreshHold;
  @override
  void initState() {
    BlocProvider.of<UserDatabaseBloc>(context)
        .add(FetchCartItems(callback: fetchItemsCallback));
    var state = BlocProvider.of<GlobalBloc>(context).state['sellerInfo'];
    if (state is InfoFetchedState) {
      fetchSellerCallback(state.sellerInfo);
    } else
      BlocProvider.of<GlobalBloc>(context)
          .add(FetchSellerInfo(callback: fetchSellerCallback));
    super.initState();
  }

  fetchSellerCallback(info) {
    if (info is Map) {
      double d;
      setState(() {
        deliveryCharges = info['deliveryCharges'].toDouble();
        packagingCharges = info['packagingCharges'].toDouble();
        otherCharges = info['packagingCharges'].toDouble();
        pointsThreshHold = info[KeyNames['pointsLimit']].toDouble();
      });
    }
  }

  fetchItemsCallback(items) {
    if (items is Map && items.length > 0) {
      setState(() {
        cart = items;
      });
    }
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

  void removeItemHandler(item) {
    setState(() {
      cart.remove(item['opc'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(
        builder: (context, currentState) {
          var userState = currentState['userstate'];
          if (userState is GlobalFetchingState) {
            return Container(
                color: ColorShades.white, child: PageFetchingViewWithLightBg());
          } else if (userState is GlobalErrorState) {
            return PageErrorView();
          } else if (userState is UserIsUser) {
            var userCart = userState.user['cart'];
            var points = userState.user[KeyNames['points']];
            usablePoints = points;
            bool cartValid = cart != null &&
                userCart.length > 0 &&
                userCart.length == cart.length;
            if (cartValid) {
              totalCost = 0;
              cart.forEach((key, item) {
                item['cartQuantity'] =
                    userCart[item['opc'].toString()]['cartQuantity'];
                if (item['cost'] == null ||
                    (item['cost'] is String) &&
                        item['cost'].trim().length == 0) {
                  item['cost'] = 0;
                }
                if (item['quantity'] >= 1) {
                  var cost = item['cost'] * item['cartQuantity'];
                  totalCost += cost;
                }
              });
            }
            totalCost = ((totalCost * 100).ceil() / 100);
            grandTotal =
                totalCost + deliveryCharges + packagingCharges + otherCharges;
            grandTotal = (grandTotal * 100).ceil() / 100;
            if (grandTotal < points) usablePoints = grandTotal;
            if (useLoyaltyPoints) grandTotal -= usablePoints;
            return Scaffold(
              appBar: MyAppBar(
                hasTransparentBackground: true,
                title: L10n().getStr('drawer.cart'),
                rightAction: !cartValid
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
                                          text:
                                              L10n().getStr('confirmation.yes'),
                                          onPressed: () {
                                            showCustomLoader(context);
                                            BlocProvider.of<UserDatabaseBloc>(
                                                    context)
                                                .add(EmptyCart(
                                                    callback: (result) {
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
              body: !cartValid
                  ? emptyState()
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ...cart.keys.map((key) {
                            var item = cart[key];
                            return listItem(
                                context: context,
                                item: item,
                                removeItemHandler: removeItemHandler,
                                user: userState.user,
                                cartItem: true);
                          }),
                          // ListView.builder(
                          //   itemCount: cart.keys.length,
                          //   itemBuilder: (context, index) {
                          //     var item = cart[cart.keys.toList()[index]];
                          //     return listItem(
                          //         context: context,
                          //         item: item,
                          //         removeItemHandler: removeItemHandler,
                          //         user: userState.user,
                          //         cartItem: true);
                          //   },
                          // ),

                          SizedBox(
                            height: Spacing.space16,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Spacing.space16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  L10n().getStr('orderDetails.cartTotal') +
                                      ' : ',
                                  style: theme.textTheme.h4
                                      .copyWith(color: ColorShades.bastille),
                                ),
                                Text(
                                  '\$ ${totalCost.toStringAsFixed(2)}',
                                  style: theme.textTheme.body1Medium
                                      .copyWith(color: ColorShades.bastille),
                                ),
                              ],
                            ),
                          ),
                          if (deliveryCharges > 0)
                            SizedBox(
                              height: Spacing.space16,
                            ),
                          if (deliveryCharges > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    L10n().getStr(
                                            'orderDetails.deliveryCharges') +
                                        ' : ',
                                    style: theme.textTheme.h4
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                  Text(
                                    '\$ ${deliveryCharges.toStringAsFixed(2)}',
                                    style: theme.textTheme.body1Medium
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                ],
                              ),
                            ),
                          if (packagingCharges > 0)
                            SizedBox(
                              height: Spacing.space16,
                            ),
                          if (packagingCharges > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    L10n().getStr(
                                            'orderDetails.packagingCharges') +
                                        ' : ',
                                    style: theme.textTheme.h4
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                  Text(
                                    '\$ ${packagingCharges.toStringAsFixed(2)}',
                                    style: theme.textTheme.body1Medium
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                ],
                              ),
                            ),
                          if (otherCharges > 0)
                            SizedBox(
                              height: Spacing.space16,
                            ),
                          if (otherCharges > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    L10n().getStr('orderDetails.otherCharges') +
                                        ' : ',
                                    style: theme.textTheme.h4
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                  Text(
                                    '\$ ${otherCharges.toStringAsFixed(2)}',
                                    style: theme.textTheme.body1Medium
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                ],
                              ),
                            ),
                          if (pointsThreshHold != null &&
                              pointsThreshHold <= points)
                            Container(
                              margin: EdgeInsets.only(top: Spacing.space8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          activeColor: ColorShades.greenBg,
                                          value: useLoyaltyPoints,
                                          onChanged: (val) {
                                            setState(() {
                                              useLoyaltyPoints = val;
                                            });
                                          },
                                        ),
                                        Text(
                                          L10n().getStr('use loyalty points') +
                                              ' : ',
                                          style: theme.textTheme.h4.copyWith(
                                              color: ColorShades.bastille),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (useLoyaltyPoints ? '-' : '') +
                                        '\$ ${usablePoints.toStringAsFixed(2)}',
                                    style: theme.textTheme.body1Medium
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                ],
                              ),
                            ),
                          if (grandTotal != totalCost)
                            SizedBox(
                              height: Spacing.space8,
                            ),
                          if (grandTotal != totalCost)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Divider(
                                color: ColorShades.grey100,
                                thickness: 2,
                              ),
                            ),
                          if (grandTotal != totalCost)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    L10n().getStr('cart.total') + ' : ',
                                    style: theme.textTheme.h4
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                  Text(
                                    '\$ ${grandTotal.toStringAsFixed(2)}',
                                    style: theme.textTheme.body1Medium
                                        .copyWith(color: ColorShades.bastille),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: Spacing.space12)
                        ],
                      ),
                    ),
              bottomNavigationBar: !cartValid
                  ? BottomAppBar()
                  : Container(
                      height: 60,
                      color: ColorShades.greenBg,
                      padding:
                          EdgeInsets.symmetric(horizontal: Spacing.space16),
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
                                '\$ ${grandTotal.toStringAsFixed(2)}',
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
                                  onPressed: () async {
                                    var result = await Navigator.pushNamed(
                                        context, Constants.CHECKOUT,
                                        arguments: {
                                          'amount': grandTotal,
                                          'actualAmount': useLoyaltyPoints
                                              ? grandTotal + usablePoints
                                              : grandTotal,
                                          'areLoyaltyPointsUsed':
                                              useLoyaltyPoints,
                                          'pointsUsed': useLoyaltyPoints
                                              ? usablePoints
                                              : 0
                                        });
                                    if (result is Map &&
                                        result['refresh'] == true) {
                                      Navigator.popAndPushNamed(
                                          context, Constants.CART);
                                    }
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
          return Container();
        },
      ),
    );
  }
}
