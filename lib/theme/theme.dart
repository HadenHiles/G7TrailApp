import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';

class HomeTheme {
  HomeTheme._();

  static final Map<String, dynamic> lightHtmlStyle = {
    'h1': Style(
      color: lightTheme.textTheme.displayLarge!.color,
      fontFamily: lightTheme.textTheme.displayLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displayLarge!.fontSize ?? 42, Unit.px),
      textTransform: TextTransform.uppercase,
    ),
    'h2': Style(
      color: lightTheme.textTheme.displayMedium!.color,
      fontFamily: lightTheme.textTheme.displayMedium!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displayMedium!.fontSize ?? 36, Unit.px),
      textTransform: TextTransform.uppercase,
    ),
    'h3': Style(
      color: lightTheme.textTheme.displaySmall!.color,
      fontFamily: lightTheme.textTheme.displaySmall!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displaySmall!.fontSize ?? 30, Unit.px),
    ),
    'h4': Style(
      color: lightTheme.textTheme.headlineMedium!.color,
      fontFamily: lightTheme.textTheme.headlineMedium!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headlineMedium!.fontSize ?? 24, Unit.px),
    ),
    'h5': Style(
      color: lightTheme.textTheme.headlineSmall!.color,
      fontFamily: lightTheme.textTheme.headlineSmall!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headlineSmall!.fontSize ?? 22, Unit.px),
    ),
    'h6': Style(
      color: lightTheme.textTheme.titleLarge!.color,
      fontFamily: lightTheme.textTheme.titleLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.titleLarge!.fontSize ?? 18, Unit.px),
    ),
    'p': Style(
      color: lightTheme.textTheme.bodyLarge!.color,
      fontFamily: lightTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
      lineHeight: LineHeight(1.75, units: 'em'),
      padding: EdgeInsets.symmetric(vertical: 5),
    ),
    'em': Style(
      color: lightTheme.textTheme.bodyLarge!.color,
      fontFamily: lightTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
      fontStyle: FontStyle.italic,
    ),
    'strong': Style(
      color: lightTheme.textTheme.bodyLarge!.color,
      fontFamily: lightTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
      fontWeight: FontWeight.bold,
    ),
  };
  static final Map<String, dynamic> darkHtmlStyle = {
    'h1': Style(
      color: darkTheme.textTheme.displayLarge!.color,
      fontFamily: darkTheme.textTheme.displayLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displayLarge!.fontSize ?? 42, Unit.px),
    ),
    'h2': Style(
      color: darkTheme.textTheme.displayMedium!.color,
      fontFamily: darkTheme.textTheme.displayMedium!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displayMedium!.fontSize ?? 36, Unit.px),
    ),
    'h3': Style(
      color: darkTheme.textTheme.displaySmall!.color,
      fontFamily: darkTheme.textTheme.displaySmall!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.displaySmall!.fontSize ?? 30, Unit.px),
    ),
    'h4': Style(
      color: darkTheme.textTheme.headlineMedium!.color,
      fontFamily: darkTheme.textTheme.headlineMedium!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headlineMedium!.fontSize ?? 24, Unit.px),
    ),
    'h5': Style(
      color: darkTheme.textTheme.headlineSmall!.color,
      fontFamily: darkTheme.textTheme.headlineSmall!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.headlineSmall!.fontSize ?? 22, Unit.px),
    ),
    'h6': Style(
      color: darkTheme.textTheme.titleLarge!.color,
      fontFamily: darkTheme.textTheme.titleLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.titleLarge!.fontSize ?? 18, Unit.px),
    ),
    'p': Style(
      color: darkTheme.textTheme.bodyLarge!.color,
      fontFamily: darkTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
    ),
    'em': Style(
      color: darkTheme.textTheme.bodyLarge!.color,
      fontFamily: darkTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
      fontStyle: FontStyle.italic,
    ),
    'strong': Style(
      color: darkTheme.textTheme.bodyLarge!.color,
      fontFamily: darkTheme.textTheme.bodyLarge!.fontFamily,
      fontSize: FontSize(darkTheme.textTheme.bodyLarge!.fontSize ?? 16, Unit.px),
      fontWeight: FontWeight.bold,
    ),
  };

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xff0053B1),
    scaffoldBackgroundColor: Color(0xffE5E5E5),
    appBarTheme: AppBarTheme(
      color: Color(0xffF2F2F2),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xffF2F2F2),
    ),
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 42,
        fontFamily: 'LGCafe',
        color: Colors.black87,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        color: Colors.black87,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        color: Colors.black87,
      ),
      headlineSmall: TextStyle(
        color: Colors.black87,
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.black54,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xffF2F2F2),
      onPrimary: Colors.black54,
      primaryContainer: Color(0xffF4F4F4),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.black,
    ).copyWith(background: Color(0xffF2F2F2)),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xff0053B1),
    scaffoldBackgroundColor: Color(0xff1A1A1A),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xff333333),
    ),
    iconTheme: IconThemeData(
      color: Color.fromRGBO(255, 255, 255, 0.8),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 42,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 36,
      ),
      displaySmall: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 30,
      ),
      headlineMedium: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 24,
      ),
      headlineSmall: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontFamily: 'LGCafe',
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        color: Color(0xff0053B1),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.8),
        fontSize: 14,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xff0053B1);
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xff1A1A1A),
      onPrimary: Color.fromRGBO(255, 255, 255, 0.75),
      primaryContainer: Color(0xff1D1D1D),
      secondary: Color(0xffA9B7A7),
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ).copyWith(background: Color(0xff222222)),
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
