import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  final List items;
  final dynamic selectedValue;
  final Function changeHandler;
  CheckboxList(
      {@required this.items,
      @required this.selectedValue,
      @required this.changeHandler});
  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  var selectedVal;
  @override
  void initState() {
    selectedVal =
        widget.selectedValue != null ? widget.selectedValue : widget.items[0];

    if (selectedVal is Map) {
      selectedVal = selectedVal['value'];
    }
    super.initState();
  }

  changeValue(value) {
    setState(() {
      selectedVal = value;
    });
    widget.changeHandler(value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        var item = widget.items[index];
        bool selected = selectedVal == item['value'];
        return GestureDetector(
          onTap: () {
            changeValue(item['value']);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: Spacing.space16),
            child: Row(
              children: <Widget>[
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorShades.greenBg,
                  ),
                  child: Center(
                    child: Container(
                      height: selected ? 8 : 18,
                      width: selected ? 8 : 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorShades.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Spacing.space12,
                ),
                Text(
                  item['title'],
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
