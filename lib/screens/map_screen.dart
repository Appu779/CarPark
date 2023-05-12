import 'dart:async';

import 'package:CarPark/components/map_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/sidebar.dart';
// import 'package:geofence_flutter/geofence_flutter.dart';

const LatLng currentLocation = LatLng(12.092770, 75.194881);

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late AnimationController animationController;
  //late StreamSubscription<Position> positionStreamSubscription;
  StreamSubscription<QuerySnapshot>? listener;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polygon> polygons = {};
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    enableLocationService();
    fetchMarkers();
    fetchPolygons();
    listenForParkingUpdates();
    // positionStreamSubscription =
    //     Geolocator.getPositionStream().listen((position) {
    //   checkParkingAvailability();
    // });
    //geofence();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    // positionStreamSubscription.cancel();
    animationController.dispose();
    listener?.cancel();
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
              listenForParkingUpdates();
              //await geofence();
              //checkParkingAvailability();
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
            circles: circles,
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          Position position = await determinedPosition();

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

  Future<Position> determinedPosition() async {
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

  Future<void> fetchCircles() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    final newCircles = snapshot.docs.map((doc) {
      final data = doc.data();
      final lat = data['latitude'] as double;
      final lng = data['longitude'] as double;
      final radius = data['radius'] as int;
      return Circle(
        circleId: CircleId(doc.id),
        center: LatLng(lat, lng),
        radius: radius.toDouble(),
        fillColor: Colors.green.withOpacity(0.2),
        strokeColor: Colors.green,
        visible: true,
      );
    });

    setState(() {
      circles.addAll(newCircles);
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

  // Future<void> geofence() async {
  //   final snapshot =
  //       await FirebaseFirestore.instance.collection('Parking').get();
  //   final parkingData = snapshot.docs.first.get('P1');
  //   final latitude = parkingData['latitude'] as double;
  //   final longitude = parkingData['longitude'] as double;
  //   final radiusMeter = parkingData['radius'] as double;
  //   final eventPeriodInSeconds = parkingData['eventPeriod'] as num;

  //   await Geofence.startGeofenceService(
  //       pointedLatitude: latitude.toString(),
  //       pointedLongitude: longitude.toString(),
  //       radiusMeter: radiusMeter.toString(),
  //       eventPeriodInSeconds: eventPeriodInSeconds.toInt());

  //   StreamSubscription<GeofenceEvent>? geofenceEventStream =
  //       Geofence.getGeofenceStream()?.listen((GeofenceEvent event) async {
  //     int availableSpace = parkingData['availspace'] as int;
  //     if (availableSpace > 0) {
  //       await parkingData.update('availspace', (value) => availableSpace - 1);
  //     }
  //   });

  //   Geofence.stopGeofenceService();
  //   geofenceEventStream?.cancel();
  // }

  // void checkParkingAvailability() async {
  //   Position position = await determinedPosition();
  //   CollectionReference parkingSpots =
  //       FirebaseFirestore.instance.collection('Parking');
  //   StreamSubscription<QuerySnapshot> listener =
  //       parkingSpots.snapshots().listen((snapshot) async {
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
  //             'availspace': availableSpace,
  //           });
  //         }
  //       }
  //     }
  //   });
  // }

  Future<void> listenForParkingUpdates() async {
    Position position = await determinedPosition();
    CollectionReference parkingSpots =
        FirebaseFirestore.instance.collection('Parking');

    listener = parkingSpots.snapshots().listen((snapshot) async {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        List<LatLng> points = List<LatLng>.from((doc['points'] as List)
            .map((point) => LatLng((point).latitude, (point).longitude)));

        bool isWithin = pointInPolygon(
            LatLng(position.latitude, position.longitude), points);

        if (isWithin) {
          int availableSpace = doc['availspace'] as int;
          int totalSpace = doc['totalspace'] as int;
          if (availableSpace > 0) {
            await parkingSpots.doc(doc.id).update({
              'availspace': totalSpace - 1,
            });
          } else {
            const Text("Parking area is full");
          }
        } else {
          int availableSpace = doc['availspace'] as int;
          int totalSpace = doc['totalspace'] as int;
          if (availableSpace < totalSpace) {
            await parkingSpots.doc(doc.id).update({
              'availspace': availableSpace + 1,
            });
          }
        }
      }
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
