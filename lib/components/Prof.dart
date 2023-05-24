import 'package:CarPark/screens/SideNav.dart';
import 'package:flutter/material.dart';

class Prof extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      drawer: SideNav(),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 500,
                    height: 500,
                    margin: EdgeInsets.only(top: 100, bottom: 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      //image: ,
                      //fit: BoxFit.fill)
                    ),
                  ),
                  Text(
                    'Username',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  Text('usermail@gmail.com',
                      style: TextStyle(fontSize: 20, color: Colors.white))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
