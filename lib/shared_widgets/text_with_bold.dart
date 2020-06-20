import 'package:flutter/material.dart';
import 'package:asia/shared_widgets/boxed_text.dart';
import 'package:asia/theme/style.dart';

class TextWithBold extends RichText {
  static RegExp anyTag =
      new RegExp(r'<(\/*?.+?)>'); // matches <foo>, matches </foo>
  static RegExp allTags =
      new RegExp(r'<(.*)>(.*?)</\1>'); // matches <foo>bar</foo>
  static RegExp boldTags =
      new RegExp(r'<(strong)>(.*?)</\1>'); // matches <strong>bar</strong>
  static RegExp boxTags =
      new RegExp(r'<(box)>(.*?)</\1>'); // matches <box> bar </box>
  TextWithBold(
    BuildContext context,
    String data, {
    Key key,
    TextStyle style,
    StrutStyle strutStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    TextWidthBasis textWidthBasis,
  }) : super(
          // todo figure out a better way to set the below commented properties with their default values as fallback
          textAlign: textAlign ?? TextAlign.start,
          softWrap: softWrap ?? true,
          overflow: overflow ?? TextOverflow.clip,
          // useful discussion on why the need to fallback using MediaQuery instead of the constructor default of 1.0:
          // https://github.com/flutter/flutter/issues/14675
          textScaleFactor:
              textScaleFactor ?? MediaQuery.of(context).textScaleFactor,
          textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
          textDirection: textDirection,
          maxLines: maxLines,
          locale: locale,
          strutStyle: strutStyle,
          text: TextSpan(
            children: allTags
                .allMatches(
                    // wrap all non-bold parts with <normal> tags
                    data.splitMapJoin(
              allTags,
              onMatch: (m) => '${m.group(0)}', // return as is
              onNonMatch: (n) =>
                  '<normal>$n</normal>', // wrap with <normal> tags
            ))
                .map((Match m) {
              String withTags = m.group(0);
              bool bold = withTags.contains(boldTags);
              bool isbox = withTags.contains(boxTags);
              String withoutTags = withTags.replaceAll(anyTag, '');
              if (isbox)
                return WidgetSpan(
                    child: BoxedText(
                        text: withoutTags, color: ColorShades.darkOrange));
              else {
                TextStyle textStyle = (style ?? TextStyle()).copyWith(fontWeight: bold ? FontWeight.w900 : style?.fontWeight);
                return TextSpan(
                  text: withoutTags,
                  style: textStyle,
                );
              }
            }).toList(),
            style: style,
          ),
        );
}
