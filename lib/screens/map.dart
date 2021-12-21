import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g7trailapp/widgets/screen_title.dart';
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

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            collapsedHeight: 65,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: Theme.of(context).iconTheme,
            actionsIconTheme: Theme.of(context).iconTheme,
            floating: true,
            pinned: false,
            flexibleSpace: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                titlePadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                centerTitle: false,
                title: ScreenTitle(icon: Icons.map_rounded, title: "Trail Map"),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
        ];
      },
      body: GoogleMap(
        mapType: MapType.terrain,
        compassEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: _kTrail,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
