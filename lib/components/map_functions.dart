import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapData {
  static Future<List<Marker>> fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    return snapshot.docs.map((doc) {
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
    }).toList();
  }

  static Future<List<Circle>> fetchCircles() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    return snapshot.docs.map((doc) {
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
    }).toList();
  }

  static Future<Set<Polygon>> fetchPolygons() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Parking').get();
    return snapshot.docs.map((doc) {
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
  }
}



