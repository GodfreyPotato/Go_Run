import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_run/model/timerModel.dart';
import 'package:go_run/screen/detailScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.uid});
  String uid;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<DocumentSnapshot> userData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
  }

  Future<QuerySnapshot> history() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('runs')
        .orderBy('dateTime')
        .get();
  }

  bool isPermissionEnabled = true;

  late List<Widget> pages;
  int _selectedIndex = 0;

  Map user = {};

  //map records
  List<LatLng> path = [];

  StreamSubscription<Position>? getPositionStream;

  var nameCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
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
          child: FutureBuilder(
            future: history(),
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
                  DrawerHeader(child: Center(child: Text("Recent Records"))),
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
                                        backgroundColor: Color(0xFF86B6FF),
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
        body: pages[_selectedIndex],
      ),
    );
  }

  Widget HomeWidget() {
    return FutureBuilder(
      future: userData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("No info.", style: TextStyle(color: Colors.white)),
          );
        }

        user = snapshot.data!.data() as Map;

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
                                user['fastestRun'] == 0
                                    ? "--:--"
                                    : "${double.parse(user['fastestRun'].toString()).toStringAsFixed(2)} KM/H",
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
                                addToFirestore(value.elapsedSeconds);
                                Navigator.of(context).pop();
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
                    Container(
                      margin: EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight,
                      ),
                      color: Colors.amber,
                      width: 200,
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(0, 0),
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
    return FutureBuilder(
      future: userData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text("No info.", style: TextStyle(color: Colors.white)),
          );
        }

        Map user = snapshot.data!.data() as Map;

        return Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(color: Color(0xFF4554D2)),
          child: ListView(
            children: [
              Text("${user['runs']}"),
              Text("Personal Record"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: CircleBorder()),
                onPressed: () async {},
                child: Text("Start Run"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> checkPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.always ||
          permission != LocationPermission.whileInUse) {
        return false;
      }
    }
    return true;
  }

  void addToFirestore(int seconds) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      barrierDismissible: false,
    );
    if (path.length < 2) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        barrierDismissible: false,
        title: "Run too short",
        text: "Not enough data points to record your run.",
      );
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

      if (user['longestRun'] < totalKm) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update({'longestRun': totalKm});
      }
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Success",
        text: "Data is recorded!",
        barrierDismissible: false,
      );
      setState(() {});
    } on FirebaseException catch (e) {
      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.error,
        title: "Something went wrong",
        text: "${e.message}",
      );
    }
    Provider.of<Timermodel>(context, listen: false).reset();
  }
}
