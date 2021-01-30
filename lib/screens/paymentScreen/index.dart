import 'package:asia/blocs/user_database_bloc/bloc.dart';
import 'package:asia/blocs/user_database_bloc/state.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/repository/payment_repo.dart';
import 'package:asia/screens/paymentScreen/BankPayment/index.dart';
import 'package:asia/screens/paymentScreen/CardPayment/index.dart';
import 'package:asia/shared_widgets/app_bar.dart';
import 'package:asia/shared_widgets/customLoader.dart';
import 'package:asia/shared_widgets/snackbar.dart';
import 'package:asia/theme/style.dart';
import 'package:asia/utils/constants.dart';
import 'package:asia/utils/storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String paymentMethod;
  PaymentScreen({@required this.amount, this.paymentMethod = 'newBank'});
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ThemeData theme;
  bool allowPop = true;
  submitData(paymentData) async {
    var userBlocState =
        BlocProvider.of<UserDatabaseBloc>(context).state['userstate'];
    if (userBlocState is UserIsUser) {
      var userData = userBlocState.user,
          customerId = userData[KeyNames['customerPaymentId']];
      paymentData['phoneNumber'] = userData[KeyNames['phone']];
      paymentData['amount'] = widget.amount.toString();
      paymentData['userId'] = await StorageManager.getItem(KeyNames['userId']);

      if (customerId != null) {
        paymentData['paymentCustomerId'] = customerId;
      }
      setState(() {
        allowPop = false;
      });
      showCustomLoader(context,
          text: L10n().getStr('payments.makingPayment'),
          willPop: () async => false);
      dynamic response =
          await PaymentRepository.makeNewPayment(paymentDetails: paymentData);
      Navigator.pop(context);
      if (response['success'] == true) {
        Navigator.pop(context, {
          'success': true,
          'transactionId': response['transactionId'],
          'paymentData': paymentData
        });
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

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return WillPopScope(
      onWillPop: allowPop ? null : () async => false,
      child: SafeArea(
        child: Scaffold(
            backgroundColor: ColorShades.white,
            appBar: MyAppBar(
              hasTransparentBackground: true,
              title: L10n().getStr('paymentScreen.header'),
            ),
            body: widget.paymentMethod == 'newBank'
                ? BankPayment(
                    onSubmitData: submitData,
                  )
                : CardPayment(onSubmitData: submitData)),
      ),
    );
  }
}
