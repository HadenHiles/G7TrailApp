import 'dart:developer';
import 'package:beacon_scanner/beacon_scanner.dart';
import 'package:g7trailapp/main.dart';
import 'package:g7trailapp/models/firestore/destination.dart';
import 'package:g7trailapp/services/notification_service.dart';

class BeaconMonitoringService {
  dynamic _streamMonitoring;
  Destination? nearbyBeacon;
  List<Beacon> nearbyBeacons = [];
  final regions = <Region>[];
  List<Destination> beacons = [];

  BeaconMonitoringService() {
    regions.add(
      Region(
        identifier: "Group of Seven Lake Superior Trail",
        beaconId: IBeaconId(
          proximityUUID: "f7826da6-4fa2-4e98-8024-bc5b71e0893e",
        ),
      ),
    );

    monitor();
  }

  void monitor() {
    _streamMonitoring = beaconScanner.monitoring(regions).listen((MonitoringResult result) {
      // result contains a region, event type and event state
      log("Beacon found: " + result.region.identifier + ":" + result.region.beaconId!.majorId.toString());
      Destination d = beacons.where((b) => int.parse(b.beaconId) == result.region.beaconId!.majorId).toList()[0];
      NotificationService().notify(result.region.beaconId!.majorId, "Trail Beacon Found", "You discovered \"${d.destinationName}\"!");
    });
  }

  void stop() {
    // stop monitoring beacons
    _streamMonitoring.cancel();
  }
}
