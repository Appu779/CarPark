// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     drawer: Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text(
//               'Drawer Header',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text('Home'),
//             onTap: () {
//               // Navigate to the home screen
//               Navigator.pop(context); // Close the drawer
//               // TODO: Add navigation logic
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               // Navigate to the settings screen
//               Navigator.pop(context); // Close the drawer
//               // TODO: Add navigation logic
//             },
//           ),
//         ],
//       ),
//     ),
//     body: Column(
//       children: [
//         Expanded(
//           child: Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: const CameraPosition(
//                   target: currentLocation,
//                   zoom: 14,
//                 ),
//                 onMapCreated: (controller) async {
//                   mapController = controller;
//                   fetchMarkers();
//                   fetchPolygons();
//                   listenForParkingUpdates();
//                 },
//                 zoomGesturesEnabled: true,
//                 zoomControlsEnabled: true,
//                 mapType: MapType.normal,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 compassEnabled: true,
//                 rotateGesturesEnabled: true,
//                 buildingsEnabled: true,
//                 markers: markers,
//                 polygons: polygons,
//               ),
//               if (isMenuOpen)
//                 Positioned.fill(
//                   child: Container(
//                     color: Colors.black.withOpacity(0.6),
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           isMenuOpen = false;
//                           animationController.reverse();
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               Positioned(
//                 top: 43,
//                 left: 20,
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       isMenuOpen = !isMenuOpen;
//                       if (isMenuOpen) {
//                         animationController.forward();
//                       } else {
//                         animationController.reverse();
//                       }
//                     });
//                   },
//                   child: AnimatedIcon(
//                     icon: AnimatedIcons.menu_close,
//                     progress: animationController,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//     floatingActionButton: Stack(
//       children: [
//         Positioned(
//           left: 20,
//           bottom: 8.0,
//           child: FloatingActionButton(
//             backgroundColor: Colors.green,
//             onPressed: () async {
//               Position position = await userLocation();
//               mapController.animateCamera(
//                 CameraUpdate.newCameraPosition(
//                   CameraPosition(
//                     target: LatLng(position.latitude, position.longitude),
//                     zoom: 15,
//                   ),
//                 ),
//               );
//             },
//             tooltip: 'My Location',
//             child: const Icon(Icons.my_location),
//           ),
//         ),
//         Positioned(
//           left: 20,
//           bottom: 70.0,
//           child: FloatingActionButton(
//             onPressed: () {
//               showNearbyParking(context);
//             },
//             tooltip: 'Nearby Parking',
//             child: const Icon(Icons.local_parking_sharp),
//           ),
//         ),
//       ],
//     ),
//   );
// }
