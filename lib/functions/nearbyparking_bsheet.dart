import 'package:CarPark/payments/payscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/nearbypark.dart';

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

              final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  nearbyParkingList =
                  filterNearbyParkings(parkingList, currentPosition!);

              if (nearbyParkingList.isEmpty) {
                return const Center(
                  child: Text(
                    'No parking space found nearby.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: nearbyParkingList.length,
                  itemBuilder: (context, index) {
                    final parkingData = nearbyParkingList[index].data();
                    // final parkingSpotId = nearbyParkingList[index].id;

                    return Column(
                      children: [
                        const Text(
                          "Nearby Parking Areas",
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
                              //Navigator.pop(context); // Close the bottom sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParkingDetailsScreen(
                                    availableSpace: parkingData['totalspace'] -
                                        parkingData['vehicles'].length,
                                    location: parkingData['location'],
                                  ),
                                ),
                              );
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
