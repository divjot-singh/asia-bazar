import 'package:flutter/material.dart';
import 'package:asia/theme/style.dart';

class BaseSliderInput extends StatefulWidget {
  final double min, max, defaultValue;
  final int divisions;
  final Function onChange;

  const BaseSliderInput({
    Key key,
    @required this.min,
    @required this.max,
    @required this.defaultValue,
    @required this.divisions,
    @required this.onChange,
  }) : super(key: key);

  @override
  _BaseSliderInputState createState() => _BaseSliderInputState();
}

class _BaseSliderInputState extends State<BaseSliderInput> {
  double value;
  @override
  void initState() {
    super.initState();
    value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            widget.min.round().toString(),
            style: Theme.of(context).textTheme.body1Regular.copyWith(
                  color: Theme.of(context).colorScheme.textSecGray3,
                ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: ColorShades.blue,
                inactiveTrackColor: ColorShades.grey100,
                thumbColor: ColorShades.blue,
                // overlayShape: SliderComponentShape.noOverlay,
                overlayColor: Colors.transparent,
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: (double newValue) {
                  setState(() {
                    value = newValue;
                  });
                  widget.onChange(value);
                },
              ),
            ),
          ),
          Text(
            widget.max.round().toString(),
            style: Theme.of(context).textTheme.body1Regular.copyWith(
                  color: Theme.of(context).colorScheme.textSecGray3,
                ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: 42.0),
            margin: EdgeInsets.only(left: Spacing.space28),
            padding: EdgeInsets.symmetric(
              vertical: Spacing.space12,
              horizontal: Spacing.space24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              // boxShadow: [Shadows(context).card],
              border: Border.all(color: ColorShades.grey100),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text(
              value.round().toString(),
              style: Theme.of(context).textTheme.body1Regular.copyWith(
                    color: value == 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.textPrimaryDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
