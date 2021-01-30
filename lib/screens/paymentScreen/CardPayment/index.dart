import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/paymentScreen/CardPayment/cardUtils.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class CardPayment extends StatefulWidget {
  CardPayment({Key key, @required this.onSubmitData}) : super(key: key);
  final Function onSubmitData;

  @override
  _CardPaymentState createState() => new _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();

  ThemeData theme;
  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  bool isValidForm() {
    if (_paymentCard.name == null ||
        _paymentCard.number == null ||
        _paymentCard.cvv == null ||
        _paymentCard.year == null ||
        _paymentCard.month == null) {
      return false;
    }
    return _paymentCard.name.isNotEmpty &&
        CardUtils.validateCardNum(_paymentCard.number) == null &&
        CardUtils.validateCVV(_paymentCard.cvv.toString()) == null &&
        CardUtils.validateDate(_paymentCard.month.toString() +
                '/' +
                _paymentCard.year.toString()) ==
            null;
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(Spacing.space16),
        child: new Form(
            key: _formKey,
            child: new ListView(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.nameOnCard'),
                      style: theme.textTheme.h3
                          .copyWith(color: ColorShades.greenBg),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: theme.textTheme.h2
                                .copyWith(color: ColorShades.redOrange)),
                      ]),
                ),
                SizedBox(height: Spacing.space16),
                InputBox(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (String value) {
                    setState(() {
                      _paymentCard.name = value;
                    });
                  },
                  hintText: L10n().getStr('payments.holdersName'),
                  hideShadow: true,
                  keyboardType: TextInputType.text,
                  validator: (String value) => value.isEmpty
                      ? L10n().getStr('onboarding.name.error')
                      : null,
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.cardNumber'),
                      style: theme.textTheme.h3
                          .copyWith(color: ColorShades.greenBg),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: theme.textTheme.h2
                                .copyWith(color: ColorShades.redOrange)),
                      ]),
                ),
                SizedBox(height: Spacing.space16),
                InputBox(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  hideShadow: true,
                  hintText: L10n().getStr('payments.cardNumber'),
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(19),
                    new CardNumberInputFormatter()
                  ],
                  onChanged: (String value) {
                    setState(() {
                      _paymentCard.number = CardUtils.getCleanedNumber(value);
                    });
                  },
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardUtils.getCardIcon(_paymentCard.type),
                  ),
                  validator: CardUtils.validateCardNum,
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.cvvNumber'),
                      style: theme.textTheme.h3
                          .copyWith(color: ColorShades.greenBg),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: theme.textTheme.h2
                                .copyWith(color: ColorShades.redOrange)),
                      ]),
                ),
                SizedBox(height: Spacing.space16),
                InputBox(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  hideShadow: true,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(4),
                  ],
                  validator: CardUtils.validateCVV,
                  onChanged: (value) {
                    setState(() {
                      _paymentCard.cvv = int.parse(value);
                    });
                  },
                  hintText: L10n().getStr('payments.cvvNumber.hint'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/card_cvv.png',
                      width: 20.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.expiryDate'),
                      style: theme.textTheme.h3
                          .copyWith(color: ColorShades.greenBg),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: theme.textTheme.h2
                                .copyWith(color: ColorShades.redOrange)),
                      ]),
                ),
                SizedBox(height: Spacing.space16),
                InputBox(
                  hideShadow: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(4),
                    new CardMonthInputFormatter()
                  ],
                  hintText: L10n().getStr('payments.expiryDate.hint'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/calender.png',
                      width: 20.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  validator: CardUtils.validateDate,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    List<int> expiryDate = CardUtils.getExpiryDate(value);

                    setState(() {
                      _paymentCard.month = expiryDate[0];
                      _paymentCard.year = expiryDate[1];
                    });
                  },
                ),
                SizedBox(
                  height: Spacing.space12,
                )
                //done
              ],
            )),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.space16, vertical: Spacing.space12),
          decoration: BoxDecoration(
              color: ColorShades.white, boxShadow: [Shadows.cardLight]),
          child: PrimaryButton(
            text: L10n().getStr('payments.makePayment'),
            disabled: !isValidForm(),
            onPressed: () {
              Map data = {};
              data['accountHolderName'] = _paymentCard.name;
              data['cardNumber'] = _paymentCard.number.split(" ").join("");
              data['expiryDate'] =
                  _paymentCard.month.toString() + _paymentCard.year.toString();
              data['cardCode'] = _paymentCard.cvv.toString();
              data['type'] = 'card';
              widget.onSubmitData(data);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }
}
