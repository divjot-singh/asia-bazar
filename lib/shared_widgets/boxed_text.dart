import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class BoxedText extends StatelessWidget {
  final String text;
  final Color color;
  const BoxedText({Key key, @required this.text, @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          right: Spacing.space4,
          left: Spacing.space4,
          top: Spacing.space4 / 4,
          bottom: Spacing.space4 / 4,
        ),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(4.0)),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorShades.white,
              fontSize: Theme.of(context).textTheme.body2Regular.fontSize,
              fontWeight: FontWeight.bold,
            )));
  }
}
