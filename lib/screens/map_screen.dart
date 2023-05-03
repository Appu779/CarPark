import 'package:CarPark/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'SideBar.dart';

const LatLng currentLocation = LatLng(12.092770, 75.194881);

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late AnimationController animationController;

  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _enableLocationService();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  Future<void> _enableLocationService() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: AnimatedMenu(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: currentLocation,
              zoom: 18,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
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
                        builder: (context) => SideBar(),
                      ));
                } else {
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
          Position position = await _determinedPosition();

          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 13)));
        },
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<Position> _determinedPosition() async {
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
}
