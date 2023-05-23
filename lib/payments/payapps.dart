import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class UpiPay extends StatefulWidget {
  double amount;
  String location;

  UpiPay({Key? key, required this.amount, required this.location})
      : super(key: key);

  @override
  _UpiPayState createState() => _UpiPayState();
}

class _UpiPayState extends State<UpiPay> {
  Future<UpiResponse>? _transaction;
  UpiIndia upiIndia = UpiIndia();
  List<UpiApp>? apps;
  late String _qrCodeData;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> _initiateTransaction(UpiApp app) async {
    final user = FirebaseAuth.instance.currentUser;

    // Generate a unique transaction ID for each user
    final transactionId =
        '${user?.uid}_${DateTime.now().millisecondsSinceEpoch}';

    // Build the order details object
    final orderDetails = {
      'transactionId': transactionId,
      'receiverUpiId': "unnisapna123@upi",
      'receiverName': 'UNNIKRISHNAN SAPNA',
      'transactionRefId': 'TestingUpiIndiaPlugin',
      'transactionNote': 'Parking Amount pay',
      'amount': widget.amount,
      'location': widget,
      'status': 'Pending', // Initial status is set to Pending
    };

    // Store the order details in the user's subcollection in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('orders')
        .doc(transactionId)
        .set(orderDetails);

    return upiIndia.startTransaction(
      app: app,
      receiverUpiId: "unnisapna123@upi",
      receiverName: 'VAISHNAV KRISHNA',
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Parking Amount pay',
      amount: widget.amount,
    );
  }

  Widget _displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = _initiateTransaction(app);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        _updateTransactionStatus('Success');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        _updateTransactionStatus('Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  void _updateTransactionStatus(String status) {
    final user = FirebaseAuth.instance.currentUser;

    // Update the status in Firestore for the specific user
    FirebaseFirestore.instance
        .collection('orders')
        .doc(user?.uid)
        .update({'status': status}).then((_) {
      setState(() {});
    });
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Apps'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse _upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = _upiResponse.transactionId ?? 'N/A';
                  String resCode = _upiResponse.responseCode ?? 'N/A';
                  String txnRef = _upiResponse.transactionRefId ?? 'N/A';
                  String status = _upiResponse.status ?? 'N/A';
                  String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
