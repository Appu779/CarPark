import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      UserAccountsDrawerHeader(accountName: Text(''), accountEmail: Text('')),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () => null,
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings',
            style: TextStyle(
              fontSize: 18,
            )),
        onTap: () => null,
      ),
      ListTile(
        leading: Icon(Icons.arrow_back),
        title: Text('Logout',
            style: TextStyle(
              fontSize: 18,
            )),
        onTap: () => null,
      ),
    ]));
  }
}
