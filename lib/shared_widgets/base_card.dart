import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

/*
this is top most wrapper for card,
It will be used globally so, we should not add many things in this
Usage BaseCard(
      child:widget,
      margin:Spacing.space16 // optional
      padding:Spacing.space16 // optional
      ),
      we can overwrite  border radius and box shadow if we have any rare scenario
      or better would be not to use this if we have to overvride many items
 */
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final border;
  final borderRadius;
  final color;

  BaseCard({
    @required this.child,
    this.margin,
    this.padding,
    this.border,
    this.borderRadius,
    this.color,
    Key key,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      width: double.infinity,
      // can remove margin later if it we have to overwrite this at many places
      margin: margin ?? EdgeInsets.symmetric(horizontal: Spacing.space16),
      padding: padding ?? EdgeInsets.all(Spacing.space12),
      decoration: BoxDecoration(
        color: color != null
            ? color
            : Theme.of(context).colorScheme.textPrimaryLight,
        borderRadius:
            borderRadius != null ? borderRadius : BorderRadius.circular(20.0),
        border: border != null ? border : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadowLight,
            offset: Offset(0, 4),
            blurRadius: 12,
          )
        ],
      ),
    );
  }
}
