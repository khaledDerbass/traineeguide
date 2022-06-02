import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';

class myStudent extends StatefulWidget {
  const myStudent({Key? key}) : super(key: key);

  @override
  _myStudentState createState() => _myStudentState();
}

class _myStudentState extends State<myStudent> {
  GoogleMapController? _controller;
  late Location currentLocation = Location();
  Set<Marker> _markers = {};
  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;
  static double lat = 0.0;
  static double lng = 0.0;
  var userSite = null;
  var username = null;
  final CHECK_IN = "CHECK_IN";
  final CHECK_OUT = "CHECK_OUT";
  String lastTransactionType = "";
  bool firstTime = false;

  void createCheckInRecord() {
    getLastUserTransaction();
    if ((lastTransactionType != "" && lastTransactionType != CHECK_IN) ||
        firstTime) {
      databaseReference
          .child("TransactionsHistory")
          .child(auth.currentUser!.uid)
          .push()
          .set({
        'type': 'CHECK_IN',
        'Date': (DateTime.now().day.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().year.toString()),
        'time': DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString(),
        'username': username,
        'site':'Al al-Bayt University',
        'location': {
          'lat': lat,
          'lng': lng,
        }
      }).then((value) => {
                showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                          title: Text('Alert'),
                          content: Text('Checked In Successfully'),
                        ))
              });
      setState(() {
        firstTime = false;
      });
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text('Alert'),
                content: Text('You cant Check In until you Checked Out'),
              ));
    }
  }

  void createCheckOutRecord() {
    getLastUserTransaction();
    if ((lastTransactionType != "" && lastTransactionType != CHECK_OUT) ||
        firstTime) {
      databaseReference
          .child("TransactionsHistory")
          .child(auth.currentUser!.uid)
          .push()
          .set({
        'type': 'CHECK_OUT',
        'time': DateTime.now().hour.toString() +
            ":" +
            DateTime.now().minute.toString(),
        'Date': (DateTime.now().day.toString() +
            "-" +
            DateTime.now().month.toString() +
            "-" +
            DateTime.now().year.toString()),
        'username': username,
        'site':'Al al-Bayt University',
        'location': {
          'lat': lat,
          'lng': lng,
        }
      }).then((value) => {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text('Alert'),
                          content: Text('Checked out Successfully'),
                        ))
              });
    } else {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                title: Text('Alert'),
                content:
                    Text('You cant check out because you are not checked in'),
              ));
    }
  }
  getStudentInfo(){
    databaseReference
        .child("Users")
        .child(auth.currentUser!.uid)
        .limitToLast(1)
        .once()
        .then((DataSnapshot snapshot) {
              setState(() {
                username = snapshot.value['username'];
                debugPrint(username);
              });
          });
  }
  getLastUserTransaction() {
    databaseReference
        .child("TransactionsHistory")
        .child(auth.currentUser!.uid)
        .limitToLast(1)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        databaseReference
            .child("TransactionsHistory")
            .child(auth.currentUser!.uid)
            .limitToLast(1)
            .once()
            .then((DataSnapshot snapshot) {
          setState(() {
            if (snapshot.value.entries != null) {
              print(snapshot.value.entries.elementAt(0).value['type']);
              lastTransactionType = snapshot.value.entries != null
                  ? snapshot.value.entries.elementAt(0).value['type']
                  : "";
            }
          });
        });
      } else {
        setState(() {
          firstTime = true;
        });
      }
    });
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(loc.latitude ?? 31.963158, loc.longitude ?? 35.930359),
        zoom: 15,
      )));

      lat = loc.latitude ?? 0.0;
      lng = loc.longitude ?? 0.0;
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('User_loc'),
            position:
                LatLng(loc.latitude ?? 31.963158, loc.longitude ?? 35.930359)));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getStudentInfo();
      getLocation();
      getLastUserTransaction();

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            elevation: null,
            backgroundColor: Colors.transparent,
            leading: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, 'student1');
              },
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black45,
              ),
            )),
        // backgroundColor: Colors.transparent,
        body: Stack(children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(31.963158, 35.930359),
              zoom: 12.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 40.0,
                ),
                child: Text(
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: 35,
                right: 35,
              ),
              child: Row(
                children: [
                  SizedBox(height: .02),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size(
                              MediaQuery.of(context).size.width * 0.365,
                              MediaQuery.of(context).size.height * 0.08),
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.365,
                              MediaQuery.of(context).size.height * 0.08),
                          primary: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          getLocation();
                          createCheckInRecord();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Check-IN '),
                            Icon(
                              Icons.add_location,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              maximumSize: Size(
                                  MediaQuery.of(context).size.width * 0.365,
                                  MediaQuery.of(context).size.height * 0.08),
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.365,
                                  MediaQuery.of(context).size.height * 0.08),
                              primary: Colors.black,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              getLocation();
                              createCheckOutRecord();
                              /*
                              final latSTS = 31.960287056858153;
                            final lonSTS = 35.85710239682962;

                            final latEst = 32.021217244153064;
                            final lonEst = 35.86053734959794;

                            final harvesine = new Haversine.fromDegrees(latitude1: latSTS,
                                longitude1: lonSTS,
                                latitude2: latEst,
                                longitude2: lonEst);
                            if (harvesine.distance() <.2 )
                                {
                                }
                               */
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Check-OUT '),
                                Icon(
                                  Icons.add_location_alt_outlined,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
