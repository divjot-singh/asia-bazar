import 'package:flutter/material.dart';
import 'package:asia/l10n/l10n.dart';
import 'package:asia/theme/style.dart';
import 'package:flutter/services.dart';

// Usage

// InputBox(
//   onChanged:(){}, //required
//   hintText:"Enter here", //optional
//   disabled:true //optional
// )

class InputBox extends StatelessWidget {
  String hintText, value, label;
  final Function validator, onChanged, onFieldSubmitted, onTap, onSaved;
  final bool disabled, autovalidate, obscureText;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final AutovalidateMode autovalidateMode;
  final int maxLength;
  final margin, labelColor;
  final suffixIcon, maxLines, prefixIcon;
  final keyboardAppearance;
  final bool hideShadow;
  final List<TextInputFormatter> inputFormatters;
  TextEditingController controller;
  InputBox(
      {this.label,
      this.labelColor,
      this.hintText,
      this.margin,
      this.validator,
      this.hideShadow = false,
      this.disabled = false,
      this.autovalidate = false,
      this.autovalidateMode,
      this.obscureText = false,
      this.value,
      this.inputFormatters,
      this.keyboardType = TextInputType.text,
      this.onFieldSubmitted,
      this.focusNode,
      this.maxLength,
      this.controller,
      this.suffixIcon,
      this.prefixIcon,
      this.onTap,
      this.onSaved,
      this.maxLines = 1,
      this.keyboardAppearance,
      this.onChanged});
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    ThemeData theme = Theme.of(context);
    return Container(
      margin: margin != null ? margin : EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label != null)
            Text(
              label.toUpperCase(),
              style: textTheme.body1Medium.copyWith(
                  color: labelColor != null
                      ? labelColor
                      : colorScheme.textSecGray3),
            ),
          if (label != null)
            SizedBox(
              height: Spacing.space8,
            ),
          Container(
            decoration: BoxDecoration(
                boxShadow: hideShadow
                    ? null
                    : [
                        Shadows.input,
                      ]),
            child: TextFormField(
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              onTap: onTap,
              maxLines: maxLines,
              initialValue: value,
              enabled: !disabled,
              keyboardAppearance: keyboardAppearance,
              onSaved: onSaved,
              controller:
                  controller != null && value == null ? controller : null,
              inputFormatters: inputFormatters,
              obscureText: obscureText,
              autovalidate: autovalidate,
              autovalidateMode: autovalidateMode,
              keyboardType: keyboardType,
              maxLength: maxLength != null ? maxLength : null,
              focusNode: focusNode != null ? focusNode : null,
              style: theme.textTheme.body1Regular
                  .copyWith(color: theme.colorScheme.textPrimaryDark),
              decoration: InputDecoration(
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                counterText: '',
                contentPadding: EdgeInsets.all(Spacing.space12),
                errorStyle: theme.textTheme.body2Regular
                    .copyWith(color: theme.colorScheme.error),
                hintText: hintText ?? L10n().getStr('input.placeholder'),
                hintStyle: theme.textTheme.body1Regular
                    .copyWith(color: theme.colorScheme.textSecGray2),
                filled: true,
                fillColor:
                    disabled ? theme.colorScheme.disabled : ColorShades.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorShades.greenBg),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(16.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorShades.greenBg),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(16.0),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.error),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(16.0),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.error),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(16.0),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(16.0),
                  ),
                ),
              ),
              onChanged: onChanged,
              onFieldSubmitted:
                  onFieldSubmitted != null ? onFieldSubmitted : (_) => {},
              validator: validator ??
                  (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
            ),
          ),
        ],
      ),
    );
  }
}
