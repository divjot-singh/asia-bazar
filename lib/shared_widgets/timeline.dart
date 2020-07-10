import 'package:asia/shared_widgets/radio_buttons.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class Timeline extends StatelessWidget {
  final List<dynamic> items;
  Timeline({@required this.items});

  Widget itemBuilder(item) {
    if (item.length > 0) {
      var currentItem = item;
      bool selected = currentItem['selected'];
      Widget child = currentItem['placeHolder'];
      return Padding(
        padding: !selected ? EdgeInsets.only(left: 2) : EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            CustomRadioButton(
              selected: selected,
              height: selected ? 24 : 20,
            ),
            SizedBox(
              width: Spacing.space8,
            ),
            child,
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(left: 11),
      height: 20,
      width: 2,
      color: ColorShades.greenBg,
    );
  }

  @override
  Widget build(BuildContext context) {
    var newItems = List(items.length + items.length - 1);
    for (var i = 0; i < newItems.length; i++) {
      if (i % 2 == 0) {
        newItems[i] = items[(i / 2).floor()];
      } else {
        newItems[i] = {};
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...newItems.map(itemBuilder),
      ],
    );
  }
}
