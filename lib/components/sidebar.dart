import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../services/firebase_service.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            body: ListView(padding: EdgeInsets.zero, children: [
              const UserAccountsDrawerHeader(
                  accountName: Text(''), accountEmail: Text('')),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => null,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () => null,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('Logout',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                onTap: () async {
                  await FirebaseServices().signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ])));
  }
}
