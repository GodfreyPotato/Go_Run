import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReplayScreen extends StatefulWidget {
  ReplayScreen({super.key, required this.path, required this.title});
  List<LatLng> path;
  String title;
  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  GoogleMapController? mapController;
  bool done = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewRoute();
  }

  void viewRoute() async {
    for (LatLng e in widget.path) {
      await mapController?.animateCamera(
        duration: Duration(milliseconds: 300),
        CameraUpdate.newCameraPosition(
          CameraPosition(target: e, zoom: 20, tilt: 70),
        ),
      );
      await Future.delayed(Duration(milliseconds: 800));
    }
    done = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          done
              ? AppBar(
                backgroundColor: Color(0xFF4554D2),
                foregroundColor: Colors.white,
                title: Text(
                  widget.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/GoRunLogo.png',
                      width: 100,
                    ),
                  ),
                ],
              )
              : null,
      body: GoogleMap(
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.hybrid,
        markers: {
          Marker(
            markerId: MarkerId("start"),
            position: widget.path[0],
            infoWindow: InfoWindow(title: "Start"),
          ),
          Marker(
            markerId: MarkerId("end"),
            position: widget.path[widget.path.length - 1],
            infoWindow: InfoWindow(title: "End"),
          ),
        },
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.path[0].latitude, widget.path[0].longitude),
          zoom: 17,
          tilt: 70,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId("Poly"),
            points: widget.path,
            color: Colors.blue,
          ),
        },
      ),
    );
  }
}
