import 'dart:async';
import 'package:flutter/material.dart';
import 'package:g7trailapp/theme/map_style.dart';
import 'package:g7trailapp/theme/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kTrail = CameraPosition(
    target: LatLng(48.6856434610084, -86.40889064111326),
    zoom: 12,
  );

  MapType _mapType = MapType.normal;
  //TODO: Replace with actual trail points - make editable in flamelink
  final Set<Polyline> _polylines = {
    Polyline(
      polylineId: PolylineId("1"),
      visible: true,
      points: const [
        LatLng(48.6002251, -86.2605286),
        LatLng(48.6202008, -86.2536621),
        LatLng(48.6406224, -86.2474823),
        LatLng(48.6492424, -86.2591553),
        LatLng(48.6542323, -86.3113403),
        LatLng(48.6633034, -86.3511658),
        LatLng(48.6696523, -86.3566589),
        LatLng(48.6823476, -86.3594055),
        LatLng(48.6927734, -86.3717651),
        LatLng(48.702744, -86.375885),
        LatLng(48.7086348, -86.3861847),
        LatLng(48.7140718, -86.3923645),
        LatLng(48.7199612, -86.3889313),
        LatLng(48.7281147, -86.3861847),
        LatLng(48.7389839, -86.387558),
        LatLng(48.7498508, -86.3951111),
        LatLng(48.7539253, -86.4026642),
        LatLng(48.7530199, -86.4081573),
        LatLng(48.7466816, -86.4081573),
        LatLng(48.7521145, -86.4157104),
        LatLng(48.7498508, -86.4225769),
        LatLng(48.7620733, -86.4177704),
        LatLng(48.7670519, -86.4246368),
        LatLng(48.7724826, -86.4239502),
        LatLng(48.7774603, -86.4253235),
        LatLng(48.7770078, -86.4369965),
        LatLng(48.7738402, -86.439743),
        LatLng(48.7693148, -86.4390564),
        LatLng(48.771125, -86.4479828),
        LatLng(48.7679571, -86.4575958),
        LatLng(48.7697674, -86.4685822),
        LatLng(48.7761028, -86.4768219),
        LatLng(48.7815325, -86.4781952),
        LatLng(48.7860568, -86.4836884),
        LatLng(48.7801751, -86.4898682),
        LatLng(48.7729352, -86.4933014),
        LatLng(48.7652416, -86.5001678),
        LatLng(48.7598101, -86.5125275),
        LatLng(48.7598101, -86.5235138),
        LatLng(48.7598101, -86.5317535),
        LatLng(48.7530199, -86.526947),
        LatLng(48.7534726, -86.5207672),
      ],
      color: HomeTheme.lightTheme.primaryColor,
      jointType: JointType.bevel,
      width: 4,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _mapType == MapType.normal
              ? GoogleMap(
                  polylines: _polylines,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  myLocationEnabled: true,
                  initialCameraPosition: _kTrail,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);

                    controller.setMapStyle(mapStyle);
                  },
                )
              : GoogleMap(
                  polylines: _polylines,
                  mapType: MapType.terrain,
                  compassEnabled: true,
                  myLocationEnabled: true,
                  initialCameraPosition: _kTrail,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
          Positioned(
            bottom: 0,
            left: 5,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _mapType = _mapType == MapType.terrain ? MapType.normal : MapType.terrain;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
              ),
              child: Icon(
                _mapType == MapType.normal ? Icons.terrain : Icons.map_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
