import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

List<String> carList = [];
bool isUpdatingSpace = false; // Flag to indicate if space update is in progress
Completer<void>? spaceUpdateCompleter; // Completer to wait for space update

Future<void> listenForParkingUpdates() async {
  DatabaseReference parkingSpotsRef = FirebaseDatabase.instance.ref("Parking");

  parkingSpotsRef.onValue.listen((event) async {
    if (isUpdatingSpace) {
      // If an update is already in progress, wait for it to complete
      await spaceUpdateCompleter?.future;
    }

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
            LatLng(position.latitude, position.longitude),
            points,
          );

          if (isWithin) {
            if (parkedUsers == 0 && availableSpace > 0 && availableSpace <= totalSpace) {
              String carId = generateCarId(); // Generate a unique car ID
              await _acquireLock(); // Acquire the lock
              await parkingSpotsRef.child(key).runTransaction((mutableData) async {
                if (mutableData.value != null) {
                  int currentAvailableSpace = mutableData.value['availspace'] ?? 0;
                  int currentParkedUsers = mutableData.value['parkedcar'] ?? 0;

                  if (currentAvailableSpace > 0 && currentParkedUsers == 0) {
                    mutableData.value['availspace'] = currentAvailableSpace - 1;
                    mutableData.value['parkedcar'] = currentParkedUsers + 1;
                    carList.add(carId); // Add the car ID to the list
                  }
                }
                return mutableData;
              } as TransactionHandler);
              await _releaseLock(); // Release the lock
            }
          } else {
            if (parkedUsers > 0 && availableSpace < totalSpace) {
              await _acquireLock(); // Acquire the lock
              await parkingSpotsRef.child(key).runTransaction((mutableData) async {
                if (mutableData.value != null) {
                  int currentAvailableSpace = mutableData.value['availspace'] ?? 0;
                  int currentParkedUsers = mutableData.value['parkedcar'] ?? 0;

                  if (currentParkedUsers > 0 && currentAvailableSpace < totalSpace) {
                    mutableData.value['availspace'] = currentAvailableSpace + 1;
                    mutableData.value['parkedcar'] = currentParkedUsers - 1;
                    carList.remove(key); // Remove the car ID from the list
                  }
                }
                return mutableData;
              } as TransactionHandler);
              await _releaseLock(); // Release the lock
            }
          }
        }
      }
    }
  });
}

Future<void> _acquireLock() async {
  while (isUpdatingSpace) {
    // Wait until the lock is released
    await Future.delayed(const Duration(milliseconds: 100));
  }
  isUpdatingSpace = true;
  spaceUpdateCompleter = Completer<void>();
}

Future<void> _releaseLock() async {
  isUpdatingSpace = false;
  spaceUpdateCompleter?.complete();
  spaceUpdateCompleter = null;
}

String generateCarId() {
  // Implement your logic to generate a unique car ID
  // Example: You can use a combination of the current timestamp and a random number
  return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(9999).toString();
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
  Future<List<dynamic>> getNearbyParkingAreas(
      Position currentPosition, double radius) async {
    DatabaseReference parkingSpotsRef =
        FirebaseDatabase.instance.ref().child('Parking');

    // Retrieve all parking spots from the database
    DatabaseEvent snapshot = await parkingSpotsRef.once();
    dynamic parkingSpotsData = snapshot;

    // Calculate the distance between the user's location and each parking spot
    List<dynamic> nearbyParkingAreas = [];
    for (var entry in parkingSpotsData.entries) {
      String parkingSpotId = entry.key;
      Map<String, dynamic> parkingSpot = entry.value;

      double latitude = parkingSpot['latitude'] as double;
      double longitude = parkingSpot['longitude'] as double;
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        latitude,
        longitude,
      );

      // Check if the parking spot is within the specified radius
      if (distance <= radius) {
        // Add the nearby parking spot to the list
        nearbyParkingAreas.add({
          'parkingSpotId': parkingSpotId,
          'latitude': latitude,
          'longitude': longitude,
          'distance': distance,
        });
      }
    }

    return nearbyParkingAreas;
  }
}
