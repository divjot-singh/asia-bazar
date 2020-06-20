import 'package:flutter/material.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';

// Usage
//  showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return GtvBottomSheet(
//             context: context,
//             sheetItems: [
//               {
//                 'onTap': () {
//                   //do something
//                 },
//                 'text': L10n().getStr('profile.edit')
//               },
//               {
//                 'onTap': () {
//                   //do something
//                 },
//                 'text': L10n().getStr('sharePopup.heading')
//               }
//             ],
//           );
//         });

class GtvBottomSheet extends StatelessWidget {
  final List sheetItems;
  final BuildContext context;

  GtvBottomSheet({@required this.sheetItems, @required this.context}) : super();

  Widget buildSheetItem(
      {@required Map item, @required ThemeData theme, String itemType}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (item['onTap'] != null) item['onTap']();
      },
      child: Container(
        margin: itemType == 'close'
            ? EdgeInsets.only(top: Spacing.space12)
            : EdgeInsets.all(0),
        width: 328.0,
        decoration: BoxDecoration(
            color: theme.colorScheme.textPrimaryLight,
            borderRadius: itemType == 'first'
                ? BorderRadius.only(
                    topRight: Radius.circular(10), topLeft: Radius.circular(10))
                : itemType == 'last'
                    ? BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))
                    : itemType == 'close' ? BorderRadius.circular(10) : null),
        padding: EdgeInsets.only(top: Spacing.space16, bottom: Spacing.space16),
        child: Text(
          item['text'],
          textAlign: TextAlign.center,
          style: theme.textTheme.body1Regular.copyWith(
              color: itemType == 'close'
                  ? theme.colorScheme.textSecGray3
                  : theme.colorScheme.textPrimaryDark),
        ),
      ),
    );
  }

  List<Widget> buildSheetFromItems(List list, ThemeData theme) {
    List<Widget> sheetWidget = [];
    for (final item in list) {
      String itemType =
          item == list.first ? 'first' : item == list.last ? 'last' : '';
      sheetWidget
          .add(buildSheetItem(item: item, theme: theme, itemType: itemType));
      if (item != list.last) {
        sheetWidget.add(Container(
          height: 1,
          width: 328,
          color: theme.colorScheme.strokes,
        ));
      }
    }
    sheetWidget.add(buildSheetItem(
        item: {'text': L10n().getStr('filter.close')},
        theme: theme,
        itemType: 'close'));
    return sheetWidget;
  }

  @override
  Widget build(BuildContext context) {
    var sheetHeight = (50 * sheetItems.length) + 70 + (sheetItems.length - 1);
    //var sheetHeight = 316;
    return Container(
      height: sheetHeight.toDouble(),
      child: Column(
        children: buildSheetFromItems(sheetItems, Theme.of(context)),
      ),
    );
  }
}
