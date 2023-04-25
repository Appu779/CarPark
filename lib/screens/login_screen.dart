import 'package:CarPark/screens/map_screen.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            Color.fromARGB(255, 234, 58, 58),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Column(children: [
            Image.asset(
              "assets/images/logo.png",
              width: 250,
              height: 150,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await FirebaseServices().signInWithGoogle();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MapScreen()));
                },
                icon: Image.asset(
                  "assets/images/g.png",
                  height: 32,
                  width: 32,
                ),
                label: Text('Sign in with google'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            )
          ]),
        ),
      ),
    ));
  }
}
