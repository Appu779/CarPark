import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';

class CheckAvailability {
  Future<void> listenForParkingUpdates() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    print(uid);
    CollectionReference parkingSpotsRef =
        FirebaseFirestore.instance.collection('Parking');

    parkingSpotsRef.snapshots().listen((snapshot) async {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int availableSpace = data['availspace'] as int;
        int totalSpace = data['totalspace'] as int;

        List<GeoPoint> points = List<GeoPoint>.from(data['points']);

        List<LatLng> latLngPoints = points
            .map((geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude))
            .toList();

        Position position = await Geolocator.getCurrentPosition();
        bool isWithin = pointInPolygon(
            LatLng(position.latitude, position.longitude), latLngPoints);
        print(isWithin);
        if (isWithin) {
          FirebaseServices().addVehicle(uid: uid, parkingId: doc.id);
          availableSpace = availableSpace - 1;
        } else {
          FirebaseServices().removeVehicle(uid, doc.id);
          availableSpace = availableSpace + 1;
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
