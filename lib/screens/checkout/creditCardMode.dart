import 'package:asia/screens/paymentScreen/CardPayment/cardUtils.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class CreditCardMode extends StatelessWidget {
  final Map paymentMode;
  CreditCardMode({@required this.paymentMode});
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Row(
      children: [
        CardUtils.getCardIconFromCardType(paymentMode['cardType'], height: 20),
        SizedBox(
          width: Spacing.space4,
        ),
        Text(
          paymentMode['cardNumber'],
          style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
        ),
      ],
    );
  }
}
