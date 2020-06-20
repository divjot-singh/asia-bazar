import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

import 'package:asia/shared_widgets/primary_button.dart';

class BottomCta extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool disabled;
  const BottomCta(
      {Key key,
      @required this.onPressed,
      @required this.text,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.textPrimaryLight,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadowLight,
            offset: Offset(0, -4),
            blurRadius: 12,
          )
        ],
      ),
      child: PrimaryButton(
        text: text,
        disabled: disabled,
        onPressed: () {
          onPressed(context);
        },
      ),
    );
  }
}
