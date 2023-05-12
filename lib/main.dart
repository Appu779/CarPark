import 'package:CarPark/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     FirebaseDatabase.instance.setPersistenceEnabled(true);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      themeMode: ThemeMode.system,
      title: "Mile2Park",
      home: SplashScreen(),
    );
  }
}
