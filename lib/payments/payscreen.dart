import 'package:CarPark/payments/payapps.dart';
import 'package:flutter/material.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final String location;
  final int availableSpace;

  const ParkingDetailsScreen(
      {Key? key, required this.location, required this.availableSpace})
      : super(key: key);

  @override
  ParkingDetailsScreenState createState() => ParkingDetailsScreenState();
}

class ParkingDetailsScreenState extends State<ParkingDetailsScreen>
    with SingleTickerProviderStateMixin {
  int parkingDuration = 1;
  double parkingRate = 20;

  void calculateParkingAmount() {
    double amount = parkingDuration * parkingRate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Parking Amount'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Payable Amount:',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text('\u20B9$amount',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpiPay(
                            amount: amount,
                            location: widget.location,
                          )),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Location :",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.location,
                style: const TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 20),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Available Space :",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "${widget.availableSpace}",
                style: const TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontSize: 20),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(7),
                      child: const Icon(
                        Icons.timer_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                "Duration Of Parking :",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(
                width: 10,
              ),
              DropdownButton<int>(
                value: parkingDuration,
                onChanged: (value) {
                  setState(() {
                    parkingDuration = value!;
                  });
                },
                items: const [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('1 hour'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('2 hours'),
                  ),
                  // Add more duration options if needed
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              calculateParkingAmount();
            },
            icon: Image.asset(
              "assets/images/c1.png",
              height: 32,
              width: 32,
            ),
            label: const Text('Calculate Amount'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ]),
      ),
    );
  }
}
