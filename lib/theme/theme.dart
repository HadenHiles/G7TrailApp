import 'package:flutter/material.dart';

class HomeTheme {
  HomeTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColorBrightness: Brightness.dark,
    backgroundColor: const Color(0xffF2F2F2),
    primaryColor: const Color(0xff0053B1),
    scaffoldBackgroundColor: const Color(0xffE5E5E5),
    appBarTheme: const AppBarTheme(
      color: Color(0xffF2F2F2),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    toggleableActiveColor: const Color(0xff0053B1),
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xffF2F2F2),
      onPrimary: Colors.black54,
      primaryVariant: Color(0xffF4F4F4),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.black,
    ),
    cardTheme: CardTheme(
      color: Colors.grey.shade300,
    ),
    iconTheme: const IconThemeData(
      color: Colors.black87,
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(
        color: Colors.black87,
      ),
      headline2: TextStyle(
        color: Colors.black87,
      ),
      headline3: TextStyle(
        color: Colors.black87,
      ),
      headline4: TextStyle(
        color: Colors.black87,
      ),
      headline5: TextStyle(
        color: Colors.black87,
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      headline6: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
      bodyText2: TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorBrightness: Brightness.dark,
    backgroundColor: const Color(0xff222222),
    primaryColor: const Color(0xff0053B1),
    scaffoldBackgroundColor: const Color(0xff1A1A1A),
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    toggleableActiveColor: const Color(0xff0053B1),
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xff1A1A1A),
      onPrimary: Color.fromRGBO(255, 255, 255, 0.75),
      primaryVariant: Color(0xff1D1D1D),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ),
    cardTheme: const CardTheme(
      color: Color(0xff333333),
    ),
    iconTheme: const IconThemeData(
      color: Color.fromRGBO(255, 255, 255, 0.8),
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(
        color: Colors.white,
      ),
      headline2: TextStyle(
        color: Colors.white,
      ),
      headline3: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
      ),
      headline4: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
      ),
      headline5: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      headline6: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.9),
        fontSize: 14,
      ),
      bodyText2: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.7),
        fontSize: 12,
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
