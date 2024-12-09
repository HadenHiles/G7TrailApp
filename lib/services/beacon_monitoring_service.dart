import 'dart:developer';
import 'dart:io';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/services/notification_service.dart';

class BeaconMonitoringService {
  dynamic _streamMonitoring;
  Destination? nearbyBeacon;
  List<Beacon> nearbyBeacons = [];
  final regions = <Region>[];
  List<Destination> beacons = [];

  BeaconMonitoringService() {
    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(
        Region(
          identifier: "Group of Seven Lake Superior Trail",
          proximityUUID: "f7826da6-4fa2-4e98-8024-bc5b71e0893e",
        ),
      );
    } else {
      // Android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }

    monitor();
  }

  void monitor() {
    _streamMonitoring = flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      // result contains a region, event type and event state
      log("Beacon found: " + result.region.identifier + ":" + result.region.major.toString());
      Destination d = beacons.where((b) => int.parse(b.beaconId) == result.region.major).toList()[0];
      NotificationService().notify(result.region.major!, "Trail Beacon Found", "You discovered \"${d.destinationName}\"!");
    });
  }

  void stop() {
    // stop monitoring beacons
    _streamMonitoring.cancel();
  }
}
