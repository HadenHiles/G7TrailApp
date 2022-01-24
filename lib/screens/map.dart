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
  final Set<Polyline> _polylines = {
    Polyline(
      polylineId: PolylineId("1"),
      visible: true,
      points: const [
        LatLng(47.5746728, -84.8542786),
        LatLng(47.6764844, -84.927063),
        LatLng(47.7614837, -84.8597717),
        LatLng(47.8094654, -84.8789978),
        LatLng(47.8620099, -84.8226929),
        LatLng(47.9080578, -84.7869873),
        LatLng(47.9503856, -84.8048401),
        LatLng(47.9623416, -84.8982239),
        LatLng(47.9761335, -84.9586487),
        LatLng(47.9577435, -85.0204468),
        LatLng(47.9761335, -85.1797485),
        LatLng(47.953145, -85.328064),
        LatLng(47.924625, -85.4434204),
        LatLng(47.9549844, -85.5326843),
        LatLng(47.9457865, -85.5519104),
        LatLng(47.9365869, -85.5917358),
        LatLng(47.9237047, -85.6466675),
        LatLng(47.9402669, -85.7661438),
        LatLng(48.0202427, -85.9130859),
        LatLng(48.0698206, -85.9762573),
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
