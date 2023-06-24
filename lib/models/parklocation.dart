import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

class ParkingSpace {
  final String id;
  final String name;
  final LatLng location;

  ParkingSpace({
    required this.id,
    required this.name,
    required this.location,
  });
}

Stream<List<ParkingSpace>> getParkingspace(Position userLocation) {
  if (userLocation == null) {
    return Stream.value([]);
  }
  
  double radius = 10.0;
  return FirebaseFirestore.instance
      .collection('Parking')
      .where('latitude', isGreaterThan: userLocation.latitude - (radius / 110.574))
      .where('latitude', isLessThan: userLocation.latitude + (radius / 110.574))
      .where('longitude', isGreaterThan: userLocation.longitude - (radius / (111.320 * cos(userLocation.latitude))))
      .where('longitude', isLessThan: userLocation.longitude + (radius / (111.320 * cos(userLocation.latitude))))
      .snapshots()
      .map((snapshots) {
    return snapshots.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      String id = doc.id;
      String name = data['name'];
      LatLng location = LatLng(data['latitude'], data['longitude']);
      
      return ParkingSpace(
        id: id,
        name: name,
        location: location,
      );
    }).toList();
  });
}
