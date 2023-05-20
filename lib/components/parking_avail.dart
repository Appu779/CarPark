import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';

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

late StreamSubscription<Position> positionStreamSubscription;
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
        //await doc.reference.update({'parkedcar': availableSpace});
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
