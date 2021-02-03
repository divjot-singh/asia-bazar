import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/events.dart';
import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/item_database_bloc/bloc.dart';
import 'package:asia/blocs/item_database_bloc/event.dart';
import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/events.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/repository/payment_repo.dart';
import 'package:asia/screens/checkout/bankAccountMode.dart';
import 'package:asia/screens/checkout/creditCardMode.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/checkbox_list.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/custom_dialog.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/network_manager.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:asia/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia/theme/style.dart';

class Checkout extends StatefulWidget {
  final double amount, pointsUsed, actualAmount;
  final bool areLoyaltyPointsUsed;
  Checkout(
      {@required this.amount,
      this.areLoyaltyPointsUsed = false,
      this.actualAmount,
      this.pointsUsed = 0});
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Map address;
  var rzpPaymentId;
  String paymentMethod;
  var currentUser;
  ThemeData theme;

  bool itemsOutOfStock = false, allowPop = true;
  List paymentMethodOptions, additionalPaymentMethods = [];
  double pointValue = 0;
  var orderId;
  bool loadingPaymentMethods = true;
  String transactionId;
  @override
  void initState() {
    BlocProvider.of<GlobalBloc>(context).add(FetchSellerInfo(callback: (info) {
      setState(() {});
    }));
    fetchPaymentProfiles();
    paymentMethodOptions = paymentOptions;
    paymentMethod = paymentMethodOptions[0]['value'];
    super.initState();
  }

