import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';
import 'dart:math' as math;

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  CustomExpansionTile({@required this.title, this.children});
  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.space16),
      padding: EdgeInsets.symmetric(
          vertical: Spacing.space16, horizontal: Spacing.space12),
      decoration: BoxDecoration(
          color: ColorShades.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: theme.colorScheme.shadowLight,
                offset: Offset(0, 4),
                blurRadius: 12),
          ]),
      child: isExpanded
          ? GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = false;
                });
              },
              child: Container(
                color: ColorShades.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.body1Medium.copyWith(
                                color: theme.colorScheme.textSecGray3),
                          ),
                        ),
                        Transform.rotate(
                          angle: math.pi,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: theme.colorScheme.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Spacing.space16,
                    ),
                    if (widget.children != null && widget.children.length > 0)
                      ...widget.children,
                  ],
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
              },
              child: Container(
                color: ColorShades.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.body1Regular.copyWith(
                          color: theme.colorScheme.textSecGray3,
                        ),
                        softWrap: true,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: theme.colorScheme.textPrimaryDark,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
