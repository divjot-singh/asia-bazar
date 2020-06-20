import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

// Usage

// showCustomDialog(
//                 context: context,
//                 heading:L10n().getStr("phoneAuthentication.enterOTP"),
//                 child: Container(
//                   margin: EdgeInsets.only(top: Spacing.space12),
//                   child: Column(
//                     children: [
//                       InputBox(
//                         hintText: 'XXX XXX',
//                         keyboardType: TextInputType.number,
//                         onChanged: (value) {
//                           phoneNumber = value;
//                         },
//                       ),
//                       SizedBox(height: 12),
//                       RichText(
//                         text: TextSpan(
//                             text: L10n().getStr(
//                                 "phoneAuthentication.error.didntGetCode"),
//                             style: theme.textTheme.body1Regular.copyWith(
//                                 color: theme.colorScheme.textSecGray3),
//                             children: [
//                               TextSpan(text: ' '),
//                               TextSpan(
//                                   text:
//                                       L10n().getStr("phoneAuthentication.resend"),
//                                   style: theme.textTheme.body1Medium.copyWith(
//                                       color: theme.colorScheme.textSecOrange,
//                                       decoration: TextDecoration.underline)),
//                             ]),
//                       ),
//                       SizedBox(
//                         height: Spacing.space24,
//                       ),
//                       Container(
//                         width: double.infinity,
//                         child: PrimaryButton(
//                           text: L10n().getStr("phoneAuthentication.verify"),
//                           onPressed: () {},
//                         ),
//                       ),
//                     ],
//                   ),
//                 ));

class GtvDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Text('hell from dialog'),
    );
  }
}

Future<Type> showCustomDialog(
    {@required BuildContext context,
    @required Widget child,
    @required String heading}) {
  ThemeData theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierDismissible: false,
    child: Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: BoxDecoration(
              color: ColorShades.marble,
              borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.all(Spacing.space16),
          child: Wrap(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    heading,
                    style: theme.textTheme.h4
                        .copyWith(color: theme.colorScheme.textPrimaryDark),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        color: theme.colorScheme.textPrimaryDark, size: 16),
                  ),
                ],
              ),
              child
            ],
          )),
    ),
  );
}
