import 'package:flutter/material.dart';
import 'package:park/splash_screen.dart';
import 'card_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen());
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: InkWell(
                    onTap: () {
                      print("Taped on horizontal scroll");
                    },
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 200,
                        width: 200,
                        color: Colors.orange,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 200,
                        width: 200,
                        color: Colors.red,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 200,
                        width: 200,
                        color: Colors.yellow,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 200,
                        width: 200,
                        color: Colors.green,
                      )
                    ]),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 200,
                color: Colors.red,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 200,
                color: Colors.yellow,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                height: 200,
                color: Colors.green,
              )
            ],
          ),
        ),
      ),
    );
  }
}
