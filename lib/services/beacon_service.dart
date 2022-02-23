// ignore: unused_import
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/services/notification_service.dart';

class BeaconService extends ChangeNotifier {
  dynamic _streamMonitoring;
  dynamic _streamRanging;
  Destination? nearbyBeacon;
  List<Beacon> nearbyBeacons = [];

  BeaconService() {
    final regions = <Region>[];
    List<Destination> beacons = [];

    // Get the destination (beacons)
    FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('beaconInfo.beaconId', isNotEqualTo: "").where('beaconInfo.beaconId', isNotEqualTo: null).get().then((snapshot) {
      for (var b in snapshot.docs) {
        Destination beacon = Destination.fromSnapshot(b);
        beacons.add(beacon);

        regions.add(
          Region(
            identifier: beacon.beaconTitle,
            proximityUUID: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
            major: int.parse(beacon.beaconId),
          ),
        );
      }

      // to start ranging beacons
      _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
        // result contains a region and list of beacons found
        // list can be empty if no matching beacons were found in range
        if (result.beacons.isNotEmpty) {
          result.beacons.sort((a, b) => a.accuracy.compareTo(b.accuracy)); //TODO: this likely isn't necessary since we currently only ever have one beacon per region

          if (!nearbyBeacons.contains(result.beacons[0])) {
            nearbyBeacons.add(result.beacons[0]);
          } else {
            int i = nearbyBeacons.indexWhere((b) => b == result.beacons[0]);
            nearbyBeacons[i] = result.beacons[0];
          }
        }

        // log("Beacons in range: " + nearbyBeacons.toString());
        // Find the closest beacon and notify the beacon service listeners there's a new beacon
        nearbyBeacons.sort((a, b) => a.accuracy.compareTo(b.accuracy));
        if (nearbyBeacons.isNotEmpty) {
          nearbyBeacon = beacons.where((b) => int.parse(b.beaconId) == nearbyBeacons[0].major).toList()[0];
          notifyListeners();
        }
      });
    });
  }

  void monitor() {
    final regions = <Region>[];
    List<Destination> beacons = [];

    // Get the destination (beacons)
    FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('beaconInfo.beaconId', isNotEqualTo: "").where('beaconInfo.beaconId', isNotEqualTo: null).get().then((snapshot) {
      for (var b in snapshot.docs) {
        Destination beacon = Destination.fromSnapshot(b);
        beacons.add(beacon);

        regions.add(
          Region(
            identifier: beacon.beaconTitle,
            proximityUUID: 'f7826da6-4fa2-4e98-8024-bc5b71e0893e',
            major: int.parse(beacon.beaconId),
          ),
        );
      }

      _streamMonitoring = flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
        // result contains a region, event type and event state
        // log("Beacon found: " + result.region.identifier + ":" + result.region.major.toString());
        Destination d = beacons.where((b) => int.parse(b.beaconId) == result.region.major).toList()[0];
        NotificationService().notify(result.region.major!, "Trail Beacon Found", "You discovered \"${d.destinationName}\"!");
      });
    });
  }

  stop() {
    // to stop monitoring beacons
    _streamMonitoring.cancel();
    _streamRanging.cancel();
  }

  @override
  void dispose() {
    stop();
    _streamMonitoring = null;
    _streamRanging = null;
    super.dispose();
  }
}
