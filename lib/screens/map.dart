import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/path.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/theme/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, this.highlightedDestination}) : super(key: key);

  final Destination? highlightedDestination;

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
  MapType _mapType = MapType.normal;
  Set<Polyline> _polylines = {};

  Future<void> _loadDestinations() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<Destination> destinations = [];
        for (var doc in snapshot.docs) {
          Destination d = Destination.fromSnapshot(doc);
          if (d.images.isNotEmpty) {
            await loadFirestoreImage(d.images[0].image, 1).then((url) => d.imgURL = url);
          }

          destinations.add(d);
        }

        setState(() {
          _destinations = destinations;
        });
      }
    });
  }

  void _loadMarkers() async {
    Set<Marker> markers = {};
    int i = 0;
    for (var d in _destinations) {
      if (d.latitude != 0 || d.longitude != 0) {
        LatLng latLng = LatLng(d.latitude, d.longitude);
        markers.add(
          Marker(
              markerId: MarkerId("beacon-" + (i++).toString()),
              position: latLng,
              infoWindow: InfoWindow(title: d.destinationName),
              icon: d == widget.highlightedDestination
                  ? BitmapDescriptor.defaultMarker
                  : await BitmapDescriptor.fromAssetImage(
                      ImageConfiguration(devicePixelRatio: 1.75),
                      d.entryPoint ? "assets/images/map-pin.png" : "assets/images/map-marker.png",
                    ),
              onTap: () {
                if (!d.entryPoint) {
                  navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) {
                    return DestinationScreen(destination: d);
                  }));
                }
              }),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _loadPolyines() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "path").get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        Set<Polyline> polylines = {};
        for (var doc in snapshot.docs) {
          Path p = Path.fromSnapshot(doc);
          Polyline polyline = Polyline(
            polylineId: PolylineId(p.title + "-" + doc.id),
            visible: true,
            points: p.points.map<LatLng>((m) {
              return LatLng(m.latitude, m.longitude);
            }).toList(),
            color: p.hexColor,
            jointType: JointType.bevel,
            width: 4,
          );

          polylines.add(polyline);
        }

        setState(() {
          _polylines = polylines;
        });
      }
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
    var worldDimension = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

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
    _loadDestinations().then((_) {
      _loadPolyines().then((_) {
        _loadMarkers();
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          _markers.isEmpty
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
              : _mapType == MapType.terrain
                  ? googleMap(MapType.terrain)
                  : googleMap(MapType.normal),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
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

  GoogleMap googleMap(MapType mapType) {
    return GoogleMap(
      mapType: mapType,
      compassEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      initialCameraPosition: _kTrail,
      polylines: _polylines,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) async {
        _controller.complete(controller);

        controller.setMapStyle(mapStyle);

        await Future.delayed(Duration(milliseconds: 50)).then((value) {
          var zoomLevel = getBoundsZoomLevel(
                _createBounds(_markers.map((m) => m.position).toList()),
                Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ) +
              0.75;

          setState(() {
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: getCentralLatlng(_markers.map((m) => LatLng(m.position.latitude, m.position.longitude)).toList()),
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
    );
  }
}
