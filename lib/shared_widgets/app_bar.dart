import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final titleIcon;
  final bool hideBackArrow;
  final Map leading, rightAction;
  final hasTransparentBackground;
  final textColor;

  MyAppBar(
      {this.title,
      this.titleIcon,
      this.leading,
      this.rightAction,
      this.hideBackArrow,
      this.hasTransparentBackground = false,
      this.textColor})
      : super();

  @override
  Size get preferredSize => Size.fromHeight(Spacing.space24 * 2);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(Spacing.space24 * 2),
      child: Padding(
          padding: EdgeInsets.only(right: 0),
          child: AppBar(
            title: titleIcon != null
                ? titleIcon
                : Text(
                    this.title,
                    style: Theme.of(context).textTheme.pageTitle.copyWith(
                        color: textColor != null
                            ? textColor
                            : hasTransparentBackground
                                ? ColorShades.greenBg
                                : ColorShades.white),
                  ),
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            backgroundColor: hasTransparentBackground == true
                ? Colors.transparent
                : ColorShades.greenBg,
            textTheme: Theme.of(context).textTheme,
            iconTheme: IconThemeData(
                color: hasTransparentBackground
                    ? ColorShades.greenBg
                    : ColorShades.white),
            actions: rightAction != null
                ? <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: Spacing.space8),
                      child: GestureDetector(
                        child: rightAction['icon'],
                        onTap: rightAction['onTap'],
                      ),
                    )
                  ]
                : <Widget>[SizedBox.shrink()],
            leading: leading != null
                ? Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        leading['onTap'](context);
                      },
                      child: leading['icon'],
                    ),
                  )
                : hideBackArrow == true
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_back,
                              color: textColor != null
                                  ? textColor
                                  : ColorShades.green),
                        ),
                      ),
          )),
    );
  }
}
