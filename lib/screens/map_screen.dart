import 'dart:async';
import 'package:CarPark/components/nearbypark.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/parking_avail.dart';
import '../components/sidebar.dart';
import '../functions/model_bottom_sheet_parking.dart';
import '../services/firebase_service.dart';

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
    fetchMarkers();
    fetchPolygons();
    listenForParkingUpdates();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    // timer = Timer.periodic(const Duration(seconds: 4),
    //     runFunction); // Add this line to create the Timer
  }

  // void runFunction(Timer timer) {
  //   listenForParkingUpdates();
  // }

  @override
  void dispose() {
    animationController.dispose();
    positionStreamSubscription.cancel();
    //timer.cancel();
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
              fetchMarkers();
              fetchPolygons();

              listenForParkingUpdates();

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
      //floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Stack(children: [
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
      ]),
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

          print(isWithin);
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
}
