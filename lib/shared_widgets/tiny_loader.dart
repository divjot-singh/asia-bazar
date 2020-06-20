import 'package:flutter/material.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';

class TinyLoader extends StatelessWidget {
  const TinyLoader({
    Key key,
    this.margin,
  }) : super(key: key);
  final margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.space12),
      margin: margin != null
          ? margin
          : EdgeInsets.only(
              bottom: Spacing.space16,
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              height: 16.0,
              width: 16.0,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.textSecNeon),
                strokeWidth: 2.0,
              )),
          SizedBox(width: Spacing.space12),
          Text(
            L10n().getStr('global.loading'),
            style: Theme.of(context)
                .textTheme
                .body1Medium
                .copyWith(color: Theme.of(context).colorScheme.textSecNeon),
          )
        ],
      ),
    );
  }
}
