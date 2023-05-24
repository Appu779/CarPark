import 'package:CarPark/components/History.dart';
import 'package:CarPark/components/Prof.dart';
import 'package:CarPark/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  const SideNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 30, bottom: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      //image: ,
                      //fit: BoxFit.fill)
                    ),
                  ),
                  Text(
                    'Username',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  Text('usermail@gmail.com',
                      style: TextStyle(color: Colors.white))
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Profile',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Prof()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(
              'History',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => History()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'logout',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                      title: Text("Logout"),
                      content: Text("Do you want to log out your account?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text('Yes')),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'))
                      ],
                    );
                  });
            },
          )
        ],
      ),
    );
  }
}
