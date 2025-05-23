import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_run/model/timerModel.dart';
import 'package:go_run/screen/detailScreen.dart';
import 'package:go_run/screen/loginScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.uid});
  String uid;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<DocumentSnapshot> userData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> lastRun() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('runs')
        .orderBy('dateTime', descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> history() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('runs')
        .orderBy('dateTime', descending: true)
        .snapshots();
  }

  bool isPermissionEnabled = true;

  late List<Widget> pages;
  int selectedIndex = 0;

  Map user = {};

  //map records
  List<LatLng> path = [];

  StreamSubscription<Position>? getPositionStream;

  var nameCtrl = TextEditingController();

  GoogleMapController? mapCtrl;

  late Stream<List<Object>> combinedStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    combinedStream = Rx.combineLatest2(
      userData(),
      lastRun(),
      (userFromStrem, runFromStream) => [userFromStrem, runFromStream],
    );
    pages = [HomeWidget(), Leaderboards()];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    getPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF4554D2),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.white, // Label color for selected item
          unselectedItemColor: Colors.white70,
          backgroundColor: Color(0xFF4554D2),
          currentIndex: selectedIndex,
          onTap: (index) {
            selectedIndex = index;
            setState(() {});
            print("HELO $index");
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Leaderboards',
            ),
          ],
        ),
        drawer: Drawer(
          child: StreamBuilder(
            stream: history(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (snapshot.data == null) {
                return Center(
                  child: Text(
                    "No history",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              List history = snapshot.data!.docs;
              return Column(
                children: [
                  DrawerHeader(
                    child: Center(
                      child: Text(
                        "Recent Records",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: Color(0xFF4554D2),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (BuildContext context, int index) {
                        QueryDocumentSnapshot run = history[index];
                        return Card(
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: () {
                                nameCtrl.text =
                                    run['title'] == null ||
                                            run['title'].toString().isEmpty
                                        ? "${DateFormat('MMMM d, y h:mm a').format(run['dateTime'].toDate())}"
                                        : run['title'];
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text("Change Run Name"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameCtrl,
                                              decoration: InputDecoration(
                                                labelText: "Name",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.loading,
                                                    barrierDismissible: false,
                                                  );

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(widget.uid)
                                                      .collection('runs')
                                                      .doc(run.id)
                                                      .update({
                                                        'title': nameCtrl.text,
                                                      });

                                                  Navigator.of(context).pop();
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.success,
                                                    title:
                                                        "Updated successfully!",
                                                    onConfirmBtnTap: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      setState(() {});
                                                    },
                                                  );
                                                } on FirebaseException catch (
                                                  e
                                                ) {
                                                  QuickAlert.show(
                                                    context: context,
                                                    type: QuickAlertType.error,
                                                    title:
                                                        "Something went wrong!",
                                                  );
                                                }
                                              },
                                              child: Text(
                                                "Change name",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailScreen(
                                        uid: widget.uid,
                                        runId: run.id,
                                      ),
                                ),
                              );
                            },
                            title: Text(
                              run['title'] == null ||
                                      run['title'].toString().isEmpty
                                  ? "${DateFormat('MMMM d, y h:mm a').format(run['dateTime'].toDate())}"
                                  : run['title'],
                              style: TextStyle(color: Color(0xFF4554D2)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      label: Text("Logout"),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      icon: Icon(Icons.logout),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/GoRunLogo.png', width: 100),
            ),
          ],
          backgroundColor: Colors.transparent,
        ),
        body: IndexedStack(children: pages, index: selectedIndex),
      ),
    );
  }

  Widget HomeWidget() {
    return StreamBuilder(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("No info.", style: TextStyle(color: Colors.white)),
          );
        }
        //convert the snapshot to documentsnapshot muna and then
        DocumentSnapshot userSnapshot = snapshot.data![0] as DocumentSnapshot;
        //make it a map
        user = userSnapshot.data() as Map;

        //convert the snapshot to documentsnapshot muna and then
        QuerySnapshot lastRunSnapshot = snapshot.data![1] as QuerySnapshot;

        // for the last run path
        Map lastRun = {};
        List firebasepath = [];
        List<LatLng> extractedPath = [];

        if (lastRunSnapshot.docs.isNotEmpty) {
          lastRun = lastRunSnapshot.docs.first.data() as Map;
          firebasepath = lastRun['path'];
          extractedPath =
              firebasepath.map((e) {
                return LatLng(e['lat'], e['lng']);
              }).toList();
        }
        return Consumer<Timermodel>(
          builder:
              (context, value, child) => Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(color: Color(0xFF4554D2)),
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Hello ${user['username']}!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      "Personal Record",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Longest Run",
                                style: TextStyle(
                                  color: Color(0xFF86B6FF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                user['longestRun'] == 0
                                    ? "--:--"
                                    : "${double.parse(user['longestRun'].toString()).toStringAsFixed(2)} KM",
                                style: TextStyle(
                                  color: Color(0xFF86B6FF),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Pace",
                                style: TextStyle(
                                  color: Color(0xFF86B6FF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                user['inSeconds'] == 0
                                    ? "--:--"
                                    : calculatePace(
                                      user['longestRun'],
                                      user['inSeconds'],
                                    ),
                                style: TextStyle(
                                  color: Color(0xFF86B6FF),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    value.isJogStarted
                        ? GestureDetector(
                          onTap: () {
                            QuickAlert.show(
                              context: context,
                              barrierDismissible: false,
                              type: QuickAlertType.warning,
                              title: "Stop recording",
                              text: "Are you sure you want to stop?",
                              onCancelBtnTap: () {
                                Navigator.of(context).pop();
                              },
                              onConfirmBtnTap: () {
                                value.stopStopwatch();
                                Navigator.of(context).pop();
                                addToFirestore(value.elapsedSeconds);
                              },
                              cancelBtnText: "No",
                              confirmBtnText: "Yes",
                              showCancelBtn: true,
                            );
                          },
                          child: Center(
                            child: CircularPercentIndicator(
                              radius: 120.0,
                              lineWidth: 12.0,
                              arcBackgroundColor: Colors.red[400],
                              arcType: ArcType.FULL,
                              percent: value.percent,
                              center: Text(
                                "${value.minutes.toString().padLeft(2, '0')}:${value.seconds.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: Colors.blue,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            minimumSize: Size(250, 250),
                            shadowColor: Colors.grey,
                          ),
                          onPressed: () async {
                            if (value.isJogStarted == false) {
                              isPermissionEnabled = await checkPermission();
                              if (isPermissionEnabled) {
                                value.startStopwatch();

                                getPositionStream =
                                    Geolocator.getPositionStream(
                                      locationSettings: LocationSettings(
                                        accuracy: LocationAccuracy.best,
                                        distanceFilter: 0,
                                      ),
                                    ).listen((pos) {
                                      path.add(
                                        LatLng(pos.latitude, pos.longitude),
                                      );
                                    });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Enable the permission in the settings.",
                                    ),
                                  ),
                                );
                              }
                            } else {
                              value.stopStopwatch();
                            }
                          },
                          child: Text(
                            "Start Run",
                            style: TextStyle(fontSize: 30, color: Colors.blue),
                          ),
                        ),

                    SizedBox(height: 20),
                    Text(
                      "Last Run",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    lastRun.isNotEmpty
                        ? Container(
                          margin: EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight,
                          ),
                          color: Colors.amber,
                          width: 200,
                          height: 200,
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              mapCtrl = controller;
                            },
                            markers:
                                extractedPath.isNotEmpty
                                    ? {
                                      Marker(
                                        markerId: MarkerId("Start"),
                                        position: extractedPath[0],
                                        infoWindow: InfoWindow(title: "Start"),
                                      ),
                                      Marker(
                                        markerId: MarkerId("End"),
                                        position:
                                            extractedPath[extractedPath.length -
                                                1],
                                        infoWindow: InfoWindow(title: "End"),
                                      ),
                                    }
                                    : {},
                            polylines: {
                              Polyline(
                                color: Colors.blue,
                                polylineId: PolylineId("lines"),
                                points:
                                    extractedPath.isNotEmpty
                                        ? extractedPath
                                        : [],
                              ),
                            },
                            initialCameraPosition: CameraPosition(
                              target:
                                  extractedPath.isNotEmpty
                                      ? extractedPath[0]
                                      : LatLng(15.9724207, 120.5215634),
                              zoom: 14,
                            ),
                          ),
                        )
                        : Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              "No data",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
        );
      },
    );
  }

  Widget Leaderboards() {
    return StreamBuilder(
      stream: leaderboardData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("No Data.", style: TextStyle(color: Colors.white)),
          );
        }

        List leaderboardList = snapshot.data!.docs;
        print(leaderboardList.toString() + leaderboardList.length.toString());
        String top1 =
            leaderboardList.length >= 1
                ? (leaderboardList[0].data() as Map)['username']
                : "None";
        String top2 =
            leaderboardList.length >= 2
                ? (leaderboardList[1].data() as Map)['username']
                : "None";

        String top3 =
            leaderboardList.length >= 3
                ? (leaderboardList[2].data() as Map)['username']
                : "None";

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 20),
              height: 200,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          top2,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFF4554D2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          height: 80,
                          width: MediaQuery.of(context).size.width / 3 - 50,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          top1,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFF4554D2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          height: 120,
                          width: MediaQuery.of(context).size.width / 3 - 50,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          top3,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFF4554D2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          height: 60,
                          width: MediaQuery.of(context).size.width / 3 - 50,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ListView.builder(
                  itemCount: leaderboardList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map record = leaderboardList[index].data() as Map;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 92, 104, 211),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                
                        title: Text(
                          "${record['username']}",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        trailing: Text(
                          "${double.parse(record['totalKM'].toString()).toStringAsFixed(2)} KM",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        return false;
      }
    }
    return true;
  }

  void addToFirestore(int seconds) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: "Please wait",
      barrierDismissible: false,
    );

    if (path.length < 2) {
      print("here is path length${path.length}");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: false,
        title: "Run too short",
        text: "Not enough data points to record your run.",
      );
      Provider.of<Timermodel>(context, listen: false).reset();
      return;
    }

    double totalKm = 0;

    for (int x = 0; x < path.length - 1; x++) {
      totalKm += Geolocator.distanceBetween(
        path[x].latitude,
        path[x].longitude,
        path[x + 1].latitude,
        path[x + 1].longitude,
      );
    }
    List<Map> pathMap =
        path.map((e) {
          return {'lat': e.latitude, 'lng': e.longitude};
        }).toList();

    totalKm = totalKm / 1000;

    try {
      //insert
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('runs')
          .add({
            'path': pathMap,
            'totalSeconds': seconds,
            'totalKm': totalKm,
            'title': null,
            'dateTime': Timestamp.now(),
          });

      //update the best kung mas malayo natakbo
      if (user['longestRun'] < totalKm) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update({'longestRun': totalKm, 'inSeconds': seconds});

        await FirebaseFirestore.instance
            .collection('leaderboards')
            .doc(widget.uid)
            .set({
              'totalKM': totalKm,
              'username': user['username'],
              'inSeconds': seconds,
            });
      }
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Data is recorded!",
        barrierDismissible: false,
      );
    } on FirebaseException catch (e) {
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.error,
        title: "Something went wrong",
        text: "${e.message}",
      );
    }
    mapCtrl?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: path[0], zoom: 14)),
    );
    path.clear();
    Provider.of<Timermodel>(context, listen: false).reset();
  }

  String calculatePace(double totalKm, int totalSeconds) {
    if (totalKm <= 0 || totalSeconds <= 0) return "0:00 / km";

    double paceSecondsPerKm = totalSeconds / totalKm;
    int paceMinutes = paceSecondsPerKm ~/ 60;
    int paceSeconds = (paceSecondsPerKm % 60).round();

    return '${paceMinutes.toString()}:${paceSeconds.toString().padLeft(2, '0')} / km';
  }

  Stream<QuerySnapshot> leaderboardData() {
    return FirebaseFirestore.instance
        .collection('leaderboards')
        .orderBy('totalKM', descending: true)
        .limit(10)
        .snapshots();
  }
}
