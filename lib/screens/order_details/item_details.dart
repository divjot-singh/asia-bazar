import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/events.dart';
import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/order_bloc/bloc.dart';
import 'package:asia/blocs/order_bloc/event.dart';
import 'package:asia/blocs/order_bloc/state.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/checkbox_list.dart';
import 'package:asia/shared_widgets/custom_dialog.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/quantity_updater.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderItemDetails extends StatefulWidget {
  final bool editView;
  final String orderId;
  final double amount;
  OrderItemDetails(
      {@required this.orderId, this.editView = false, this.amount});

  @override
  _OrderItemDetailsState createState() => _OrderItemDetailsState();
}

class _OrderItemDetailsState extends State<OrderItemDetails> {
  ThemeData theme;
  double grandTotal = 0;
  double totalCost = 0;

  List selectedItems;
  bool selected = true;
  var currentUser;
  var address;
  @override
  void initState() {
    BlocProvider.of<OrderDetailsBloc>(context).add(
        FetchOrderItems(orderId: widget.orderId, callback: fetchItemsCallback));

    super.initState();
  }

  fetchItemsCallback(List items) {
    List allItems = items.map((item) {
      var cartItem = item['orderData'].data['itemDetails'];
      return {
        'id': cartItem['item_id'].toString(),
        'price': cartItem['price'],
        'returnQuantity': cartItem['cartQuantity'],
        'item': item
      };
    }).toList();
    setState(() {
      selectedItems = [...allItems];
    });
  }

