// import 'package:flutter/material.dart';

// class SideBar extends StatelessWidget {
//   const SideBar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//         child: Scaffold(
//             appBar: AppBar(
//               leading: IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   }),
//             ),
//             body: ListView(padding: EdgeInsets.zero, children: [
//               const UserAccountsDrawerHeader(
//                   accountName: Text(''), accountEmail: Text('')),
//               ListTile(
//                 leading: const Icon(Icons.person),
//                 title: const Text('Profile'),
//                 onTap: () => null,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('Settings',
//                     style: TextStyle(
//                       fontSize: 18,
//                     )),
//                 onTap: () => null,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.arrow_back),
//                 title: const Text('Logout',
//                     style: TextStyle(
//                       fontSize: 18,
//                     )),
//                 onTap: () async {
//                   await FirebaseServices().signOut();
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const LoginScreen()),
//                     (route) => false,
//                   );
//                 },
//               ),
//             ])));
//   }
// }

import 'package:CarPark/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class SideNav extends StatelessWidget {
  const SideNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 30, bottom: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Username',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  const Text('usermail@gmail.com',
                      style: TextStyle(color: Colors.white))
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Profile',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => Prof()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(
              'History',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => History()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'logout',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () async {
              await FirebaseServices().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
    );
  }
}
