import 'dart:async';
import 'dart:ui';

import 'package:CarPark/login_screen.dart';
import 'package:CarPark/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 240, 243, 245),
              Color.fromARGB(255, 112, 179, 227),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 300.0,
                    width: 300.0,
                  ),
                  SizedBox(height: 20.0),
                  SpinKitCircle(
                    size: 50.0,
                    itemBuilder: (context, index) {
                      final colors = [Colors.white, Colors.blue];
                      final color = colors[index % colors.length];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