  fetchPaymentProfiles() async {
    var userState =
        BlocProvider.of<UserDatabaseBloc>(context).state['userstate'];
    if (userState is UserIsUser) {
      String paymentId = userState.user[KeyNames['customerPaymentId']];
      var response =
          await PaymentRepository.fetchPaymentProfiles(paymentId: paymentId);
      setState(() {
        loadingPaymentMethods = false;
      });
      if (response['success'] == true) {
        var modesList = response['data'].toList();

        setState(() {
          additionalPaymentMethods = modesList;
          paymentMethod = modesList[0]['customerPaymentProfileId'];
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void paymentChangeHandler(value) {
    setState(() {
      paymentMethod = value;
    });
  }

  Widget getAddressBox() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
      child: Column(
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
            style: theme.textTheme.body1Regular
                .copyWith(color: ColorShades.greenBg),
          )
        ],
      ),
    );
  }

  Widget getPaymentOptions() {
    if (loadingPaymentMethods) {
      return Padding(
        padding: const EdgeInsets.only(top: Spacing.space32),
        child: PageFetchingViewWithLightBg(),
      );
    }
    var additionalMethods = additionalPaymentMethods.map((mode) {
      Map paymentModeObject = {};
      paymentModeObject['value'] = mode['customerPaymentProfileId'];
      if (mode['payment'] != null) {
        if (mode['payment']['bankAccount'] != null) {
          paymentModeObject['widget'] = BankAccountPaymentMode(
            paymentMode: mode['payment']['bankAccount'],
            isExpanded: paymentMethod == mode['customerPaymentProfileId'],
          );
        } else if (mode['payment']['creditCard'] != null) {
          paymentModeObject['widget'] = CreditCardMode(
            paymentMode: mode['payment']['creditCard'],
          );
        } else {
          paymentModeObject = null;
        }
      } else {
        paymentModeObject = null;
      }
      return paymentModeObject;
    });
    var options = [...additionalMethods, ...paymentMethodOptions];
    options.removeWhere((item) => item == null || item['value'] == 'points');
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
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
                items: options,
                selectedValue: paymentMethod,
                changeHandler: paymentChangeHandler,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void placeOrder({dynamic currentPaymentMethod}) async {
    var globalBlocState =
        BlocProvider.of<GlobalBloc>(context).state['sellerInfo'];
    if (globalBlocState is InfoFetchedState) {
      pointValue = globalBlocState.sellerInfo['loyalty_point_value'];
    }
    var phoneNumber = currentUser[KeyNames['phone']];
    var userName = currentUser[KeyNames['userName']];
    var orderAddress = address;
    var amount = widget.amount;
    var orderPaymentMethod;
    if (currentPaymentMethod != null) {
      orderPaymentMethod = {};
      orderPaymentMethod['value'] = currentPaymentMethod['type'];
      if (currentPaymentMethod['type'] == 'card') {
        String cardDetails = currentPaymentMethod['cardNumber'],
            maskedString =
                cardDetails.replaceRange(0, cardDetails.length - 4, 'XXXX');
        orderPaymentMethod['title'] = 'Card- $maskedString';
      } else if (currentPaymentMethod['type'] == 'bank') {
        String bankDetails = currentPaymentMethod['accountNo'],
            maskedString =
                bankDetails.replaceRange(0, bankDetails.length - 4, 'XXXX');
        orderPaymentMethod['title'] = 'Bank account- $maskedString';
      }
    } else {
      var options = [...paymentMethodOptions, ...additionalPaymentMethods];
      orderPaymentMethod = options.firstWhere((item) {
        if (item['customerPaymentProfileId'] != null) {
          return item['customerPaymentProfileId'] == paymentMethod;
        } else {
          return item['value'] ==
              (widget.amount == 0 ? 'points' : paymentMethod);
        }
      }, orElse: () => null);
      if (orderPaymentMethod['value'] == null) {
        var value, title;
        if (orderPaymentMethod['payment'] != null) {
          if (orderPaymentMethod['payment']['creditCard'] != null) {
            value = 'creditCard';
            title =
                'Card- ${orderPaymentMethod['payment']['creditCard']['cardNumber']}';
          } else if (orderPaymentMethod['payment']['bankAccount'] != null) {
            value = 'bankAccount';
            title =
                'Bank account- ${orderPaymentMethod['payment']['bankAccount']['accountNumber']}';
          }
        }
        orderPaymentMethod = {};
        orderPaymentMethod['title'] = title;
        orderPaymentMethod['value'] = value;
      }
    }
    Map cartItems = {...currentUser[KeyNames['cart']]};

    ///cartItems.removeWhere((key, item) => item['quantity'] < 1);
    orderId = Utilities.getOrderId(userName);
    var userId = await StorageManager.getItem(KeyNames['userId']);
    var orderDetails = {
      'phoneNumber': phoneNumber,
      'address': orderAddress,
      'amount':
          widget.actualAmount != null ? widget.actualAmount : widget.amount,
      'paymentMethod': orderPaymentMethod,
      'cart': cartItems,
      'orderId': orderId,
      'status': KeyNames['orderPlaced'],
      'userId': userId,
      'areLoyaltyPointsUsed': widget.areLoyaltyPointsUsed,
      'pointsUsed': widget.pointsUsed,
      'points': pointValue != null ? pointValue * amount : 0
    };
    if (transactionId != null) {
      orderDetails['transactionId'] = transactionId;
    }
    BlocProvider.of<ItemDatabaseBloc>(context).add(
        PlaceOrder(orderDetails: orderDetails, callback: placeOrderCallback));
    showCustomLoader(context, text: L10n().getStr('checkout.placingOrder'));
  }

  void placeOrderCallback(result) {
    Navigator.pop(context);
    if (result == true) {
      BlocProvider.of<UserDatabaseBloc>(context).add(EmptyCart());
      if (orderId != null) {
        Navigator.pushNamedAndRemoveUntil(
            context,
            Constants.ORDER_DETAILS.replaceAll(':orderId', orderId),
            (route) => route.isFirst);
      } else
        showCustomSnackbar(
            context: context, content: 'Success', type: SnackbarType.success);

      //todo order placed, take to order details page
    } else if (result is Map) {
      setState(() {
        itemsOutOfStock = true;
      });
      processRefund();
      showCustomDialog(
        context: context,
        heading: '',
        child: Container(
          child: Column(
            children: <Widget>[
              Text(
                L10n().getStr('checkout.itemOutOfStock'),
                style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Spacing.space20,
              ),
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {'refresh': true});
                },
                text: L10n().getStr('redirector.goBack'),
              ),
            ],
          ),
        ),
      );
    } else {
      processRefund();
      showCustomSnackbar(
          context: context,
          content: L10n().getStr('profile.address.error') +
              '.' +
              L10n().getStr('cart.refundProcessing'),
          type: SnackbarType.error);
    }
  }

  void processRefund() async {
    if (paymentMethod != 'cod' && transactionId != null) {
      var response =
          await PaymentRepository.voidTransaction(transactionId: transactionId);
      if (response['success'] == true) {
        showCustomSnackbar(
            type: SnackbarType.success,
            context: context,
            content: L10n().getStr('payments.refundSuccess'));
      } else {
        showCustomSnackbar(
            type: SnackbarType.error,
            context: context,
            duration: 2,
            content: L10n().getStr('payments.refundFailed'));
      }
    }
  }

  void makePaymentFromPaymentProfile() async {
    if (currentUser != null) {
      var customerId = currentUser[KeyNames['customerPaymentId']];
      Map<String, String> paymentData = {};
      paymentData['customerProfileId'] = customerId;
      paymentData['customerPaymentProfileId'] = paymentMethod;
      paymentData['amount'] = widget.amount.toString();
      setState(() {
        allowPop = false;
      });
      showCustomLoader(context,
          text: L10n().getStr('payments.makingPayment'),
          willPop: () async => false);
      dynamic response = await PaymentRepository.makePaymentFromPaymentProfile(
          paymentData: paymentData);
      Navigator.pop(context);
      if (response['success'] == true) {
        transactionId = response['transactionId'];
        placeOrder();
      } else {
        setState(() {
          allowPop = true;
        });
        showCustomSnackbar(
            type: SnackbarType.error,
            context: context,
            content: response['message'] != null
                ? response['message']
                : L10n().getStr('payments.error'));
      }
    }
  }

  void makePaymentAndPlaceOrder() async {
    if (paymentMethod == 'cod' || widget.amount == 0) {
      placeOrder();
    } else if (paymentMethod == 'newBank' || paymentMethod == 'newCard') {
      dynamic result = await Navigator.pushNamed(
          context, Constants.MAKE_PAYMENT,
          arguments: {'amount': widget.amount, 'paymentMethod': paymentMethod});
      if (result is Map && result['success'] == true) {
        transactionId = result['transactionId'];
        placeOrder(currentPaymentMethod: result['paymentData']);
      }
    } else {
      makePaymentFromPaymentProfile();
    }
  }

  Widget getAmountBanner() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: Spacing.space12),
      color: ColorShades.greenBg,
      child: Center(
        child: Text(
          L10n()
              .getStr('checkout.amount', {'amount': widget.amount.toString()}),
          style: theme.textTheme.h4.copyWith(color: ColorShades.white),
        ),
      ),
    );
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
        return WillPopScope(
          onWillPop: allowPop ? null : () async => false,
          child: SafeArea(
            child: Scaffold(
              appBar: MyAppBar(
                hasTransparentBackground: true,
                title: L10n().getStr('checkout.checkout'),
                leading: {
                  'icon': Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_back, color: ColorShades.green),
                  ),
                  'onTap': (context) {
                    if (itemsOutOfStock) {
                      Navigator.pop(context, {'refresh': true});
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
              body: Column(
                children: <Widget>[
                  SizedBox(
                    height: Spacing.space24,
                  ),
                  getAddressBox(),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  getAmountBanner(),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  getPaymentOptions(),
                ],
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
                    disabled: !(currentUser[KeyNames['cart']] is Map &&
                            currentUser[KeyNames['cart']].length > 0) ||
                        loadingPaymentMethods,
                    onPressed: () {
                      makePaymentAndPlaceOrder();
                    },
                  ),
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
