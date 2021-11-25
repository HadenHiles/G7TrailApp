// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:ci_connectivity/ci_connectivity.dart';

enum NetworkStatus { Online, Offline }

class NetworkStatusService {
  final ciConnectivity = CiConnectivity();

  StreamController<NetworkStatus> networkStatusController = StreamController<NetworkStatus>();

  NetworkStatusService() {
    // actively listen for status updates
    ciConnectivity.loopVerifyStatus();
    ciConnectivity.onListenerStatusNetwork.listen((event) {
      switch (event) {
        case true:
          networkStatusController.add(NetworkStatus.Online);
          break;
        case false:
          networkStatusController.add(NetworkStatus.Offline);
          break;
      }
    });
  }
}