  Widget itemTile(item) {
    var listItem = item['itemData'].data;
    var cartItem = item['orderData'].data['itemDetails'];
    var returnedQuantity;
    if (selectedItems != null && widget.editView) {
      var selectedCartItem = selectedItems.firstWhere(
          (item) => item['id'] == listItem['item_id'].toString(),
          orElse: () => {});
      returnedQuantity = selectedCartItem['returnQuantity'] != null
          ? selectedCartItem['returnQuantity']
          : 0;
    } else {
      returnedQuantity = cartItem['cartQuantity'];
    }
    bool outOfStock = listItem['quantity'] == 0;
    var itemTotal = cartItem['price'] * returnedQuantity;
    itemTotal = ((itemTotal * 100).ceil() / 100);
    totalCost += itemTotal;
    grandTotal = widget.amount;
    totalCost = ((totalCost * 100).ceil() / 100);
    grandTotal = ((grandTotal * 100).ceil() / 100);

    return Container(
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          // boxShadow: [Shadows.cardLight],
          color: outOfStock ? ColorShades.grey100 : ColorShades.white),
      padding: EdgeInsets.symmetric(
          horizontal: widget.editView ? 0 : Spacing.space16,
          vertical: Spacing.space12),
      margin: EdgeInsets.only(
          bottom: Spacing.space16,
          left: Spacing.space16,
          right: Spacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Image.network(
          //   listItem['image_url'] != null
          //       ? listItem['image_url']
          //       : 'https://dummyimage.com/600x400/ffffff/000000.png&text=Image+not+available',
          //   height: widget.editView ? 50 : 100,
          //   width: widget.editView ? 50 : 100,
          // ),
          // SizedBox(
          //   width: Spacing.space12,
          // ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  listItem['description'] + ':',
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.bastille),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          SizedBox(
            height: Spacing.space12,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        L10n().getStr('orderDetails.quantity'),
                        style: theme.textTheme.body1Bold
                            .copyWith(color: theme.colorScheme.textPrimaryDark),
                      ),
                      SizedBox(
                        height: Spacing.space4,
                      ),
                      Text(
                        widget.editView
                            ? returnedQuantity.toString()
                            : cartItem['cartQuantity'].toString(),
                        style: theme.textTheme.body1Regular
                            .copyWith(color: theme.colorScheme.textPrimaryDark),
                      )
                    ]),
              ),
              Expanded(
                child: Column(children: [
                  Text(L10n().getStr('orderDetails.price'),
                      style: theme.textTheme.body1Bold
                          .copyWith(color: theme.colorScheme.textPrimaryDark)),
                  SizedBox(
                    height: Spacing.space4,
                  ),
                  Text('\$ ${cartItem['price'].toStringAsFixed(2)}',
                      style: theme.textTheme.body1Regular
                          .copyWith(color: theme.colorScheme.textPrimaryDark))
                ]),
              ),
              Expanded(
                child: Column(children: [
                  Text(L10n().getStr('orderDetails.total'),
                      style: theme.textTheme.body1Bold
                          .copyWith(color: theme.colorScheme.textPrimaryDark)),
                  SizedBox(
                    height: Spacing.space4,
                  ),
                  Text('\$ ${itemTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.body1Regular
                          .copyWith(color: theme.colorScheme.textPrimaryDark))
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> totalCalculations() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Divider(
          thickness: 2,
          color: ColorShades.grey100,
        ),
      ),
      SizedBox(
        height: Spacing.space16,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              L10n().getStr('orderDetails.cartTotal') + ' : ',
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
            ),
            Text(
              '\$ ${totalCost.toStringAsFixed(2)}',
              style: theme.textTheme.body1Medium
                  .copyWith(color: ColorShades.bastille),
            ),
          ],
        ),
      ),
      if (grandTotal != totalCost)
        SizedBox(
          height: Spacing.space16,
        ),
      if (grandTotal != totalCost)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('orderDetails.additionalCharges') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${(grandTotal - totalCost).toStringAsFixed(2)}',
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
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Divider(
            color: ColorShades.grey100,
            thickness: 2,
          ),
        ),
      if (grandTotal != totalCost)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('cart.total') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${grandTotal.toStringAsFixed(2)}',
                style: theme.textTheme.body1Medium
                    .copyWith(color: ColorShades.bastille),
              ),
            ],
          ),
        ),
      SizedBox(
        height: Spacing.space16,
      ),
    ];
  }

  List<Widget> returnCalculations() {
    var returnValue;
    if (selectedItems != null) {
      returnValue = selectedItems.fold(0, (value, item) {
        var cartQuantity = item['returnQuantity'];
        var itemCost = item['price'];
        value += (cartQuantity * itemCost);
        return value;
      });
      returnValue = ((returnValue * 100).ceil() / 100);
    } else {
      returnValue = 0;
    }
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              L10n().getStr('orderDetails.return.value') + ' : ',
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
            ),
            Text(
              '\$ ${returnValue.toStringAsFixed(2)}',
              style: theme.textTheme.body1Medium
                  .copyWith(color: ColorShades.bastille),
            ),
          ],
        ),
      ),
    ];
  }

  confirmExchangeReturn(type) {
    if (type == 'return') {
      var exchangeItems = selectedItems.map((item) {
        return {
          'price': item['price'],
          'returnQuantity': item['returnQuantity'],
          'item_id': item['id'].toString(),
        };
      });
      var orderRef = selectedItems[0]['item']['orderData'].data['orderRef'];
      var exchangeOrders = {
        'items': exchangeItems,
        'orderId': widget.orderId,
        'orderRef': orderRef
      };
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    grandTotal = 0;
    totalCost = 0;
    theme = Theme.of(context);
    return BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
      var currentState = state['userstate'];
      if (currentState is UserIsUser) {
        currentUser = currentState.user;
        List addressList = currentUser[KeyNames['address']];
        address = addressList.firstWhere((item) => item['is_default'] == true);
        return SafeArea(
          child: BlocBuilder<OrderDetailsBloc, Map>(
            builder: (context, state) {
              var currentState = state['itemState'];
              if (currentState is GlobalFetchingState) {
                return Container(
                    color: ColorShades.white,
                    child: PageFetchingViewWithLightBg());
              } else if (currentState is GlobalErrorState) {
                return PageErrorView();
              } else if (currentState is ItemFetchedState &&
                  currentState.orderId == widget.orderId) {
                if (currentState.orderItems.length > 0) {
                  return Scaffold(
                    backgroundColor: ColorShades.white,
                    appBar: MyAppBar(
                      hasTransparentBackground: true,
                      title: L10n().getStr('orderItems.heading'),
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: Spacing.space16,
                          ),
                          if (widget.editView)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: Spacing.space20,
                                  left: Spacing.space16),
                              child: Text(
                                L10n().getStr('orderDetails.chooseItems'),
                                style: theme.textTheme.h4
                                    .copyWith(color: ColorShades.bastille),
                              ),
                            ),
                          ...currentState.orderItems.map((item) {
                            if (widget.editView) {
                              var cartItem =
                                  item['orderData'].data['itemDetails'];
                              var itemSelected = selectedItems != null
                                  ? selectedItems.firstWhere(
                                      (item) =>
                                          item['id'] ==
                                          cartItem['item_id'].toString(),
                                      orElse: () => null)
                                  : {};
                              int availableQuantity =
                                  item['itemData'].data['quantity'];
                              bool isItemSelected = itemSelected != null;
                              int selectedQuantity = isItemSelected
                                  ? itemSelected['returnQuantity']
                                  : 0;
                              bool outOfStock = availableQuantity <= 0;
                              if (outOfStock && isItemSelected)
                                selectedItems.removeWhere(
                                    (item) => item['id'] == itemSelected['id']);
                              return Container(
                                color: outOfStock
                                    ? ColorShades.grey100
                                    : ColorShades.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.space16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: outOfStock
                                          ? Container(
                                              child: Center(
                                                  child: Text(
                                                L10n()
                                                    .getStr('item.outOfStock'),
                                                style: theme
                                                    .textTheme.body1Medium
                                                    .copyWith(
                                                  color: ColorShades.redOrange,
                                                ),
                                              )),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  height: 24,
                                                  width: 24,
                                                  child: Center(
                                                    child: Checkbox(
                                                      onChanged: (selected) {
                                                        if (selected) {
                                                          selectedItems.add({
                                                            'id': cartItem[
                                                                    'item_id']
                                                                .toString(),
                                                            'price': cartItem[
                                                                'price'],
                                                            'returnQuantity':
                                                                cartItem[
                                                                    'cartQuantity'],
                                                            'item': item
                                                          });
                                                          setState(() {
                                                            selectedItems = [
                                                              ...selectedItems
                                                            ];
                                                          });
                                                        } else {
                                                          List newItems = [
                                                            ...selectedItems
                                                          ];
                                                          newItems.removeWhere(
                                                              (item) =>
                                                                  item['id'] ==
                                                                  cartItem[
                                                                          'item_id']
                                                                      .toString());
                                                          setState(() {
                                                            selectedItems =
                                                                newItems;
                                                          });
                                                        }
                                                      },
                                                      activeColor:
                                                          ColorShades.greenBg,
                                                      value: isItemSelected,
                                                    ),
                                                  ),
                                                ),
                                                if (cartItem['cartQuantity'] >
                                                        1 &&
                                                    isItemSelected)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: Spacing.space8),
                                                    child: QuantityUpdater(
                                                      subtractHandler: () {
                                                        Map currentItem = {
                                                          ...itemSelected
                                                        };
                                                        currentItem[
                                                                'returnQuantity'] =
                                                            currentItem[
                                                                    'returnQuantity'] -
                                                                1;
                                                        List allItems =
                                                            selectedItems
                                                                .map((item) {
                                                          if (item['id'] ==
                                                              itemSelected[
                                                                  'id']) {
                                                            item['returnQuantity'] -=
                                                                1;
                                                          }
                                                          return item;
                                                        }).toList();
                                                        setState(() {
                                                          selectedItems =
                                                              allItems;
                                                        });
                                                      },
                                                      addHandler: (
                                                          {int value}) {
                                                        Map currentItem = {
                                                          ...itemSelected
                                                        };
                                                        currentItem[
                                                                'returnQuantity'] =
                                                            currentItem[
                                                                    'returnQuantity'] -
                                                                1;
                                                        List allItems =
                                                            selectedItems
                                                                .map((item) {
                                                          if (item['id'] ==
                                                              itemSelected[
                                                                  'id']) {
                                                            item['returnQuantity'] =
                                                                value != null
                                                                    ? value
                                                                    : item['returnQuantity'] +
                                                                        1;
                                                          }
                                                          return item;
                                                        }).toList();
                                                        setState(() {
                                                          selectedItems =
                                                              allItems;
                                                        });
                                                      },
                                                      quantity:
                                                          selectedQuantity,
                                                      maxQuantity: cartItem[
                                                          'cartQuantity'],
                                                      showAdd: selectedQuantity !=
                                                          cartItem[
                                                              'cartQuantity'],
                                                      showMinus:
                                                          selectedQuantity !=
                                                                  null &&
                                                              selectedQuantity >
                                                                  1,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: itemTile(item),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return itemTile(item);
                          }),
                          if (!widget.editView)
                            ...totalCalculations()
                          else
                            ...returnCalculations()
                        ],
                      ),
                    ),
                    bottomNavigationBar: widget.editView
                        ? BottomAppBar(
                            child: Container(
                              height: 75,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Spacing.space16,
                                  vertical: Spacing.space16),
                              color: ColorShades.greenBg,
                              child: PrimaryButton(
                                text: L10n().getStr('onboarding.next'),
                                onPressed: () {
                                  showCustomDialog(
                                      context: context,
                                      heading: '',
                                      child: ExchangeReturnDialog(
                                        onSelect: confirmExchangeReturn,
                                      ));
                                },
                              ),
                            ),
                          )
                        : null,
                  );
                }
                return PageEmptyView();
              }
              return Container();
            },
          ),
        );
      }
      return Container();
    });
  }
}

