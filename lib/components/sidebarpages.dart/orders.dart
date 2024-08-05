import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersHistory extends StatefulWidget {
  const OrdersHistory({Key? key}) : super(key: key);

  @override
  State<OrdersHistory> createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('orders')
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to fetch order details.'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final orders = snapshot.data!.docs;
            if (orders.isEmpty) {
              return const Center(
                child: Text('No orders found.'),
              );
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (BuildContext context, int index) {
                final order = orders[index];
                final orderData = order.data() as Map<String, dynamic>;
                final transactionId = orderData['transactionId'];
                final status = orderData['status'];
                final location = orderData['location'];
                // Render the order details UI for each order
                const SizedBox(
                  height: 10,
                );
                return Card(
                  child: ListTile(
                    title: Text('Location: $location'),
                    subtitle: Text('Status: $status'
                        '\n'
                        'Transaction ID: $transactionId'),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('No orders found.'),
          );
        },
      ),
    );
  }
}
