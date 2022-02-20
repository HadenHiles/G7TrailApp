import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:g7trailapp/models/firestore/destination.dart';

class BeaconService extends ChangeNotifier {
  dynamic _streamMonitoring;
  Destination? nearbyBeacon;

  BeaconService() {
    final regions = <Region>[];
    List<Destination> beacons = [];

    // Get the destination (beacons)
    FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('beaconInfo.beaconId', isNotEqualTo: "").where('beaconInfo.beaconId', isNotEqualTo: null).get().then((snapshot) {
      for (var b in snapshot.docs) {
        Destination beacon = Destination.fromSnapshot(b);
        beacons.add(beacon);

        if (Platform.isIOS) {
          // iOS platform, at least set identifier and proximityUUID for region scanning
          regions.add(
            Region(
              identifier: beacon.beaconTitle,
              proximityUUID: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
              major: int.parse(beacon.beaconId),
            ),
          );
        } else {
          // android platform, it can ranging out of beacon that filter all of Proximity UUID
          regions.add(
            Region(
              identifier: beacon.beaconTitle,
              proximityUUID: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
              major: int.parse(beacon.beaconId),
            ),
          );
        }
      }

      // to start ranging beacons
      dynamic _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
        // result contains a region and list of beacons found
        // list can be empty if no matching beacons were found in range
        log("Beacons found: \n" + result.beacons.toString());
      });

      // to start monitoring beacons
      // _streamMonitoring = flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      //   // result contains a region, event type and event state
      //   log("Beacon found: " + result.region.identifier + ":" + result.region.major.toString());
      //   nearbyBeacon = beacons.where((b) => int.parse(b.beaconId) == result.region.major).toList()[0];
      //   notifyListeners();
      // });
    });
  }

  stop() {
    // to stop monitoring beacons
    _streamMonitoring.cancel();
  }

  @override
  void dispose() {
    stop();
    _streamMonitoring = null;
    super.dispose();
  }
}
