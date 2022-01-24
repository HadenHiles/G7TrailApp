import 'dart:async';
import 'package:flutter/material.dart';
import 'package:g7trailapp/theme/map_style.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _mapType == MapType.normal
              ? GoogleMap(
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
