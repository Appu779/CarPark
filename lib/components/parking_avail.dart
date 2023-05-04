import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> decrementParkingSpace(MarkerId markerId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('parking')
      .doc(markerId.value)
      .get();
  final data = snapshot.data();
  final availableSpace = data?['availableSpace'] as int? ?? 0;
  if (availableSpace > 0) {
    await FirebaseFirestore.instance
        .collection('parking')
        .doc(markerId.value)
        .update({'availSpace': availableSpace - 1});
  } 
  else {
    await FirebaseFirestore.instance
        .collection('parking')
        .doc(markerId.value)
        .update({'availSpace' : availableSpace + 1});
  }
}
