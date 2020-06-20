import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

// Usage

// showCustomSnackbar(
//           context: context,
//           content: 'Success',
//           duration:4,// optional
//           type: SnackbarType.success);

enum SnackbarType { error, success }
Future<Type> showCustomSnackbar(
    {@required BuildContext context,
    int duration = 1,
    String content,
    @required SnackbarType type}) {
  Future.delayed(Duration(seconds: duration), () {
    Navigator.pop(context);
  });
  return showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        return Container(
            height: 400,
            child: Center(
                child: Container(
              width: 328,
              padding: EdgeInsets.symmetric(vertical: Spacing.space16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: type == SnackbarType.error
                    ? theme.colorScheme.error
                    : theme.colorScheme.success,
              ),
              child: Text(
                content.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.body1Medium
                    .copyWith(color: theme.colorScheme.textPrimaryLight),
              ),
            )));
      });
}
