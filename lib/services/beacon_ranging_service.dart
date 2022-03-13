// ignore: unused_import
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:g7trailapp/models/firestore/destination.dart';

class BeaconRangingService extends ChangeNotifier {
  dynamic _streamRanging;
  Destination? nearbyBeacon;
  List<Beacon> nearbyBeacons = [];
  final regions = <Region>[];
  List<Destination> beacons = [];

  BeaconRangingService() {
    loadBeacons().then((value) {
      startRanging();
      Duration notifyDelayTime = Duration(seconds: 1);
      Timer.periodic(notifyDelayTime, (_) async {
        notifyListeners();
      });
    });
  }

  Future<void> loadBeacons() async {
    // Get the destination (beacons)
    await FirebaseFirestore.instance.collection('fl_content').where('_fl_meta_.schema', isEqualTo: "destination").where('beaconInfo.beaconId', isNotEqualTo: "").where('beaconInfo.beaconId', isNotEqualTo: null).get().then((snapshot) {
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
    });
  }

  void startRanging() {
    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
      // result contains a region and list of beacons found
      // list can be empty if no matching beacons were found in range
      if (result.beacons.isNotEmpty) {
        if (!nearbyBeacons.contains(result.beacons[0])) {
          nearbyBeacons.add(result.beacons[0]);
        } else {
          int i = nearbyBeacons.indexWhere((b) => b.major == result.beacons[0].major);
          nearbyBeacons[i] = result.beacons[0];
        }
      }

      // log("Beacons in range: " + nearbyBeacons.toString());

      // Find the closest beacon and notify the beacon service listeners there's a new beacon
      nearbyBeacons.sort((a, b) => a.accuracy.compareTo(b.accuracy));
      if (nearbyBeacons.isNotEmpty) {
        nearbyBeacon = beacons.where((b) => int.parse(b.beaconId) == nearbyBeacons[0].major).toList()[0];
      }
    });
  }

  void stop() {
    // to stop ranging beacons
    _streamRanging.cancel();
  }

  @override
  void dispose() {
    stop();
    _streamRanging = null;
    super.dispose();
  }
}
