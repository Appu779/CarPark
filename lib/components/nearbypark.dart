import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentPosition() async {
  // Use the Geolocator package to get the current position of the device
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  final Position position = await geolocator.getCurrentPosition();
  return position;
}

List<QueryDocumentSnapshot<Map<String, dynamic>>> filterNearbyParkings(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> parkingList,
  Position currentPosition,
) {
  // Filter the parking list based on the proximity to the current position
  const double maxDistanceInMeters =
      1000; // Maximum distance in meters to consider as nearby
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> nearbyParkings = [];

  for (final parking in parkingList) {
    final parkingData = parking.data();
    final parkingLatitude = parkingData['latitude'] as double;
    final parkingLongitude = parkingData['longitude'] as double;
    final parkingPosition = Position(
        latitude: parkingLatitude,
        longitude: parkingLongitude,
        timestamp: null,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);

    final distance = GeolocatorPlatform.instance.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      parkingPosition.latitude,
      parkingPosition.longitude,
    );

    if (distance <= maxDistanceInMeters) {
      nearbyParkings.add(parking);
    }
  }

  return nearbyParkings;
}
