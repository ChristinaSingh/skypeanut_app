import 'package:flutter/material.dart';

import 'colors.dart';

class MThemeData {
  static ThemeData themeData() {
    return ThemeData(
      fontFamily: 'Poppins',
      primaryColor: primaryColor,
      secondaryHeaderColor: primaryColor,
      hintColor: primaryColor,
      focusColor: primaryColor,
      hoverColor: primaryColor,
      highlightColor: primaryColor,
      unselectedWidgetColor: primaryColor,
      cardColor: backgroundColor, // ✅ Force dialog color
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
        accentColor: primaryColor2,
        backgroundColor: backgroundColor,
      ).copyWith(
        primary: primaryColor2,
        secondary: primaryColor,
        onPrimary: backgroundColor,
        onSecondary: backgroundColor,
      ), dialogTheme: DialogThemeData(backgroundColor: primaryColor),
    );
  }
}
