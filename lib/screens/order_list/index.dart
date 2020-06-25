import 'package:asia/l10n/l10n.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('myOrders.heading'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/no_orders.png'),
              SizedBox(
                height: Spacing.space20,
              ),
              Text(
                L10n().getStr('myOrders.noOrders'),
                textAlign: TextAlign.center,
                style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
