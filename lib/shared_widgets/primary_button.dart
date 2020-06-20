import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

/*
-------Usage---------
PrimaryButton(
          text: 'Register',
          disabled: true, //optional
          onPressed: _onPressed,
        ),
*/

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool disabled;
  final Function onPressed;
  final dynamic width;
  final height;
  PrimaryButton({
    @required this.text,
    @required this.onPressed,
    this.width,
    this.height,
    this.disabled = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == null ? 42.0 : height,
      width: width ?? null,
      decoration: BoxDecoration(
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadowDark,
                  offset: Offset(0, 0),
                  blurRadius: 8,
                )
              ],
      ),
      child: RaisedButton(
        color: ColorShades.pinkBackground,
        disabledColor: Theme.of(context).colorScheme.disabled,
        textColor: Theme.of(context).colorScheme.textPrimaryLight,
        disabledTextColor: Theme.of(context).colorScheme.textSecGray3,
        highlightColor: ColorShades.darkPink,
        child: Text(
          text,
          style: Theme.of(context).textTheme.body1Medium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        onPressed: disabled ? null : onPressed ?? () => {},
      ),
    );
  }
}
