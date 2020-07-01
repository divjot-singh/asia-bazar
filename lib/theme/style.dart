import 'package:flutter/material.dart';

class ColorShades {
  // Primary
  static const Color white = const Color(0xffffffff);
  static const Color neon = const Color(0xff426bff);
  static const Color freeSpeech = const Color(0xff3755c1);
  static const Color navy = const Color(0xff001a79);
  static const Color marble = const Color(0xffffffff);
  static const Color smokeWhite = const Color(0xfff9f9f9);
  static const Color grey100 = const Color(0xffd9dfee);
  static const Color grey200 = const Color(0xffb1bad4);
  static const Color grey300 = const Color(0xff647093);
  static const Color bastille = const Color(0xff2d2d33);
  static const Color greenBg = const Color(0xff178A43);
  static const Color darkGreenBg = const Color(0xff0F5C2C);
  static const Color lightGreenBg = const Color(0xffBDF5D2);
  static const Color lightGreenBg50 = const Color(0xff52c234);
  static const Color lightGreenBg75 = const Color(0xff0f9b0f);
  static const Color darkGreenBg50 = const Color(0xff061700);

  // Semantic
  static const Color elfGreen = const Color(0xff229d58);
  static const Color darkOrange = const Color(0xffff8a00);
  static const Color redOrange = const Color(0xfffa313d);

  // Gradients
  static const Color persianIndigo = const Color(0xff3c1f94);
  static const Color deepLilac = const Color(0xffab58c0);
  static const Color mangoTango = const Color(0xffe27100);
  static const Color orange = const Color(0xffedaa00);
  static const Color faluRed = const Color(0xff82120e);
  static const Color fireBrick = const Color(0xffc32322);
  static const Color cinnabar = const Color(0xffec5043);
  static const Color crusta = const Color(0xffef8351);
  static const Color clinker = const Color(0xff3a321b);
  static const Color shadow = const Color(0xff89774d);
  static const Color pinkBackground = const Color(0xfff2465d);
  static const Color darkPink = const Color(0Xfff3697e);
  static const Color lightBlue = const Color(0xffd4fcff);

  static const Color greyDark = const Color(0xff919191);
  static const Color greyLight = const Color(0xffC5C5C5);
  static const Color brownDark = const Color(0xff98553A);
  static const Color brownLight = const Color(0xffD5986E);

  // Additionalcolors
  static const Color supernova = const Color(0xffffc042);
  static const Color bastille70 = const Color(0xff2d2d33);
  static const Color lavender = const Color(0xffafc5ff);
  static const Color goldTips = const Color(0xffe2b823);
  static const Color suvaGrey = const Color(0xff8b8b8b);
  static const Color sepia = const Color(0xff9f5e46);
  static const Color lightGold = const Color(0xfffffdf8);

  // Socialmedia
  static const Color facebook = const Color(0xff4267b2);
  static const Color discord = const Color(0xff7289da);
  static const Color twitter = const Color(0xff1da1f2);
  static const Color line = const Color(0xff00c300);
  static const Color apple = const Color(0xff1c1c1e);
  static const Color pacificBlue = const Color(0xff0099cc);

  // Google
  static const Color blue = const Color(0xff4285f4);
  static const Color red = const Color(0xffdb4437);
  static const Color yellow = const Color(0xfff4b400);
  static const Color green = const Color(0xff0f9d58);
}

/*
variables have been created for the clearly identifiable use cases
usage: Theme.of(context).colorScheme.strokesDisabled)`
for the rest, use the color shades directly by:
1. importing this file
2. doing `ColorShades.myColor`
*/
extension CustomColorScheme on ColorScheme {
  /* Marble - To be used on background color : Bastille, Grey 200, Grey 300 Neon, Dark Orange, Elf Green, Red orange. */
  Color get textPrimaryLight => ColorShades.marble;
  /* Bastille - To be used on background color : Marble, Smoke white, Grey 100. */
  Color get textPrimaryDark => ColorShades.bastille;
  /* Grey 200 - To be used on background color : Marble, Bastille. */
  Color get textSecGray2 => ColorShades.grey200;
  /* Grey 300 - To be used on background color : Marble, Smoke white, Grey 100. */
  Color get textSecGray3 => ColorShades.grey300;
  /* Neon - To be used on background color : Marble, Smoke white. */
  Color get textSecNeon => ColorShades.neon;
  /* Dark Orange - To be used on background color : Marble. */
  Color get textSecOrange => ColorShades.darkOrange;

