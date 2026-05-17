import 'package:flutter/material.dart';

class MeshColors {
  const MeshColors._();

  static const ink = Color(0xff05070a);
  static const panel = Color(0xff0b1017);
  static const panelLight = Color(0xfff4f7fb);
  static const cyan = Color(0xff0df2c9);
  static const lime = Color(0xffb7ff5a);
  static const amber = Color(0xffffc857);
  static const red = Color(0xffff4d67);
  static const violet = Color(0xff8f7cff);
  static const steel = Color(0xff9aa8b8);
}

class MeshTheme {
  const MeshTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MeshColors.cyan,
      brightness: Brightness.dark,
      surface: MeshColors.panel,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: MeshColors.ink,
      fontFamily: 'Roboto',
      textTheme: _textTheme(Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MeshColors.panel.withOpacity(0.82),
        indicatorColor: MeshColors.cyan.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.07),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MeshColors.cyan,
      brightness: Brightness.light,
      surface: MeshColors.panelLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xffeef3f7),
      textTheme: _textTheme(const Color(0xff0b1017)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: color.withOpacity(0.86),
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        height: 1.35,
        color: color.withOpacity(0.76),
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
