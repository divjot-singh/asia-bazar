import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

class QuantityUpdater extends StatefulWidget {
  final int quantity, maxQuantity, minQuantity;
  final Function addHandler, subtractHandler;
  final bool showMinus, showAdd;
  QuantityUpdater(
      {@required this.quantity,
      this.showMinus = true,
      this.showAdd = true,
      this.minQuantity = 1,
      this.maxQuantity = 50,
      @required this.addHandler,
      @required this.subtractHandler});
  @override
  _QuantityUpdaterState createState() => _QuantityUpdaterState();
}

class _QuantityUpdaterState extends State<QuantityUpdater> {
  ThemeData theme;

  showPickerNumber(BuildContext context, {@required int quantity}) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
            begin: widget.minQuantity,
            initValue: quantity,
            end: widget.maxQuantity,
          ),
        ]),
        hideHeader: true,
        title: Text(L10n().getStr('item.selectQuantity')),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          widget.addHandler(value: value[0] + 1);
        }).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Container(
        child: Row(
      children: <Widget>[
        if (widget.showMinus)
          GestureDetector(
              onTap: widget.subtractHandler,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: ColorShades.pinkBackground)),
                child: Icon(
                  Icons.remove,
                  color: ColorShades.pinkBackground,
                  size: 20,
                ),
              )),
        Container(
          height: 24,
          width: 36,
          child: Center(
            child: GestureDetector(
              onTap: () {
                showPickerNumber(context, quantity: widget.quantity);
              },
              child: Text(
                widget.quantity.toString(),
                style: theme.textTheme.h4.copyWith(
                    color: ColorShades.neon,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
        ),
        if (widget.showAdd)
          GestureDetector(
              onTap: widget.addHandler,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: ColorShades.greenBg)),
                child: Icon(
                  Icons.add,
                  color: ColorShades.greenBg,
                  size: 20,
                ),
              )),
      ],
    ));
  }
}
