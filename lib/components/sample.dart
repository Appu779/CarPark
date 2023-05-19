// Future<void> listenForParkingUpdates() async {
//   DatabaseReference parkingSpotsRef = FirebaseDatabase.instance.ref("Parking");

//   parkingSpotsRef.onValue.listen((event) async {
//     DataSnapshot snapshot = event.snapshot;
//     dynamic data = snapshot.value;
//     data = data.cast<String, dynamic>();

//     if (data != null && data is Map) {
//       Map<String, dynamic> mapData = data.cast<String, dynamic>();
//       Position position = await Geolocator.getCurrentPosition();

//       for (String key in mapData.keys) {
//         Map doc = mapData[key];
//         int availableSpace = doc['availspace'] as int;
//         int totalSpace = doc['totalspace'] as int;
//         int parkedUsers = doc['parkedcar'] as int; // default to 0 if not set

//         List<LatLng> points = List<LatLng>.generate(
//           doc['points'].length,
//           (i) => LatLng(
//             doc['points'][i]['latitude'] as double,
//             doc['points'][i]['longitude'] as double,
//           ),
//         );

//         bool isWithin = pointInPolygon(
//             LatLng(position.latitude, position.longitude), points);

//         if (isWithin) {
//           if (parkedUsers == 0 && availableSpace > 0 && availableSpace <= totalSpace) {
//             // Try to reserve a parking spot
//             parkingSpotsRef.child(key).runTransaction((mutableData) async {
//               if (mutableData.value == null) {
//                 // The parking spot has been deleted by another user
//                 return null;
//               }

//               int availspace = mutableData.value['availspace'];
//               int parkedcar = mutableData.value['parkedcar'];

//               if (availspace > 0 && parkedcar == 0) {
//                 mutableData.value['availspace'] = availspace - 1;
//                 mutableData.value['parkedcar'] = 1;
//                 return mutableData;
//               }

//               // The parking spot is already taken or full
//               return null;
//             });
//           } else if (availableSpace == 0) {
//             print("it is full");
//           } else {
//             // Try to park a car in a parking spot
//             parkingSpotsRef.child(key).runTransaction((mutableData) async {
//               if (mutableData.value == null) {
//                 // The parking spot has been deleted by another user
//                 return null;
//               }

//               int availspace = mutableData.value['availspace'];
//               int parkedcar = mutableData.value['parkedcar'];

//               if (availspace > 0 && parkedcar > 0) {
//                 mutableData.value['availspace'] = availspace - 1;
//                 mutableData.value['parkedcar'] = parkedcar + 1;
//                 return mutableData;
//               }

//               // The parking spot is already taken or full
//               return null;
//             });
//           }
//         } else {
//           if (parkedUsers > 0 && availableSpace <= totalSpace) {
//             // Try to unpark a car from a parking spot
//             parkingSpotsRef.child(key).runTransaction((
