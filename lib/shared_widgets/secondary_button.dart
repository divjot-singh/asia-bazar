import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final bool disabled, noWidth, hideShadow;
  final padding;
  final height;
  final shadow;
  Function onPressed;
  SecondaryButton(
      {@required this.text,
      this.padding,
      this.height,
      this.disabled = false,
      this.hideShadow = false,
      this.shadow,
      this.noWidth = false,
      @required this.onPressed});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      height: height != null ? height : null,
      decoration: BoxDecoration(
        border: disabled ? null : Border.all(color: ColorShades.greenBg),
        borderRadius: BorderRadius.circular(10),
        boxShadow: disabled || (hideShadow)
            ? null
            : [shadow != null ? shadow : Shadows.input],
      ),
      width: noWidth ? null : double.infinity,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: disabled ? ColorShades.grey100 : ColorShades.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: padding != null
              ? padding
              : EdgeInsets.symmetric(vertical: Spacing.space16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.h4.copyWith(
                color: disabled
                    ? theme.colorScheme.textSecGray2
                    : ColorShades.greenBg),
          ),
        ),
      ),
    );
  }
}
