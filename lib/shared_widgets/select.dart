import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class BaseDropDownInputMenuItem<T> {
  final T id;
  final String name;
  String subtext; //text that is to be shown to the right end of the button.
  bool isDisabled;
  final TextAlign textAlign;

  BaseDropDownInputMenuItem(
      {@required this.id,
      @required this.name,
      this.subtext,
      this.isDisabled = false,
      this.textAlign = TextAlign.start});
}

class BaseDropdownInput<T> extends StatelessWidget {
  BaseDropdownInput({
    Key key,
    @required this.value,
    @required this.list,
    @required this.onChanged,
    this.underline,
    this.isWhite = false,
  }) : super(key: key);
  final T value;
  final bool isWhite;
  final List<BaseDropDownInputMenuItem> list;
  final onChanged;
  final Widget underline;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.space12,
        vertical: 0.0,
      ),
      decoration: BoxDecoration(
          border: Border.all(color: ColorShades.greenBg),
          borderRadius: BorderRadius.circular(16)),
      // decoration: isWhite
      //     ? BoxDecoration()
      //     : BoxDecoration(
      //         boxShadow: [Shadows.card],
      //         color: Colors.white,
      //         borderRadius: BorderRadius.all(
      //           Radius.circular(10.0),
      //         ),
      //       ),
      child: DropdownButton<T>(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        value: value,
        dropdownColor: ColorShades.white,
        icon: Image.asset(
          "assets/images/dropdown.png",
          height: 20,
        ),

        // iconEnabledColor: ColorShades.white,
        underline: underline ??
            Container(
              height: 0,
              color: Colors.transparent,
            ),
        elevation: 16,
        isExpanded: !isWhite,
        // style: TextStyle(color: isWhite ? Colors.white : Colors.deepPurple),
      onChanged: (newValue) {
          bool isItemDisabled =
              list.firstWhere((item) => item.id == newValue).isDisabled;
          if (!isItemDisabled) {
            FocusScope.of(context).requestFocus(FocusNode());
            onChanged(newValue);
          }
        },
        selectedItemBuilder: isWhite
            ? (BuildContext context) {
                return list.map<Widget>((item) {
                  return Center(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.pageTitle.copyWith(
                          color:
                              Theme.of(context).colorScheme.textPrimaryLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              }
            : null,
        items: list.map<DropdownMenuItem<T>>(
          (BaseDropDownInputMenuItem menuItem) {
            bool isSeleceted = menuItem.id == value;
            // bool isLastItem = list[list.length - 1] == menuItem;
            // Decoration decoration = isLastItem
            //     ? null
            //     : BoxDecoration(
            //         border: Border(
            //           bottom: BorderSide(color: ColorShades.grey300),
            //         ),
            //       );
            return DropdownMenuItem<T>(
              value: menuItem.id,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        menuItem.name,
                        style:
                            _getDropDownTheme(context, menuItem, isSeleceted),
                        textAlign: menuItem.textAlign,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (menuItem.subtext != null)
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: Spacing.space12),
                          child: Text(
                            menuItem.subtext,
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                                .textTheme
                                .body2Italic
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textSecOrange),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  TextStyle _getDropDownTheme(BuildContext context,
      BaseDropDownInputMenuItem menuItem, bool isSelected) {
    if (isSelected) return Theme.of(context).textTheme.body1Medium;

    return (Theme.of(context).textTheme.body1Regular).copyWith(
      color: (menuItem.isDisabled
          ? Theme.of(context).colorScheme.textSecGray2
          : (isSelected
              ? Theme.of(context).colorScheme.textPrimaryDark
              : Theme.of(context).colorScheme.textSecGray3)),
      fontWeight: isSelected ? FontWeight.w500 : null,
    );
  }
}
