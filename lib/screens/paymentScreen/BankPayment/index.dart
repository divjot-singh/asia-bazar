import 'package:asia/l10n/l10n.dart';
import 'package:asia/screens/paymentScreen/BankPayment/bankUtils.dart';
import 'package:asia/shared_widgets/input_box.dart';
import 'package:asia/shared_widgets/primary_button.dart';
import 'package:asia/shared_widgets/select.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class BankPayment extends StatefulWidget {
  BankPayment({Key key, @required this.onSubmitData}) : super(key: key);
  final Function onSubmitData;

  @override
  _BankPaymentState createState() => new _BankPaymentState();
}

class _BankPaymentState extends State<BankPayment> {
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _bankDetails = BankDetails();

  ThemeData theme;
  @override
  void initState() {
    super.initState();
    _bankDetails.bankType = BankType.saving;
  }

  bool isValidForm() {
    if (_bankDetails.bankAccountHoldersName == null ||
        _bankDetails.accountNumber == null ||
        _bankDetails.bankType == null ||
        _bankDetails.routingNumber == null) {
      return false;
    }

    return _bankDetails.bankAccountHoldersName.isNotEmpty &&
        BankUtils.validateAccountNumber(_bankDetails.accountNumber) == null &&
        BankUtils.validateRoutingNumber(_bankDetails.routingNumber) == null;
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
                    text: L10n().getStr('payments.bankName'),
                    style:
                        theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
                  ),
                ),
                SizedBox(height: Spacing.space16),
                InputBox(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (String value) {
                    setState(() {
                      _bankDetails.bankName = value;
                    });
                  },
                  hintText: L10n().getStr('payments.bankName'),
                  hideShadow: true,
                  keyboardType: TextInputType.text,
                  validator: (String value) => value.isEmpty
                      ? L10n().getStr('onboarding.name.error')
                      : null,
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.accountHoldersName'),
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
                      _bankDetails.bankAccountHoldersName = value;
                    });
                  },
                  hintText: L10n().getStr('payments.accountHoldersName'),
                  hideShadow: true,
                  keyboardType: TextInputType.text,
                  validator: (String value) => value.isEmpty
                      ? L10n().getStr('onboarding.name.error')
                      : null,
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.accountNumber'),
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
                  hintText: L10n().getStr('payments.accountNumber'),
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(17),
                  ],
                  onChanged: (String value) {
                    setState(() {
                      _bankDetails.accountNumber = value;
                    });
                  },
                  validator: BankUtils.validateAccountNumber,
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.routingNumber'),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(9),
                  ],
                  validator: BankUtils.validateRoutingNumber,
                  onChanged: (value) {
                    setState(() {
                      _bankDetails.routingNumber = value;
                    });
                  },
                  hintText: L10n().getStr('payments.routingNumber'),
                ),
                SizedBox(height: Spacing.space16),
                RichText(
                  text: TextSpan(
                      text: L10n().getStr('payments.accountType'),
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
                BaseDropdownInput(
                  value: _bankDetails.bankType,
                  onChanged: (value) {
                    setState(() {
                      _bankDetails.bankType = value;
                    });
                  },
                  list: [
                    BaseDropDownInputMenuItem(
                        id: BankType.saving,
                        name: L10n().getStr('payments.accountType.saving')),
                    BaseDropDownInputMenuItem(
                        id: BankType.checking,
                        name: L10n().getStr('payments.accountType.checking')),
                    BaseDropDownInputMenuItem(
                        id: BankType.businessChecking,
                        name: L10n()
                            .getStr('payments.accountType.businessChecking')),
                  ],
                ),
                SizedBox(
                  height: 10,
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
              data['bankName'] = _bankDetails.bankName;
              data['accountHolderName'] = _bankDetails.bankAccountHoldersName;
              data['accountNo'] = _bankDetails.accountNumber;
              data['routingNo'] = _bankDetails.routingNumber;
              data['accountType'] =
                  BankUtils.getBankType(_bankDetails.bankType);
              data['type'] = 'bank';
              widget.onSubmitData(data);
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree

    super.dispose();
  }
}
