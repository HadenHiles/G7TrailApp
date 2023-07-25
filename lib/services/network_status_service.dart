// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:ac_inet_connectivity_checker/ac_inet_connectivity_checker.dart';

enum NetworkStatus { Online, Offline }

class NetworkStatusService {
  StreamController<NetworkStatus> networkStatusController = StreamController<NetworkStatus>();

  NetworkStatusService() {
    // actively listen for status updates
    final checker = InetConnectivityChecker(
      endpoint: InetEndpoint(host: 'google.com', port: 443),
      // optional timeout. if unspecified the operating system
      // default connect timeout will be used instead (~120s).
      timeout: const Duration(seconds: 10),
    );

    checker.cancelableOperation.value.then((connected) {
      switch (connected) {
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
