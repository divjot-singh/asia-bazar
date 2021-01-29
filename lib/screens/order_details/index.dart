import 'package:asia/blocs/global_bloc/bloc.dart';
import 'package:asia/blocs/global_bloc/state.dart';
import 'package:asia/blocs/order_bloc/bloc.dart';
import 'package:asia/blocs/order_bloc/event.dart';
import 'package:asia/blocs/order_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/bottom_sheet.dart';
import 'package:asia/shared_widgets/custom_dialog.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/page_views.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/shared_widgets/timeline.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  final String orderId;
  OrderDetails({@required this.orderId});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  ThemeData theme;
  String sellerPhoneNumber;
  List statusChronology = [
    KeyNames['orderPlaced'],
    KeyNames['orderApproved'],
    KeyNames['orderDispatched'],
    KeyNames['orderDelivered']
  ];
  bool returnAvailable = false;
  @override
  void initState() {
    BlocProvider.of<OrderDetailsBloc>(context)
        .add(FetchOrderDetails(orderId: widget.orderId));
    super.initState();
  }

  // void fetchInfoCallback(data) {
  //   if (data is Map && data['phoneNumber'] != null) {
  //     setState(() {
  //       sellerPhoneNumber = data['phoneNumber'];
  //     });
  //   }
  // }

  Widget getHeader(Map details) {
    var imageUrl;
    if (details['status'] == KeyNames['orderPlaced'])
      imageUrl = 'assets/images/order_placed.png';
    if (details['status'] == KeyNames['orderApproved'])
      imageUrl = 'assets/images/order_approved.png';
    if (details['status'] == KeyNames['orderDispatched'])
      imageUrl = 'assets/images/order_dispatched.png';
    if (details['status'] == KeyNames['orderDelivered'])
      imageUrl = 'assets/images/order_delivered.png';
    if (details['status'] == KeyNames['orderCancelled'])
      imageUrl = 'assets/images/order_cancelled.png';
    if (details['status'] == KeyNames['orderReturnRequested'] ||
        details['status'] == KeyNames['orderReturnRejected'] ||
        details['status'] == KeyNames['orderReturnApproved'])
      imageUrl = 'assets/images/order_delivered.png';
    if (imageUrl != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Image.asset(
          imageUrl,
          height: 200,
          width: 200,
        ),
      );
    }
    return Container();
  }

  Widget orderLifecycle(Map details) {
    bool placed = statusChronology.indexOf(details['status']) == 0;
    bool approved = statusChronology.indexOf(details['status']) > 0;
    bool dispatched = statusChronology.indexOf(details['status']) > 1;
    List timeline = [
      {
        'selected': true,
        'placeHolder': Text(
          L10n().getStr('order.placed'),
          style: theme.textTheme.body1Regular
              .copyWith(color: ColorShades.bastille),
        ),
      },
      {
        'selected': approved,
        'placeHolder': Text(
          placed & !approved
              ? L10n().getStr('order.${KeyNames['orderApproved']}.waiting')
              : L10n().getStr('order.${KeyNames['orderApproved']}'),
          style: placed & !approved
              ? theme.textTheme.h4.copyWith(color: ColorShades.bastille)
              : theme.textTheme.body1Regular
                  .copyWith(color: ColorShades.bastille),
        ),
      },
      {
        'selected': dispatched,
        'placeHolder': Text(
          approved & !dispatched
              ? L10n().getStr('order.${KeyNames['orderDispatched']}.waiting')
              : L10n().getStr('order.${KeyNames['orderDispatched']}'),
          style: approved & !dispatched
              ? theme.textTheme.h4.copyWith(color: ColorShades.bastille)
              : theme.textTheme.body1Regular.copyWith(
                  color: placed && !approved
                      ? ColorShades.grey300
                      : ColorShades.bastille),
        )
      },
      {
        'selected': false,
        'placeHolder': Text(
            L10n().getStr('order.${KeyNames['orderDelivered']}.waiting'),
            style: dispatched
                ? theme.textTheme.h4.copyWith(color: ColorShades.bastille)
                : theme.textTheme.body1Regular
                    .copyWith(color: ColorShades.grey300)),
      }
    ];
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: Spacing.space16, vertical: Spacing.space12),
        margin: EdgeInsets.only(bottom: Spacing.space12),
        child: Timeline(items: timeline));
  }

  Widget returnExchangeBanner(details) {
    // Timestamp timestamp = details['deliveryTimestamp'] != null
    //     ? details['deliveryTimestamp']
    //     : details['timestamp'];
    // DateTime time =
    //     DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    // time = time.add(Duration(days: ORDER_RETURN_THRESHOLD_IN_DAYS));
    // String timeToShow =
    //     DateFormatter.formatWithTime(time.millisecondsSinceEpoch.toString());
    // if (!returnAvailable)
    //   return Container();
    // else
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: Spacing.space12),
      color: ColorShades.greenBg,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.space16,
        vertical: Spacing.space12,
      ),
      child: Center(
        child: Text(
          L10n().getStr('orderDetails.cashBanner',
              {'amount': details['amount'].toString()}),
          textAlign: TextAlign.center,
          style: theme.textTheme.h3.copyWith(color: ColorShades.white),
        ),
      ),
    );
  }

  Widget orderInfo(details) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: Spacing.space12),
        decoration: BoxDecoration(
          border: Border.all(color: ColorShades.greenBg),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: Spacing.space8, vertical: Spacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              L10n().getStr('orderDetails.orderInfo'),
              style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space8,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('profile.address') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: details['address']['address_text'],
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('orderDetails.placedOn') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: DateFormatter.formatWithTime(details['timestamp']
                          .millisecondsSinceEpoch
                          .toString()),
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('orderDetails.deliveredOn') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: DateFormatter.formatWithTime(details[
                              details['deliveryTimestamp'] != null
                                  ? 'deliveryTimestamp'
                                  : 'timestamp']
                          .millisecondsSinceEpoch
                          .toString()),
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('orderDetails.paymentMethod') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: details['paymentMethod']['title'],
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('orderDetails.orderAmount') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text:
                          '\$ ${details['finalAmount'] != null ? details['finalAmount'].toString() : details['amount'].toString()}',
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            Row(
              children: <Widget>[
                Text(
                  L10n().getStr('orderDetails.itemDetails') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Constants.ORDER_ITEM_DETAILS
                          .replaceAll(":orderId", widget.orderId)
                          .replaceAll(
                              ":amount",
                              details['finalAmount'] != null
                                  ? details['finalAmount'].toString()
                                  : details['amount'].toString()),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        L10n().getStr('app.seeDetails'),
                        style: theme.textTheme.body2Regular
                            .copyWith(color: ColorShades.neon),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 8, color: ColorShades.neon),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: Spacing.space4,
            ),
          ],
        ),
      ),
    );
  }

  Widget detailsBody(details) {
    bool showLifeCycle = statusChronology.indexOf(details['status']) < 3 &&
        statusChronology.indexOf(details['status']) > -1;

    // bool delivered = statusChronology.indexOf(details['status']) > 2;
    // var noCancellationOrders = [
    //   KeyNames['orderDelivered'],
    //   KeyNames['orderCancelled'],
    //   KeyNames['orderReturnApproved'],
    //   KeyNames['orderReturnRejected']
    // ];

    // // Timestamp timestamp = details['deliveryTimestamp'] != null
    // //     ? details['deliveryTimestamp']
    // //     : details['timestamp'];
    // // if (timestamp != null && delivered) {
    // //   var today = DateTime.now().millisecondsSinceEpoch;
    // //   var diff = DateFormatter.findDifferenceMilliSeconds(
    // //       today, timestamp.millisecondsSinceEpoch);
    // //   if (diff['days'] != null &&
    // //       diff['days'] < ORDER_RETURN_THRESHOLD_IN_DAYS) {
    // //     returnAvailable = true;
    // //   } else
    // //     returnAvailable = false;
    // // } else
    // //   returnAvailable = false;
    // // bool cancellationAvailable =
    // //     !(noCancellationOrders.indexOf(details['status']) > -1);
    var optionsList = [];
    optionsList.add({
      'onTap': () {
        var globalBlocState =
            BlocProvider.of<GlobalBloc>(context).state['sellerInfo'];
        if (globalBlocState is InfoFetchedState) {
          sellerPhoneNumber = globalBlocState.sellerInfo['phoneNumber'];
        }
        contactSeller(context: context, phoneNumber: sellerPhoneNumber);
      },
      'text': L10n().getStr('orderDetails.contactSeller')
    });
    bool showCashBanner = details['paymentMethod']['value'] == 'cod' &&
        statusChronology.indexOf(details['status']) == 2;
    // if (cancellationAvailable)
    //   optionsList.add({
    //     'onTap': () {
    //       //do something
    //     },
    //     'text': L10n().getStr('orderDetails.requestCancellation')
    //   });
    // if (returnAvailable)
    //   optionsList.add({
    //     'onTap': () {
    //       Navigator.pushNamed(
    //           context,
    //           Constants.ORDER_ITEM_DETAILS
    //               .replaceAll(":orderId", widget.orderId)
    //               .replaceAll(":editView", "true"));
    //     },
    //     'text': L10n().getStr('orderDetails.returnExchange')
    //   });
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('orderDetails.heading'),
          rightAction: {
            'icon': Icon(Icons.more_vert),
            'onTap': () {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return BottomSheetModal(
                      context: context,
                      sheetItems: optionsList,
                    );
                  });
            }
          },
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: Spacing.space16,
                ),
                getHeader(details),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
                  child: Text(
                    L10n().getStr('order.${details['status']}.info'),
                    textAlign: TextAlign.center,
                    style:
                        theme.textTheme.h2.copyWith(color: ColorShades.greenBg),
                  ),
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                if (showCashBanner) returnExchangeBanner(details),
                if (showLifeCycle) orderLifecycle(details),
                orderInfo(details),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocBuilder<OrderDetailsBloc, Map>(
      builder: (context, currentState) {
        var state = currentState['orderState'];

        if (state is GlobalFetchingState) {
          return Scaffold(
              backgroundColor: ColorShades.white,
              body: PageFetchingViewWithLightBg());
        } else if (state is GlobalErrorState) {
          return PageErrorView();
        } else if (state is OrderFetchedState) {
          if (state.orderDetails.length == 0) {
            return PageEmptyView();
          } else {
            var stream = state.orderDetails;
            if (stream is Stream<DocumentSnapshot>) {
              return StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return detailsBody(snapshot.data.data);
                  else
                    return Container();
                },
              );
            } else {
              return detailsBody(stream);
            }
          }
        }
        return Container();
      },
    );
  }
}

void contactSeller({String phoneNumber, BuildContext context}) {
  ThemeData theme = Theme.of(context);
  try {
    launch("tel://$phoneNumber");
  } catch (e) {
    showCustomDialog(
      context: context,
      heading: '',
      child: Container(
        child: Column(
          children: <Widget>[
            Text(
              L10n().getStr('contactSeller.error.info'),
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: Spacing.space20,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: phoneNumber),
                ).then((_) {
                  Navigator.pop(context);
                  showCustomSnackbar(
                      type: SnackbarType.success,
                      context: context,
                      content: L10n().getStr('contactSeller.copied'));
                });
              },
              child: InputBox(
                hideShadow: true,
                disabled: true,
                onChanged: (_) {},
                value: phoneNumber,
                suffixIcon: Icon(Icons.content_copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
