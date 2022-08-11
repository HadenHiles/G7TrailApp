import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/models/firestore/landmark.dart';
import 'package:g7trailapp/models/firestore/legend.dart';
import 'package:g7trailapp/models/firestore/path.dart';
import 'package:g7trailapp/screens/destination.dart';
import 'package:g7trailapp/utility/firebase_storage.dart';
import 'package:g7trailapp/theme/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
    zoom: 10,
  );

  List<Destination> _destinations = [];
  Legend? _legend;
  Set<Marker> _markers = {};
  List<Landmark> _landmarks = [];
  Marker? highlightedMarker;
  MapType _mapType = MapType.normal;
  Set<Polyline> _polylines = {};
  String? _selectedPathTitle;

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

  Future<void> _loadMarkers() async {
    Set<Marker> markers = {};
    int i = 0;
    int? highlightedMarkerIdx;
    for (var d in _destinations) {
      if (d.id == widget.highlightedDestination?.id) {
        highlightedMarkerIdx = i;
      }
      if (d.latitude != 0 || d.longitude != 0) {
        LatLng latLng = LatLng(d.latitude, d.longitude);
        markers.add(
          Marker(
              markerId: MarkerId("beacon-" + (i++).toString()),
              position: latLng,
              infoWindow: InfoWindow(title: d.destinationName),
              icon: await BitmapDescriptor.fromAssetImage(
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

      if (highlightedMarkerIdx != null) {
        highlightedMarker = _markers.elementAt(highlightedMarkerIdx);
      }
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
            onTap: () {
              setState(() {
                _selectedPathTitle = p.title;
              });
              print(p.title);
            },
            consumeTapEvents: true,
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

  Future<void> _loadLandmarks() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "landmarks").get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Landmark l = Landmark.fromSnapshot(doc);
          setState(() {
            _landmarks.add(l);
          });
        }

        Set<Marker> landmarkers = {};
        int i = 0;
        for (var l in _landmarks) {
          await loadFirestoreImage(l.icon, 1).then((url) => l.iconURL = url).then((_) async {
            List<LatLng> lPoints = l.points.map<LatLng>((m) {
              return LatLng(m.latitude, m.longitude);
            }).toList();

            for (var p in lPoints) {
              if (p.latitude != 0 || p.longitude != 0) {
                // Get the raw image data for the landmark icon
                var iconRequest = await http.get(Uri.parse(l.iconURL!));
                var iconBytes = await iconRequest.bodyBytes;

                LatLng latLng = LatLng(p.latitude, p.longitude);
                landmarkers.add(
                  Marker(
                    markerId: MarkerId("landmark-" + (i++).toString()),
                    position: latLng,
                    infoWindow: InfoWindow(title: l.title),
                    icon: l.iconURL!.isEmpty ? BitmapDescriptor.defaultMarker : await BitmapDescriptor.fromBytes(iconBytes),
                  ),
                );
              }
            }

            setState(() {
              _markers.addAll(landmarkers);
            });
          });
        }
      }
    });
  }

  Future<void> _loadLegend() async {
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "mapLegend").limit(1).get().then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        Legend legend = Legend.fromSnapshot(snapshot.docs[0]);
        if (legend.items.isNotEmpty) {
          for (var i in legend.items) {
            await loadFirestoreImage(i.image, 1).then((url) => i.imageURL = url);
          }
        }

        setState(() {
          _legend = legend;
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
        _loadMarkers().then((_) {
          _loadLandmarks();
        });
      });
    });

    _loadLegend();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          _markers.length <= 0
              ? Stack(
                  children: [
                    SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image(image: AssetImage('assets/images/temp-map.jpg')),
                      ),
                    ),
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
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            right: 5,
            child: TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Legend"),
                    content: Container(
                      width: 180,
                      height: 300,
                      child: ListView.builder(
                        itemCount: _legend!.items.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            leading: (_legend!.items[i].imageURL != "" && _legend!.items[i].imageURL != null)
                                ? Image(
                                    image: NetworkImage(_legend!.items[i].imageURL!),
                                    width: 40,
                                  )
                                : Container(
                                    color: _legend!.items[i].color,
                                    margin: EdgeInsets.only(top: 10),
                                    height: 4,
                                    width: 20,
                                  ),
                            title: Text(
                              _legend!.items[i].title,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                        },
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, 'Close');
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
              ),
              child: Icon(
                Icons.info_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          _selectedPathTitle == null
              ? Container()
              : Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 25,
                  left: 100,
                  right: 100,
                  child: Container(
                    height: 50,
                    child: Card(
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: AutoSizeText(
                          _selectedPathTitle!,
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
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
      onTap: (latLng) {
        setState(() {
          _selectedPathTitle = null;
        });
      },
      onCameraMoveStarted: () {
        setState(() {
          _selectedPathTitle = null;
        });
      },
      onMapCreated: (GoogleMapController controller) async {
        _controller.complete(controller);

        controller.setMapStyle(mapStyle);

        double zoomLevel = 12;
        Duration delayZoom = Duration(milliseconds: 50);
        Set<Marker> markers = {};
        if (highlightedMarker != null) {
          markers.add(highlightedMarker!);
          zoomLevel = 14;
        } else {
          markers = _markers;
          zoomLevel = getBoundsZoomLevel(
                _createBounds(markers.map((m) => m.position).toList()),
                Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ) +
              0.75;
        }

        await Future.delayed(delayZoom).then((value) {
          setState(() {
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: getCentralLatlng(markers.map((m) => LatLng(m.position.latitude, m.position.longitude)).toList()),
                  zoom: zoomLevel,
                ),
              ),
            );
          });
        });
      },
    );
  }
}
