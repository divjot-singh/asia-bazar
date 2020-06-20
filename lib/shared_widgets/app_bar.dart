import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final titleIcon;
  final bool hideBackArrow;
  final Map leading, rightAction;
  final hasTransparentBackground;

  /*
   * Constructor accepts the following fields:
   * title: String
   * leading: Map<leadingObject> - to be shown in the left end of the App bar.
   *    ** LeadingObject: {icon: String - path of a png image, onTap: Function - defines the onTap action of the leading icon }
   * rightAction: Map<RightActionObject> - to be shown in the right end of the App bar.
   *    ** RightActionObject: {icon: Widget, onTap: Function - defines the onTap action of the icon Widget }
   * hideBackArrow: bool - Controls the display of back arrow (in the left end of the App bar)
  */

  MyAppBar({
    this.title,
    this.titleIcon,
    this.leading,
    this.rightAction,
    this.hideBackArrow,
    this.hasTransparentBackground,
  }) : super();

  @override
  Size get preferredSize => Size.fromHeight(Spacing.space24 * 2);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(Spacing.space24 * 2),
      child: Padding(
          //todo ask khushboo
          padding: EdgeInsets.only(right: 0),
          child: AppBar(
            title: titleIcon != null
                ? titleIcon
                : Text(
                    this.title,
                    style: Theme.of(context).textTheme.pageTitle,
                  ),
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            backgroundColor: hasTransparentBackground == true
                ? Colors.transparent
                : Theme.of(context).colorScheme.bg,
            textTheme: Theme.of(context).textTheme,
            iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.textPrimaryDark),
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
                              color: ColorShades.bastille),
                        ),
                      ),
          )),
    );
  }
}
