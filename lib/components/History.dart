import 'package:CarPark/screens/SideNav.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var his = [
      'dhjxsbx',
      'exbwyyex',
      'ewxwxew',
      'exwewx'
    ]; //array of list inputs
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      drawer: SideNav(),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('$index'),
            title: Text(his[index]),
            subtitle: Text('Address'),
            trailing: Text('Date'),
          );
        },
        itemCount: 10,
        separatorBuilder: (context, index) => Divider(
          height: 20,
          thickness: 1,
        ),
      ),
    );
  }
}
