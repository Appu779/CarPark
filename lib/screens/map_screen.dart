import 'package:CarPark/components/map_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Set<Polygon> polygons = {};
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    LiveLocation();
    fetchMarkers();
    fetchPolygons();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
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
              // await fetchCircles();
              await fetchPolygons();
            },
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
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
                      )
                      );
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
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: location,
          snippet: snippet,
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
}
