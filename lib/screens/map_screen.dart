import 'dart:async';

import 'package:CarPark/components/sidebarpages.dart/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../components/sidebarpages.dart/drawerheader.dart';
import '../components/sidebarpages.dart/orders.dart';
import '../functions/model_bottom_sheet_parking.dart';
import '../functions/nearbyparking_bsheet.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';

const LatLng currentLocation = LatLng(12.092770, 75.194881);

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late AnimationController animationController;
  late StreamSubscription<Position> positionStreamSubscription; // Add this line

  late Timer timer;
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    enableLocationService();
    requestStoragePermission();
    fetchMarkers();
    fetchPolygons();
    //listenForParkingUpdates();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    animationController.dispose();
    positionStreamSubscription.cancel();
    super.dispose();
  }

  var currentPage = DrawerSections.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mile2Park'),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: CustomDrawerShape(),
                child: Container(
                  color: Colors.blue, // Set your desired background color
                  child: Column(
                    children: const [
                      MyHeaderDrawer(),
                      // Add any additional content for the header
                    ],
                  ),
                ),
              ),
              myDrawerList(),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: currentLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) async {
              mapController = controller;
              fetchMarkers();
              fetchPolygons();
              listenForParkingUpdates();
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
              left: 20,
              bottom: 8.0,
              child: FloatingActionButton(
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
              )),
          Positioned(
              left: 20,
              bottom: 70.0,
              child: FloatingActionButton(
                onPressed: () {
                  //findNearbyParkingAreas();
                  showNearbyParking(context);
                },
                tooltip: 'Nearby Parking',
                child: const Icon(Icons.local_parking_sharp),
              ))
        ],
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      // Permission granted
      // You can proceed with accessing storage
    } else if (status == PermissionStatus.denied) {
      // Permission denied
      return;
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
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

  Future<void> fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    final newmarkers = snapshot.docs.map((doc) {
      final data = doc.data();
      final lat = data['latitude'] as double;
      final lng = data['longitude'] as double;
      final location = data['location'] as String;

      return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: location,
          ),
          onTap: () {
            showBottomSheetParking(context, doc.reference.path);
          });
    });

    setState(() {
      markers.addAll(newmarkers);
    });
  }

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

  Stream<Position> getUserPositionStream() {
    // Create a StreamController for the user's position
    StreamController<Position> positionStreamController =
        StreamController<Position>();

    // Get the user's position using Geolocator
    Geolocator.getCurrentPosition().then((position) {
      // Add the initial position to the stream
      positionStreamController.add(position);

      // Listen for position changes and add them to the stream
      Geolocator.getPositionStream().listen((position) {
        positionStreamController.add(position);
      });
    }).catchError((error) {
      // Handle any errors that occur while getting the position
      positionStreamController.addError(error);
    });

    // Return the stream from the StreamController
    return positionStreamController.stream;
  }

  Future<void> listenForParkingUpdates() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference parkingSpotsRef =
        FirebaseFirestore.instance.collection('Parking');

    Stream<Position> positionStream = getUserPositionStream();

    positionStreamSubscription = positionStream.listen((position) {
      parkingSpotsRef.get().then((snapshot) async {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          List<GeoPoint> points = List<GeoPoint>.from(data['points']);

          List<LatLng> latLngPoints = points
              .map((geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude))
              .toList();

          bool isWithin = pointInPolygon(
              LatLng(position.latitude, position.longitude), latLngPoints);

          //print(isWithin);
          if (isWithin) {
            FirebaseServices().addVehicle(uid: uid, parkingId: doc.id);
          } else {
            FirebaseServices().removeVehicle(uid, doc.id);
          }

          // Update the 'parkedcar' count in the Firestore document
          //await doc.reference.update({'availspace': availableSpace});
        }
      });
    }, onError: (error) {
      // Handle any errors that occur while getting the user's position
      print(error);
    });
  }

  bool pointInPolygon(LatLng point, List<LatLng> points) {
    int crossings = 0;

    for (int i = 0; i < points.length; i++) {
      LatLng a = points[i];
      LatLng b = points[(i + 1) % points.length];
      if (((a.latitude <= point.latitude) && (point.latitude < b.latitude)) ||
          ((b.latitude <= point.latitude) && (point.latitude < a.latitude))) {
        double vt = (point.latitude - a.latitude) / (b.latitude - a.latitude);
        if (point.longitude < a.longitude + vt * (b.longitude - a.longitude)) {
          crossings++;
        }
      }
    }

    return (crossings % 2 == 1);
  }

  Widget myDrawerList() {
    //bool isLightThemeSelected = true; // Initial selection

    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuItem(1, "Home", Icons.home, currentPage == DrawerSections.home),
          menuItem(2, "Profile", Icons.person, currentPage == DrawerSections.profile),
          menuItem(3, "Transactions", Icons.history,
              currentPage == DrawerSections.orders),
          const Divider(),
          menuItem(
              4, "Log Out", Icons.logout, currentPage == DrawerSections.logout),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              currentPage = DrawerSections.home;
            }
            else if(id==2){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfilePage()));
            } else if (id == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrdersHistory()));
            } else if (id == 4) {
              performLogout();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void performLogout() async {
    FirebaseServices().signOut();

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

enum DrawerSections { home, orders, logout, profile }
