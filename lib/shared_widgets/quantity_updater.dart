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
        confirmTextStyle:
            Theme.of(context).textTheme.h4.copyWith(color: ColorShades.greenBg),
        cancelTextStyle: Theme.of(context)
            .textTheme
            .body1Regular
            .copyWith(color: ColorShades.bastille),
        selectedTextStyle:
            Theme.of(context).textTheme.h3.copyWith(color: ColorShades.greenBg),
        onConfirm: (Picker picker, List value) {
          widget.addHandler(value: value[0] + 1);
        }).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ColorShades.white,
            boxShadow: [Shadows.noOffsetShadow]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (widget.showMinus)
              GestureDetector(
                  onTap: widget.subtractHandler,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(color: ColorShades.grey50),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: Spacing.space8, horizontal: Spacing.space8),
                    child: Icon(
                      widget.quantity == 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      color: ColorShades.redOrange,
                      size: 24,
                    ),
                  )),
            Container(
              height: 40,
              width: 40,
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
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        boxShadow: [BoxShadow(color: ColorShades.grey50)]),
                    padding: EdgeInsets.symmetric(
                        vertical: Spacing.space8, horizontal: Spacing.space8),
                    child: Icon(
                      Icons.add,
                      color: ColorShades.greenBg,
                      size: 24,
                    ),
                  )),
          ],
        ));
  }
}
