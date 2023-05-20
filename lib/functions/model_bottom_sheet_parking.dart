import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../components/nearbypark.dart';

void showBottomSheetParking(BuildContext context, String parkingId) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.doc(parkingId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            return SizedBox(
              height: 200,
              child: Column(
                children: [
                  Text(
                    snapshot.data!['location'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Available Parking"),
                      trailing: CircleAvatar(
                        child: Text(
                            "${snapshot.data!['totalspace'] - snapshot.data!['vehicles'].length}"),
                      ),
                      onTap: () {
                        // Perform share action
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Total Parking"),
                      trailing: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text("${snapshot.data!['totalspace']}"),
                      ),
                      onTap: () {
                        // Perform share action
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),
                ],
              ),
            );
          });
    },
  );
}

void showNearbyParking(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return FutureBuilder<Position>(
        future: getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          if (snapshot.hasError) {
            return Container(); // Handle error case
          }

          final currentPosition = snapshot.data;
          print(snapshot.data);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('Parking').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.hasError) {
                return Container(); // Handle error case
              }

              final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  parkingList = snapshot.data!.docs;
              print(snapshot.data);

              final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  nearbyParkingList =
                  filterNearbyParkings(parkingList, currentPosition!);

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: nearbyParkingList.length,
                  itemBuilder: (context, index) {
                    final parkingData = nearbyParkingList[index].data();

                    return Column(
                      children: [
                        const Text(
                    "NearBy Parking Areas",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                        Card(
                          child: ListTile(
                            title: Text(parkingData['location']),
                            trailing: CircleAvatar(
                        child: Text(
                            "${parkingData['totalspace'] - parkingData['vehicles'].length}"),
                      ),
                            onTap: () {
                              // Perform share action or navigate to the parking details screen
                              Navigator.pop(context); // Close the bottom sheet
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      );
    },
  );
}

