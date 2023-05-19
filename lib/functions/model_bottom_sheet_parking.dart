 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showBottomSheetParking(BuildContext context, String ParkingId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.doc(ParkingId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              return Container(
                height: 200,
                child: Column(
                  children: [
                    Text(
                      snapshot.data!['location'],
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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