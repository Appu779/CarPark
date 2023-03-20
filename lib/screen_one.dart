import 'package:flutter/material.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'images/lam2.gif',
        fit: BoxFit.fill,
        height: 1000,
        width: 1250,
      ),
    );
  }
}
