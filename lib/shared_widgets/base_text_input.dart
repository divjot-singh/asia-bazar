import 'package:asia/utils/deboucer.dart';
import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class BaseTextInput extends StatelessWidget {
  final bool isOkay;
  final String placeholder;
  final String message;
  final int maxLength;
  final Function onStopTyping;
  final bool isWorking;

  BaseTextInput({
    Key key,
    this.placeholder = '',
    this.isOkay = false,
    this.message = '',
    this.maxLength,
    this.onStopTyping,
    this.isWorking,
  }) : super(key: key) {
    d = Debouncer(milliseconds: 1000);
  }
  Debouncer d;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextField(
          onChanged: (value) {
            d.run(() {
              onStopTyping(value);
            });
          },
          maxLength: maxLength,
          style: Theme.of(context).textTheme.body1Regular,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            counterStyle: TextStyle(
              color: Theme.of(context).colorScheme.textSecGray3,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.space12,
              vertical: 0.0,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorShades.grey200,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorShades.grey100,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.textSecGray2,
            ),
            helperText: message,
            helperStyle: TextStyle(
              color: isOkay
                  ? Theme.of(context).colorScheme.success
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        if (isWorking == true)
          Positioned(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              backgroundColor: ColorShades.grey300,
            ),
            top: 14.0,
            right: 10.0,
            width: 20.0,
            height: 20.0,
          ),
      ],
    );
  }
}
