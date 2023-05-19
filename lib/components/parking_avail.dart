import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

class Checkavilability {
  Future<void> listenForParkingUpdates() async {
    DatabaseReference parkingSpotsRef =
        FirebaseDatabase.instance.ref("Parking");

    parkingSpotsRef.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      dynamic data = snapshot.value;
      data = data.cast<String, dynamic>();

      if (data != null && data is Map) {
        Map<String, dynamic> mapData = data.cast<String, dynamic>();
        Position position = await Geolocator.getCurrentPosition();
        

        for (String key in mapData.keys) {
          Map doc = mapData[key];
          int availableSpace = doc['availspace'] as int;
          int totalSpace = doc['totalspace'] as int;
          int parkedUsers = doc['parkedcar'] as int; // default to 0 if not set

          List<LatLng> points = List<LatLng>.generate(
            doc['points'].length,
            (i) => LatLng(
              doc['points'][i]['latitude'] as double,
              doc['points'][i]['longitude'] as double,
            ),
          );

          bool isWithin = pointInPolygon(
              LatLng(position.latitude, position.longitude), points);

          if (isWithin) {
            if (parkedUsers == 0 &&
                availableSpace > 0 &&
                availableSpace <= totalSpace) {
              await parkingSpotsRef.child(key).update({
                'availspace': availableSpace - 1,
                'parkedcar': 1, // set parked users to 1
              });
            } else if (availableSpace == 0) {
            } else {}
          } else {
            if (parkedUsers > 0 && availableSpace <= totalSpace) {
              await parkingSpotsRef.child(key).update({
                'parkedcar': parkedUsers - 1,
                'availspace':
                    availableSpace + 1 // increment available space by 1
              });
            }
          }
        }
      }

      Timer(const Duration(seconds: 4), () {
        listenForParkingUpdates();
      });
    });
  }
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

class Nearby {
  String id;
  double latitude;
  double longitude;

  Nearby(this.id, this.latitude, this.longitude);
}

class NearbyParkingService {
  Future<List<Nearby>> getNearbyParkingSpots(double radius) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    DatabaseReference parkingSpotsRef =
        FirebaseDatabase.instance.ref().child('Parking');

    DataSnapshot snapshot = (await parkingSpotsRef.once()) as DataSnapshot;

    List<Nearby> nearbySpots = [];

    if (snapshot.value != null) {
      Map data = snapshot.value as Map;
      print(data);
      data.forEach((key, value) {
        double latitude = value['latitude'] as double;
        double longitude = value['longitude'] as double;

        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          latitude,
          longitude,
        );

        if (distance <= radius) {
          Nearby spot = Nearby(key.toString(), latitude, longitude);
          nearbySpots.add(spot);
        }
      });
    }

    return nearbySpots;
  }
}
