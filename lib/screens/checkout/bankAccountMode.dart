import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class BankAccountPaymentMode extends StatefulWidget {
  final Map paymentMode;
  final bool isExpanded;
  BankAccountPaymentMode({@required this.paymentMode, this.isExpanded = false});
  @override
  _BankAccountPaymentModeState createState() => _BankAccountPaymentModeState();
}

class _BankAccountPaymentModeState extends State<BankAccountPaymentMode> {
  ThemeData theme;
  getBankCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
      child: Container(
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
              L10n().getStr('payments.bank'),
              style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space8,
            ),
            RichText(
              text: TextSpan(
                  text: L10n().getStr('payments.accountNumber') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: widget.paymentMode['accountNumber'],
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
                  text: L10n().getStr('payments.accountHoldersName') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: widget.paymentMode['nameOnAccount'],
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
                  text: L10n().getStr('payments.routingNumber') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: widget.paymentMode['routingNumber'],
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
                  text: L10n().getStr('payments.accountType') + ": ",
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                  children: [
                    TextSpan(
                      text: widget.paymentMode['accountType'].toUpperCase(),
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  ]),
            ),
            SizedBox(
              height: Spacing.space4,
            ),
            if (widget.paymentMode['bankName'] != null)
              RichText(
                text: TextSpan(
                    text: L10n().getStr('payments.bankName') + ": ",
                    style:
                        theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                    children: [
                      TextSpan(
                        text: widget.paymentMode['bankName'],
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ]),
              ),
            if (widget.paymentMode['bankName'] != null)
              SizedBox(
                height: Spacing.space4,
              ),
            SizedBox(
              height: Spacing.space4,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    if (widget.isExpanded) {
      return getBankCard();
    }
    return RichText(
      text: TextSpan(
          text: L10n().getStr('payments.bankAccountEndingIn') + ': ',
          style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
          children: [
            TextSpan(
                text: widget.paymentMode['accountNumber'],
                style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg))
          ]),
    );
  }
}
