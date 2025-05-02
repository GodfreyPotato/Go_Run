import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<LatLng> points = [
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.95131, 120.1725117),
    LatLng(15.9518835, 120.1763602),
    LatLng(15.9525442, 120.1775692),
    LatLng(15.9509871, 120.1822042),
    LatLng(15.9499072, 120.1870911),
    LatLng(15.9480083, 120.1912233),
    LatLng(15.9480083, 120.1912233),
    LatLng(15.9480083, 120.1912233),
    LatLng(15.9480083, 120.1912233),
    LatLng(15.9480083, 120.1912233),
    LatLng(15.9480083, 120.1912233),
  ];
  GoogleMapController? mapController;

  Future<bool> onLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
      return false;
    }
    startRecord();
    return true;
  }

  void startRecord() async {
    Geolocator.getPositionStream().listen((data) {
      mapController?.animateCamera(
        duration: Duration(milliseconds: 800),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(data.latitude, data.longitude),
            zoom: 12,
          ),
        ),
      );
      points.add(LatLng(data.latitude, data.longitude));

      setState(() {});
    });
  }

  void viewRoute() async {
    for (LatLng e in points) {
      await mapController?.animateCamera(
        duration: Duration(seconds: 1),
        CameraUpdate.newCameraPosition(
          CameraPosition(target: e, zoom: 20, tilt: 30),
        ),
      );
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // onLocation();
    viewRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(target: LatLng(15, 120)),
        polylines: {Polyline(polylineId: PolylineId("Route"), points: points)},
        // myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
    );
  }
}
