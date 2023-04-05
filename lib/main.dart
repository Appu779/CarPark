import 'package:CarPark/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/home.dart';

void main() {
  runApp(MaterialApp(
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    title: "Mile2Park",
    home: SplashScreen(),
  ));
}
