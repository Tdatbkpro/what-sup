import 'package:flutter/material.dart';
import 'package:whats_up/Config/Colors.dart';

var lightTheme = ThemeData();
var darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: dPrimaryColor,
    onPrimary: dOnBackgroundColor,
    surface: dBackgroundColor,
    onSurface: dOnContainerColor,
    primaryContainer: dContainerColor,         // ✅ Đặt đúng vị trí
    onPrimaryContainer: dOnContainerColor      // ✅ Đặt đúng vị trí
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: dContainerColor,
    shape: const RoundedRectangleBorder(
          
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
          )
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: dBackgroundColor,
    filled: true,

    border: UnderlineInputBorder(
      
      borderRadius: BorderRadius.circular(10)
    )
  ),
  textButtonTheme: TextButtonThemeData(
  style: TextButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

  textTheme: TextTheme(

    headlineLarge: TextStyle(
      fontSize: 32,
      color: dPrimaryColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w800,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      color: dOnBackgroundColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontSize: 28,
      color: dOnBackgroundColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 26,
      color: dPrimaryColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w800,
    ),
    bodyMedium: TextStyle(
      fontSize: 24,
      color: dOnBackgroundColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      fontSize: 22,
      color: dOnBackgroundColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: dOnContainerColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w800,
    ),
    labelMedium: TextStyle(
      fontSize: 20,
      color: dOnContainerColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontSize: 18,
      color: dOnContainerColor,
      fontFamily: "Roboto_Condensed",
      fontWeight: FontWeight.w400,
    ),
    

  )
);
 