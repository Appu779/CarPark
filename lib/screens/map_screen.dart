import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/parking_avail.dart';
import '../components/sidebar.dart';

const LatLng currentLocation = LatLng(12.092770, 75.194881);

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late AnimationController animationController;
  late StreamSubscription<Position> positionStreamSubscription;
  late Timer timer;
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    enableLocationService();
    fetchMarkers();
    fetchPolygons();
    //listenForParkingUpdates();
    CheckAvailability().listenForParkingUpdates();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    timer = Timer.periodic(const Duration(seconds: 4),
        runFunction); // Add this line to create the Timer
  }

  void runFunction(Timer timer) {
    CheckAvailability().listenForParkingUpdates();
  }

  @override
  void dispose() {
    animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: currentLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) async {
              mapController = controller;
              await fetchMarkers();
              await fetchPolygons();
              CheckAvailability().listenForParkingUpdates();
              //await _showParkingDetails("P1");
              //await listenForParkingUpdates();
            },
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            buildingsEnabled: true,
            markers: markers,
            //circles: circles,
            polygons: polygons,
          ),
          Positioned(
            top: 43,
            left: 20,
            child: GestureDetector(
              onTap: () {
                isMenuOpen = !isMenuOpen;
                if (isMenuOpen) {
                  animationController.forward();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SideBar(),
                      ));
                  animationController.reverse();
                }
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: animationController,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              color: Colors.black,
            ),
          ),
          // Positioned(
          //   top: 60,
          //   right: 20,
          //   child: IconButton(
          //     icon: const Icon(Icons.park_rounded),
          //     onPressed: () {},
          //     color: Colors.black,
          //   ),
          // )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          Position position = await userLocation();

          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15)));
        },
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> enableLocationService() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return;
      }
    }
  }

  Future<Position> userLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("location sericec diabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission denied permanent");
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  // Future<String> getSnippet(String docId) async {
  //   final snapshot = FirebaseDatabase.instance.ref('Parking').child(docId);
  //   final data = snapshot as Map;
  //   final snippet = data['snippet'] as String;
  //   final availablespace = data['availspace'] as num;
  //   return 'Available Space: $availablespace $snippet';
  // }

  // Future<void> fetchMarkers() async {
  //   final snapshot =
  //       await FirebaseFirestore.instance.collection('Parking').get();
  //   final newmarkers = snapshot.docs.map((doc) async {
  //     final data = doc.data();
  //     final lat = data['latitude'] as double;
  //     final lng = data['longitude'] as double;
  //     final location = data['location'] as String;
  //     final snippet = await getSnippet(doc.id);
  //     print(data); // Retrieve snippet from Realtime Database
  //     return Marker(
  //       markerId: MarkerId(doc.id),
  //       position: LatLng(lat, lng),
  //       infoWindow: InfoWindow(
  //         title: location,
  //         snippet: await snippet, // Use the retrieved snippet
  //       ),
  //     );
  //   });

  //   setState(() {
  //     markers.addAll(newmarkers as Iterable<Marker>);
  //   });
  // }

  Future<void> fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    final newmarkers = snapshot.docs.map((doc) {
      final data = doc.data();
      final lat = data['latitude'] as double;
      final lng = data['longitude'] as double;
      final location = data['location'] as String;
      final snippet = data['snippet'] as String;
      var availablespace = data['availspace'] as num;

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: location,
          snippet: 'Available Space: $availablespace $snippet',
        ),
      );
    });

    setState(() {
      markers.addAll(newmarkers);
    });
  }

  // Future<void> _showParkingDetails(String Parkingid) async {
  //   DatabaseReference parkingRef =
  //       FirebaseDatabase.instance.ref("Parking").child(Parkingid);

  //   DataSnapshot snapshot = (await parkingRef.once()) as DataSnapshot;
  //   if (snapshot.value != null) {
  //     dynamic data = snapshot.value;
  //     data = data.cast<String, dynamic>();

  //     if (data != null && data is Map) {
  //       Map<String, dynamic> mapData = data.cast<String, dynamic>();
  //       String name = mapData['name'] as String;
  //       int availableSpace = mapData['availspace'] as int;
  //       int totalSpace = mapData['totalspace'] as int;
  //       //String address = mapData['address'] as String;

  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text(name),
  //             content: SingleChildScrollView(
  //               child: ListBody(
  //                 children: <Widget>[
  //                   //Text("Address: $address"),
  //                   Text("Available space: $availableSpace"),
  //                   Text("Total space: $totalSpace"),
  //                 ],
  //               ),
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   }
  // }

  // Future<void> fetchMarkers() async {
  //   DatabaseReference parkingRef = FirebaseDatabase.instance.ref("Parking");

  //   DataSnapshot snapshot = (await parkingRef.once()) as DataSnapshot;
  //   print(snapshot);
  //   Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  //   if (data != null) {
  //     final newmarkers = data.entries.map((entry) {
  //       final doc = entry.value;
  //       final lat = doc['latitude'] as double;
  //       final lng = doc['longitude'] as double;
  //       final location = doc['location'] as String;
  //       final snippet = doc['snippet'] as String;
  //       var availablespace = doc['availspace'] as num;

  //       return Marker(
  //         markerId: MarkerId(entry.key.toString()),
  //         position: LatLng(lat, lng),
  //         infoWindow: InfoWindow(
  //           title: location,
  //           snippet: 'Available Space: $availablespace $snippet',
  //         ),
  //       );
  //     });

  //     setState(() {
  //       markers.addAll(newmarkers);
  //     });
  //   }
  // }

  // Future<void> fetchCircles() async {
  //   final snapshot =
  //       await FirebaseFirestore.instance.collection('Parking').get();
  //   final newCircles = snapshot.docs.map((doc) {
  //     final data = doc.data();
  //     final lat = data['latitude'] as double;
  //     final lng = data['longitude'] as double;
  //     final radius = data['radius'] as int;
  //     return Circle(
  //       circleId: CircleId(doc.id),
  //       center: LatLng(lat, lng),
  //       radius: radius.toDouble(),
  //       fillColor: Colors.green.withOpacity(0.2),
  //       strokeColor: Colors.green,
  //       visible: true,
  //     );
  //   });

  //   setState(() {
  //     circles.addAll(newCircles);
  //   });
  // }

  Future<void> fetchPolygons() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    final newPolygons = snapshot.docs.map((doc) {
      final data = doc.data();
      final points = List<LatLng>.from(data['points'].map((point) =>
          LatLng(point.latitude as double, point.longitude as double)));

      return Polygon(
        polygonId: PolygonId(doc.id),
        points: points,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
        visible: true,
      );
    }).toSet();
    setState(() {
      polygons.addAll(newPolygons);
    });
  }

