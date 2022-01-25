import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
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

  static final LatLng _defaultPosition = LatLng(48.6856434610084, -86.40889064111326);
  static final CameraPosition _kTrail = CameraPosition(
    target: _defaultPosition,
    zoom: 12,
  );

  List<Destination> _destinations = [];
  Set<Marker> _markers = {};

  Future<void> _loadDestinations() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<Destination> destinations = [];
        for (var doc in snapshot.docs) {
          Destination d = Destination.fromSnapshot(doc);
          if (!d.entryPoint && d.images.isNotEmpty) {
            await loadFirestoreImage(d.images[0].image, 1).then((url) => d.imgURL = url);
            destinations.add(d);
          }
        }

        setState(() {
          _destinations = destinations;
        });
      }
    });
  }

  void _loadMarkers() {
    Set<Marker> markers = {};
    int i = 0;
    for (var d in _destinations) {
      if (d.latitude != 0 || d.longitude != 0) {
        LatLng latLng = LatLng(d.latitude, d.longitude);
        markers.add(
          Marker(
              markerId: MarkerId("beacon-" + (i++).toString()),
              position: latLng,
              // infoWindow: InfoWindow(title: address, snippet: "go here"),
              icon: BitmapDescriptor.defaultMarker),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((value, element) => value < element ? value : element); // smallest
    final southwestLon = positions.map((p) => p.longitude).reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce((value, element) => value > element ? value : element); // biggest
    final northeastLon = positions.map((p) => p.longitude).reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLon),
      northeast: LatLng(northeastLat, northeastLon),
    );
  }

  double getBoundsZoomLevel(LatLngBounds bounds, Size mapDimensions) {
    var worldDimension = Size(1024, 1024);

    double latRad(lat) {
      var sinValue = sin(lat * pi / 180);
      var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
      return max(min(radX2, pi), -pi) / 2;
    }

    double zoom(mapPx, worldPx, fraction) {
      return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
    }

    var ne = bounds.northeast;
    var sw = bounds.southwest;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    var latZoom = zoom(mapDimensions.height, worldDimension.height, latFraction);
    var lngZoom = zoom(mapDimensions.width, worldDimension.width, lngFraction);

    if (latZoom < 0) return lngZoom;
    if (lngZoom < 0) return latZoom;

    return min(latZoom, lngZoom);
  }

  LatLng getCentralLatlng(List<LatLng> geoCoordinates) {
    if (geoCoordinates.length == 1) {
      return geoCoordinates.first;
    }

    double x = 0;
    double y = 0;
    double z = 0;

    for (var geoCoordinate in geoCoordinates) {
      var latitude = geoCoordinate.latitude * pi / 180;
      var longitude = geoCoordinate.longitude * pi / 180;

      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }

    var total = geoCoordinates.length;

    x = x / total;
    y = y / total;
    z = z / total;

    var centralLongitude = atan2(y, x);
    var centralSquareRoot = sqrt(x * x + y * y);
    var centralLatitude = atan2(z, centralSquareRoot);

    return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
  }

  @override
  void initState() {
    _loadDestinations().then((value) {
      _loadMarkers();
    });

    super.initState();
  }
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
      child: _markers.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            )
          : GoogleMap(
              mapType: MapType.terrain,
              compassEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: _kTrail,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);

                await Future.delayed(Duration(milliseconds: 50)).then((value) {
                  var zoomLevel = getBoundsZoomLevel(
                        _createBounds(_markers.map((m) => m.position).toList()),
                        Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height / 5,
                        ),
                      ) +
                      1;

                  setState(() {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: getCentralLatlng(_destinations.map((d) => LatLng(d.latitude, d.longitude)).toList()),
                          zoom: zoomLevel,
                        ),
                      ),
                    );
                  });
                });
              },
              onTap: (latLng) {
                print("LatLng: ${latLng.toString()}");
              },
            ),
    );
  }
}
