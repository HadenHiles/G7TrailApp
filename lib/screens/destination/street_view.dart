import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';

class DestinationPanoView extends StatefulWidget {
  DestinationPanoView({Key? key, required this.destination}) : super(key: key);

  final Destination destination;

  @override
  State<DestinationPanoView> createState() => _DestinationPanoViewState();
}

class _DestinationPanoViewState extends State<DestinationPanoView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            FlutterGoogleStreetView(
              /**
                 * It not necessary but you can set init position
                 * choice one of initPos or initPanoId
                 * do not feed param to both of them, or you should get assert error
                 */
              // initPos: LatLng(37.769263, -122.450727),
              initPanoId: widget.destination.panoId,

              /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initSource is a filter setting to filter panorama
                 */
              initSource: StreetViewSource.outdoor,

              /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initBearing can set default bearing of camera.
                 */
              initBearing: 0,

              /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initTilt can set default tilt of camera.
                 */
              initTilt: 0,

              /**
                 *  It is worked while you set initPos or initPanoId.
                 *  initZoom can set default zoom of camera.
                 */
              initZoom: 1,

              /**
                 *  iOS Only
                 *  It is worked while you set initPos or initPanoId.
                 *  initFov can set default fov of camera.
                 */
              //initFov: 120,

              /**
                 *  Set street view can panning gestures or not.
                 *  default setting is true
                 */
              //panningGesturesEnabled: false,

              /**
                 *  Set street view shows street name or not.
                 *  default setting is true
                 */
              //streetNamesEnabled: false,

              /**
                 *  Set street view can allow user move to other panorama or not.
                 *  default setting is true
                 */
              //userNavigationEnabled: false,

              /**
                 *  Set street view can zoom gestures or not.
                 *  default setting is true
                 */
              //zoomGesturesEnabled: false,

              /**
                 *  To control street view after street view was initialized.
                 *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                 *  And you can using [StreetViewController] object(controller) to control street view.
                 */
              onStreetViewCreated: (controller) async {
                controller.animateTo(duration: 50, camera: StreetViewPanoramaCamera(bearing: 0, tilt: 0, zoom: 1));
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  navigatorKey.currentState!.pop();
                },
                splashColor: Colors.black54,
                highlightColor: Colors.black54,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
