import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({Key? key}) : super(key: key);

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  _user!.photoURL ?? 'https://example.com/default-image.jpg'),
            ),
          ),
          Text(
            _user!.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDrawerShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double radius = 30.0; // Adjust the radius as needed

    path.lineTo(0, size.height); // Start at the bottom left corner
    path.quadraticBezierTo(0, size.height - radius, radius, size.height - radius); // Bottom left curve
    path.lineTo(size.width - radius, size.height - radius); // Bottom edge
    path.quadraticBezierTo(size.width, size.height - radius, size.width, size.height); // Bottom right curve
    path.lineTo(size.width, 0); // Top right corner
    path.close(); // Complete the shape by closing the path

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