  // non text colors
  Color get accent => ColorShades.neon;
  Color get hover => ColorShades.freeSpeech;
  Color get shadowLight =>
      ColorShades.navy.withOpacity(0.08); // cards,headers,footers
  Color get shadowDark => ColorShades.navy.withOpacity(0.24); // buttons
  Color get surface => ColorShades.marble;
  Color get bg => ColorShades.smokeWhite;
  Color get disabled => ColorShades.grey100;
  Color get strokes => ColorShades.grey100;
  Color get strokesDisabled => ColorShades.grey200;
  Color get success => ColorShades.elfGreen;
  Color get error => ColorShades.redOrange;
  Color get pinkBackground => ColorShades.pinkBackground;
}

// IMPORTANT: remember to capitalize h5 and body1Black !!!
// `Text(someString.toUpperCase())`
// TextStyle doesn't support capitalisation so you will have to do it manually
// Usage: `style: Theme.of(context).textTheme.title)`
// BOLD = 700, NORMAL = 400
extension CustomTextTheme on TextTheme {
  TextStyle get h1 => TextStyle(
      fontSize: 28.0, fontWeight: FontWeight.w500, height: 28.0 / 28.0);
  TextStyle get h2 => TextStyle(
      fontSize: 24.0, fontWeight: FontWeight.w500, height: 24.0 / 24.0);
  TextStyle get h3 => TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.w500, height: 24.0 / 20.0);
  TextStyle get h4 => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w500, height: 20.0 / 16.0);
  TextStyle get h5 => TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      height: 16.0 / 12.0,
      letterSpacing: 1.0);
  TextStyle get pageTitle => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w700, height: 20.0 / 16.0);
  TextStyle get body1Regular => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w400, height: 18.0 / 14.0);
  TextStyle get body1Medium => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w500, height: 18.0 / 14.0);
  TextStyle get body1Bold => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w700, height: 18.0 / 14.0);
  TextStyle get body1Black => TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w900, height: 18.0 / 14.0);
  TextStyle get body2Regular => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w400, height: 16.0 / 12.0);
  TextStyle get body2Medium => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w500, height: 16.0 / 12.0);
  TextStyle get body2Bold => TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w700, height: 16.0 / 12.0);
  TextStyle get body2Italic => TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w700,
      height: 16.0 / 12.0,
      fontStyle: FontStyle.italic);
  TextStyle get formFieldText => TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w400, letterSpacing: 2.0);
}

/* 1. Minimum spacing between elements should be 4px & not less than that.
2. All the spacing used in the design system is in multiples of ‘4’. e.g. 4px, 8px, 12px, 16px, 20px, 24px */
class Spacing {
  static const double minSpacing = 4;
  // multiples
  static const double space4 = minSpacing * 1; // 4
  static const double space8 = minSpacing * 2; // 8
  static const double space12 = minSpacing * 3; // 12
  static const double space16 = minSpacing * 4; // 16
  static const double space20 = minSpacing * 5; // 20
  static const double space24 = minSpacing * 6; // 24
  static const double space28 = minSpacing * 7; // 28
  static const double space32 = minSpacing * 8; // 32
}

ThemeData appTheme() {
  return ThemeData(
    fontFamily: 'Roboto',
    accentColor: Colors.white,
    //  scaffoldBackgroundColor: const Color(0xFFFBFBFB)
  );
}

class Gradients {
  static LinearGradient silk = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      ColorShades.persianIndigo,
      ColorShades.deepLilac,
    ],
  );
  static LinearGradient greenGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      colors: [ColorShades.lightGreenBg, ColorShades.greenBg]);
  static LinearGradient greenGradientReverse = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      colors: [
        ColorShades.greenBg,
        ColorShades.lightGreenBg,
      ]);
}

class Shadows {
  final BuildContext context;
  Shadows(this.context) : super();

  static get card => BoxShadow(
        color: Color(0xff001a79),
        offset: Offset(0, 4),
        blurRadius: 12,
      );
  static get cardLight => BoxShadow(
        color: Color(0xff001a79),
        offset: Offset(0, 2),
        blurRadius: 6,
      );
  static get input => BoxShadow(
        color: ColorShades.darkGreenBg,
        offset: Offset(-1, 1),
        blurRadius: 12,
      );
  static get inputLight => BoxShadow(
        color: ColorShades.darkGreenBg,
        offset: Offset(-1, 1),
        blurRadius: 6,
      );
}
