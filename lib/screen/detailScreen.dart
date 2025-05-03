import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_run/screen/replayScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  DetailScreen({super.key, required this.uid, required this.runId});
  String uid;
  String runId;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<DocumentSnapshot> runData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('runs')
        .doc(widget.runId)
        .get();
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String calculatePace(double totalKm, int totalSeconds) {
    if (totalKm == 0) return "0:00";
    double paceSecondsPerKm = totalSeconds / totalKm;
    int paceMinutes = paceSecondsPerKm ~/ 60;
    int paceSeconds = (paceSecondsPerKm % 60).round();
    return '${paceMinutes.toString().padLeft(1, '0')}:${paceSeconds.toString().padLeft(2, '0')}';
  }

  List<LatLng> path = [];
  String title = "";
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: runData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        Map run = snapshot.data!.data() as Map;
        String pace = calculatePace(run['totalKm'], run['totalSeconds']);
        title =
            run['title'] == null || run['title'].toString().isEmpty
                ? DateFormat(
                  'MMMM d, y h:mm a',
                ).format(run['dateTime'].toDate())
                : run['title'];

        List firebasePath = run['path'];
        path = [];
        firebasePath.forEach((e) {
          path.add(LatLng(e['lat'], e['lng']));
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF4554D2),
            foregroundColor: Colors.white,
            title: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/GoRunLogo.png', width: 100),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              children: [
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${double.parse(run['totalKm'].toString()).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Kilometers",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.replay, size: 25, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE8B601),
                        minimumSize: Size(120, 40),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ReplayScreen(path: path, title: title),
                          ),
                        );
                      },
                      label: Text(
                        "Replay Path",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "$pace / km",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Avg. Pace",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${formatTime(run['totalSeconds'])}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Time",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 400,
                  width: 400,
                  child: GoogleMap(
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(path[0].latitude, path[0].longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("Start"),
                        position: LatLng(path[0].latitude, path[0].longitude),
                      ),
                      Marker(
                        markerId: MarkerId("End"),
                        position: LatLng(
                          path[path.length - 1].latitude,
                          path[path.length - 1].longitude,
                        ),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: PolylineId("Poly"),
                        points: path,
                        color: Colors.blue,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
