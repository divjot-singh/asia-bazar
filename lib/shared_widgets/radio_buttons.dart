import 'package:asia/theme/style.dart';
import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final bool selected;
  final double height, selectedChildHeight, unselectedChildHeight;
  final Color internalColor, externalColor;
  CustomRadioButton(
      {this.selected = false,
      this.height = 20,
      this.selectedChildHeight = 8,
      this.unselectedChildHeight = 15,
      this.internalColor = ColorShades.white,
      this.externalColor = ColorShades.greenBg});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(color: externalColor, shape: BoxShape.circle),
      child: Center(
        child: Container(
          height: selected ? selectedChildHeight : unselectedChildHeight,
          width: selected ? selectedChildHeight : unselectedChildHeight,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: internalColor,
          ),
        ),
      ),
    );
  }
}