// Future<void> listenForParkingUpdates() async {
//   Position position = await determinedPosition();
//   CollectionReference parkingSpots = FirebaseFirestore.instance.collection('Parking');
//   DatabaseReference databaseReference = FirebaseDatabase.instance.ref('https://mile2park-d82bd-default-rtdb.asia-southeast1.firebasedatabase.app/').child('Parking');

//   // Listen for changes to the parking spots collection.
//   listener = parkingSpots.snapshots().listen((snapshot) async {
//     for (QueryDocumentSnapshot doc in snapshot.docs) {
//       // Get the points of the parking spot.
//       List<LatLng> points = List<LatLng>.from((doc['points'] as List)
//         .map((point) => LatLng((point).latitude, (point).longitude)));

//       // Check if the user's position is within the polygon defined by the points.
//       bool isWithin = pointInPolygon(LatLng(position.latitude, position.longitude), points);

//       // If the user's position is within the polygon, update the availability of the parking spot.
//       if (isWithin) {
//         databaseReference.child(doc.id).once().then((snapshot) async {
//           int availableSpace = snapshot.value['availspace'] as int;
//           int totalSpace = snapshot.value['totalspace'] as int;

//           if (availableSpace > 0) {
//             await databaseReference.child(doc.id).update({
//               'availspace': totalSpace - 1,
//             });
//           } else {
//             const Text('Parking area is full');
//           }
//         });
//       } else {
//         databaseReference.child(doc.id).once().then((snapshot) async {
//           int availableSpace = snapshot.data['availspace'] as int;
//           int totalSpace = snapshot.data['totalspace'] as int;

//           if (availableSpace < totalSpace) {
//             await databaseReference.child(doc.id).update({
//               'availspace': availableSpace + 1,
//             });
//           }
//         });
//       }
//     }
//   });
// }

  // Future<void> listenForParkingUpdates() async {
  //   Position position = await determinedPosition();
  //   CollectionReference parkingSpots =
  //       FirebaseFirestore.instance.collection('Parking');

  //   listener = parkingSpots.snapshots().listen((snapshot) async {
  //     for (QueryDocumentSnapshot doc in snapshot.docs) {
  //       List<LatLng> points = List<LatLng>.from((doc['points'] as List)
  //           .map((point) => LatLng((point).latitude, (point).longitude)));

  //       bool isWithin = pointInPolygon(
  //           LatLng(position.latitude, position.longitude), points);

  //       if (isWithin) {
  //         int availableSpace = doc['availspace'] as int;
  //         int totalSpace = doc['totalspace'] as int;
  //         if (availableSpace > 0) {
  //           await parkingSpots.doc(doc.id).update({
  //             'availspace': totalSpace - 1,
  //           });
  //         } else {
  //           const Text("Parking area is full");
  //         }
  //       } else {
  //         int availableSpace = doc['availspace'] as int;
  //         int totalSpace = doc['totalspace'] as int;
  //         if (availableSpace < totalSpace) {
  //           await parkingSpots.doc(doc.id).update({
  //             'availspace': availableSpace + 1,
  //           });
  //         }
  //       }
  //     }
  //   });
  // }
}
