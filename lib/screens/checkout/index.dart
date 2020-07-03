import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/checkbox_list.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Checkout extends StatefulWidget {
  final double amount;
  Checkout({@required this.amount});
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Map address;
  String paymentMethod;
  var currentUser;
  ThemeData theme;
  Razorpay _razorpay;
  List paymentMethodOptions;
  @override
  void initState() {
    paymentMethodOptions = paymentOptions;
    paymentMethod = paymentMethodOptions[0]['value'];
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder();
    // showCustomSnackbar(
    //     context: context, type: SnackbarType.success, content: 'Success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showCustomSnackbar(
        context: context, type: SnackbarType.error, content: 'Error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showCustomSnackbar(
        context: context, type: SnackbarType.error, content: 'Wallet');
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void paymentChangeHandler(value) {
    setState(() {
      paymentMethod = value;
    });
  }

  Widget getAddressBox() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.location_on, color: ColorShades.greenBg),
                SizedBox(
                  width: Spacing.space8,
                ),
                Text(
                  L10n().getStr('checkout.deliverTo') + ' : ',
                  style: theme.textTheme.body1Bold
                      .copyWith(color: ColorShades.greenBg),
                ),
                Text(
                  L10n().getStr('profile.address.type.' + address['type']),
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.greenBg),
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                if (address['is_default'] == true)
                  Text(
                    '(' + L10n().getStr('address.default') + ')',
                    style: theme.textTheme.body1Regular.copyWith(
                        fontStyle: FontStyle.italic,
                        color: ColorShades.greenBg),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                dynamic result = await Navigator.pushNamed(
                    context, Constants.ADDRESS_LIST,
                    arguments: {'selectView': true});
                if (result != null && result is Map) {
                  setState(() {
                    address = result;
                  });
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: Spacing.space8, horizontal: Spacing.space12),
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorShades.greenBg),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    L10n().getStr('checkout.change'),
                    style: theme.textTheme.body2Regular
                        .copyWith(color: ColorShades.greenBg),
                  )),
            ),
          ],
        ),
        SizedBox(
          height: Spacing.space8,
        ),
        Text(
          address['address_text'],
          style:
              theme.textTheme.body1Regular.copyWith(color: ColorShades.greenBg),
        )
      ],
    );
  }

  Widget getPaymentOptions() {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              L10n().getStr('checkout.paymentOption'),
              style: theme.textTheme.pageTitle
                  .copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space16,
            ),
            Expanded(
              child: CheckboxList(
                items: paymentMethodOptions,
                selectedValue: paymentMethod,
                changeHandler: paymentChangeHandler,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void placeOrder() {
    var phoneNumber = currentUser[KeyNames['phone']];
    var userName = currentUser[KeyNames['userName']];
    var orderAddress = address;
    var amount = widget.amount;
    var orderPaymentMethod = paymentMethodOptions
        .firstWhere((item) => item['value'] == paymentMethod);
    var cartItems = currentUser[KeyNames['cart']];
    var orderId = Utilities.getOrderId(userName);
    var userId = currentUser[KeyNames['userId']];
    var orderDetails = {
      'phoneNumber': phoneNumber,
      'address': orderAddress,
      'amount': amount,
      'paymentMethod': orderPaymentMethod,
      'cart': cartItems,
      'orderId': orderId,
      'status':KeyNames['orderPlaced'],
      'userId':userId,
    };
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(PlaceOrder(orderDetails: orderDetails));
    showCustomLoader(context, text: L10n().getStr('checkout.placingOrder'));
  }

  void makePaymentAndPlaceOrder() {
    if (paymentMethod == 'cod') {
      placeOrder();
    } else if (paymentMethod == 'razorpay') {
      _razorpay.open(razorpayOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
      var currentState = state['userstate'];
      if (currentState is UserIsUser) {
        currentUser = currentState.user;
        List addressList = currentUser[KeyNames['address']];
        if (address == null)
          address =
              addressList.firstWhere((item) => item['is_default'] == true);
        return SafeArea(
          child: Scaffold(
            appBar: MyAppBar(
              hasTransparentBackground: true,
              title: L10n().getStr('checkout.checkout'),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: Spacing.space24,
                  ),
                  getAddressBox(),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  getPaymentOptions(),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                height: 70,
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.space16, vertical: Spacing.space12),
                decoration: BoxDecoration(
                    color: ColorShades.white, boxShadow: [Shadows.cardLight]),
                child: PrimaryButton(
                  text: L10n().getStr('checkout.placeOrder'),
                  onPressed: () {
                    makePaymentAndPlaceOrder();
                  },
                ),
              ),
            ),
          ),
        );
      }
      return Container();
    });
  }
}
