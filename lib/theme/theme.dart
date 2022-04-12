import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';

class HomeTheme {
  HomeTheme._();

  static final Map<String, Style> lightHtmlStyle = {
    'h1': Style(
      color: lightTheme.textTheme.headline1!.color,
      fontFamily: lightTheme.textTheme.headline1!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline1!.fontSize, units: 'px'),
      textTransform: TextTransform.uppercase,
    ),
    'h2': Style(
      color: lightTheme.textTheme.headline2!.color,
      fontFamily: lightTheme.textTheme.headline2!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline2!.fontSize, units: 'px'),
      textTransform: TextTransform.uppercase,
    ),
    'h3': Style(
      color: lightTheme.textTheme.headline3!.color,
      fontFamily: lightTheme.textTheme.headline3!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline3!.fontSize, units: 'px'),
    ),
    'h4': Style(
      color: lightTheme.textTheme.headline4!.color,
      fontFamily: lightTheme.textTheme.headline4!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline4!.fontSize, units: 'px'),
    ),
    'h5': Style(
      color: lightTheme.textTheme.headline5!.color,
      fontFamily: lightTheme.textTheme.headline5!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline5!.fontSize, units: 'px'),
    ),
    'h6': Style(
      color: lightTheme.textTheme.headline6!.color,
      fontFamily: lightTheme.textTheme.headline6!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.headline6!.fontSize, units: 'px'),
    ),
    'p': Style(
      color: lightTheme.textTheme.bodyText1!.color,
      fontFamily: lightTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.bodyText1!.fontSize, units: 'px'),
      lineHeight: LineHeight(1.75, units: 'em'),
      padding: EdgeInsets.symmetric(vertical: 5),
    ),
    'em': Style(
      color: lightTheme.textTheme.bodyText1!.color,
      fontFamily: lightTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.bodyText1!.fontSize, units: 'px'),
      fontStyle: FontStyle.italic,
    ),
    'strong': Style(
      color: lightTheme.textTheme.bodyText1!.color,
      fontFamily: lightTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(lightTheme.textTheme.bodyText1!.fontSize, units: 'px'),
      fontWeight: FontWeight.bold,
    ),
  };
  static final Map<String, Style> darkHtmlStyle = {
    'h1': Style(
      color: darkTheme.textTheme.headline1!.color,
      fontFamily: darkTheme.textTheme.headline1!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline1!.fontSize, units: 'px'),
    ),
    'h2': Style(
      color: darkTheme.textTheme.headline2!.color,
      fontFamily: darkTheme.textTheme.headline2!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline2!.fontSize, units: 'px'),
    ),
    'h3': Style(
      color: darkTheme.textTheme.headline3!.color,
      fontFamily: darkTheme.textTheme.headline3!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline3!.fontSize, units: 'px'),
    ),
    'h4': Style(
      color: darkTheme.textTheme.headline4!.color,
      fontFamily: darkTheme.textTheme.headline4!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline4!.fontSize, units: 'px'),
    ),
    'h5': Style(
      color: darkTheme.textTheme.headline5!.color,
      fontFamily: darkTheme.textTheme.headline5!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline5!.fontSize, units: 'px'),
    ),
    'h6': Style(
      color: darkTheme.textTheme.headline6!.color,
      fontFamily: darkTheme.textTheme.headline6!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headline6!.fontSize, units: 'px'),
    ),
    'p': Style(
      color: darkTheme.textTheme.bodyText1!.color,
      fontFamily: darkTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyText1!.fontSize, units: 'px'),
    ),
    'em': Style(
      color: darkTheme.textTheme.bodyText1!.color,
      fontFamily: darkTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyText1!.fontSize, units: 'px'),
      fontStyle: FontStyle.italic,
    ),
    'strong': Style(
      color: darkTheme.textTheme.bodyText1!.color,
      fontFamily: darkTheme.textTheme.bodyText1!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyText1!.fontSize, units: 'px'),
      fontWeight: FontWeight.bold,
    ),
  };

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Color(0xffF2F2F2),
    primaryColor: Color(0xff0053B1),
    scaffoldBackgroundColor: Color(0xffE5E5E5),
    appBarTheme: AppBarTheme(
      color: Color(0xffF2F2F2),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    toggleableActiveColor: Color(0xff0053B1),
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xffF2F2F2),
      onPrimary: Colors.black54,
      primaryContainer: Color(0xffF4F4F4),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.black,
    ),
    cardTheme: CardTheme(
      color: Color(0xffF2F2F2),
    ),
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 42,
        fontFamily: 'LGCafe',
        color: Colors.black87,
      ),
      headline2: TextStyle(
        fontSize: 36,
        color: Colors.black87,
      ),
      headline3: TextStyle(
        fontSize: 30,
        color: Colors.black87,
      ),
      headline4: TextStyle(
        fontSize: 24,
        color: Colors.black87,
      ),
      headline5: TextStyle(
        color: Colors.black87,
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      headline6: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        color: Colors.black54,
        fontSize: 16,
      ),
      bodyText2: TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xff222222),
    primaryColor: Color(0xff0053B1),
    scaffoldBackgroundColor: Color(0xff1A1A1A),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    toggleableActiveColor: Color(0xff0053B1),
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xff1A1A1A),
      onPrimary: Color.fromRGBO(255, 255, 255, 0.75),
      primaryContainer: Color(0xff1D1D1D),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Color(0xff333333),
    ),
    iconTheme: IconThemeData(
      color: Color.fromRGBO(255, 255, 255, 0.8),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        color: Colors.white,
        fontSize: 42,
      ),
      headline2: TextStyle(
        color: Colors.white,
        fontSize: 36,
      ),
      headline3: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 30,
      ),
      headline4: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 24,
      ),
      headline5: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      headline6: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 16,
      ),
      bodyText2: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 14,
      ),
    ),
  );
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