class ExchangeReturnDialog extends StatefulWidget {
  final Function onSelect;
  ExchangeReturnDialog({@required this.onSelect});
  @override
  _ExchangeReturnDialogState createState() => _ExchangeReturnDialogState();
}

class _ExchangeReturnDialogState extends State<ExchangeReturnDialog> {
  var selectedVal;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(
          L10n().getStr('orderDetails.choose'),
          style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
        ),
        SizedBox(
          height: Spacing.space20,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedVal = 'exchange';
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                boxShadow: selectedVal == 'exchange'
                    ? [
                        BoxShadow(
                          color: ColorShades.darkGreenBg,
                          offset: Offset(-3, 5),
                          blurRadius: 6,
                        )
                      ]
                    : null,
                border: Border.all(color: ColorShades.greenBg),
                borderRadius: BorderRadius.circular(20),
                color: selectedVal == 'exchange'
                    ? ColorShades.greenBg
                    : ColorShades.white),
            child: Center(
                child: Text(L10n().getStr('orderDetails.exchange'),
                    style: theme.textTheme.body1Bold.copyWith(
                      color: selectedVal == 'exchange'
                          ? ColorShades.white
                          : ColorShades.greenBg,
                    ))),
          ),
        ),
        SizedBox(
          height: Spacing.space20,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedVal = 'return';
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                boxShadow: selectedVal == 'return'
                    ? [
                        BoxShadow(
                          color: ColorShades.darkGreenBg,
                          offset: Offset(-3, 5),
                          blurRadius: 6,
                        )
                      ]
                    : null,
                border: Border.all(color: ColorShades.greenBg),
                borderRadius: BorderRadius.circular(20),
                color: selectedVal == 'return'
                    ? ColorShades.greenBg
                    : ColorShades.white),
            child: Center(
                child: Text(L10n().getStr('orderDetails.return'),
                    style: theme.textTheme.body1Bold.copyWith(
                      color: selectedVal == 'return'
                          ? ColorShades.white
                          : ColorShades.greenBg,
                    ))),
          ),
        ),
        SizedBox(
          height: Spacing.space24,
        ),
        PrimaryButton(
            disabled: selectedVal == null,
            onPressed: () {
              widget.onSelect(selectedVal);
            },
            text: L10n().getStr('app.confirm')),
      ],
    );
  }
}
