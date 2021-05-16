import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/quantity_updater.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCard extends StatefulWidget {
  final Map item;
  final Function removeItemHandler;
  ItemCard({@required this.item, this.removeItemHandler});

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool showQuantityUpdater = false;

  addItemToCart(cartItem) {
    showCustomLoader(context);
    BlocProvider.of<UserDatabaseBloc>(context).add(AddItemToCart(
        item: cartItem,
        callback: (result) {
          Navigator.pop(context);
          if (result is Map && result['error'] != null || result == false) {
            var errorMessage = result is Map && result['error'] != null
                ? 'error.' + result['error']
                : 'profile.address.error';
            showCustomSnackbar(
                content: L10n().getStr(errorMessage),
                context: context,
                type: SnackbarType.error);
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var item = widget.item;
    bool outOfStock = item['quantity'] <= 0;
    if (item['cost'] == null ||
        (item['cost'] is String && item['cost'].trim().length == 0)) {
      item['cost'] = 0;
    }
    var cost = item['cost'] is String
        ? double.parse(item['cost'])
        : item['cost'].toDouble();
    return BlocBuilder<UserDatabaseBloc, Map>(
      builder: (context, state) {
        var currentState = state['userstate'];
        if (currentState is UserIsUser) {
          var user = currentState.user;
          var cart = user['cart'];
          bool itemInCart = cart[item['item_id'].toString()] != null;
          int cartQuantity = 0;
          if (itemInCart) {
            cartQuantity = cart[item['item_id'].toString()]['cartQuantity'];
          }
          return GestureDetector(
            onTap: () {
              setState(() {
                showQuantityUpdater = false;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: Spacing.space16),
              width: 140,
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ColorShades.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: item['image_url'] != null
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.fill,
                                      placeholder: 'assets/images/loader.gif',
                                      image: item['image_url']
                                          .replaceAll('http', 'https'),
                                    )
                                  : Image.asset(
                                      'assets/images/image_unavailable.jpeg'),
                            ),
                          ),
                          SizedBox(
                            width: Spacing.space8,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (!itemInCart) {
                                var currentCartItem = {
                                  'price': item['cost'],
                                  'cartQuantity': 1,
                                  'category_id': item['category_id'].toString(),
                                  'item_id': item['item_id'].toString()
                                };
                                addItemToCart(currentCartItem);
                              } else {
                                setState(() {
                                  showQuantityUpdater = true;
                                });
                              }
                            },
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: itemInCart
                                    ? ColorShades.greenBg
                                    : ColorShades.white,
                                border: Border.all(color: ColorShades.greenBg),
                              ),
                              child: Center(
                                  child: itemInCart
                                      ? Text(
                                          cartQuantity.toString(),
                                          style: theme.textTheme.body1Bold
                                              .copyWith(
                                                  color: ColorShades.white),
                                        )
                                      : Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorShades.greenBg,
                                        )),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Spacing.space8,
                      ),
                      if (outOfStock)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: Spacing.space4),
                          child: Text(
                            L10n().getStr('item.outOfStock'),
                            style: theme.textTheme.body1Regular.copyWith(
                                color: ColorShades.red,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: Spacing.space4),
                          child: Row(
                            children: <Widget>[
                              if (item['normal_price'] != null)
                                Text(
                                  '\$ ' + item['normal_price'].toString(),
                                  style: theme.textTheme.body1Regular.copyWith(
                                      color: ColorShades.grey200,
                                      decoration: TextDecoration.lineThrough),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(
                                width: Spacing.space4,
                              ),
                              Text(
                                '  \$ ' + cost.toString(),
                                style: theme.textTheme.body1Bold.copyWith(
                                  color: ColorShades.bastille,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                      SizedBox(height: Spacing.space4),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Spacing.space4),
                        child: Text(
                          item['description'],
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.body1Regular.copyWith(
                            color: ColorShades.grey300,
                          ),
                        ),
                      )
                    ],
                  ),
                  if (showQuantityUpdater)
                    Container(
                      height: 200,
                      width: 132,
                      color: ColorShades.white.withOpacity(0.4),
                    ),
                  if (showQuantityUpdater)
                    Container(
                      width: 132,
                      padding: EdgeInsets.only(left: 1, right: 1, top: 1),
                      child: QuantityUpdater(
                        quantity: cartQuantity,
                        minQuantity: 1,
                        maxQuantity: 50,
                        addHandler: ({int value}) {
                          Map currentCartItem = {
                            ...cart[item['item_id'].toString()]
                          };

                          currentCartItem['cartQuantity'] = value != null
                              ? value
                              : currentCartItem['cartQuantity'] + 1;

                          addItemToCart(currentCartItem);
                          setState(() {
                            showQuantityUpdater = false;
                          });
                        },
                        subtractHandler: () {
                          Map currentCartItem = {
                            ...cart[item['item_id'].toString()]
                          };
                          if (currentCartItem['cartQuantity'] > 1) {
                            currentCartItem['cartQuantity'] =
                                currentCartItem['cartQuantity'] - 1;
                            addItemToCart(currentCartItem);
                          } else {
                            showCustomLoader(context);
                            BlocProvider.of<UserDatabaseBloc>(context).add(
                                RemoveCartItem(
                                    itemId:
                                        currentCartItem['item_id'].toString(),
                                    callback: (result) {
                                      Navigator.pop(context);
                                      if (!result) {
                                        showCustomSnackbar(
                                            content: L10n().getStr(
                                                'profile.address.error'),
                                            context: context,
                                            type: SnackbarType.error);
                                      } else {
                                        if (widget.removeItemHandler != null)
                                          widget.removeItemHandler(
                                              currentCartItem);
                                      }
                                    }));
                          }
                          setState(() {
                            showQuantityUpdater = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
