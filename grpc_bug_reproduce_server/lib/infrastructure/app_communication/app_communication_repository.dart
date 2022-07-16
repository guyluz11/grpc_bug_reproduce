import 'dart:async';

import 'package:grpc_bug_reproduce_server_1/infrastructure/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';
import 'package:rxdart/rxdart.dart';

/// Connect all streams from the internet devices into one stream that will be
/// send to mqtt broker to update devices states
class HubRequestsToApp {
  static BehaviorSubject<dynamic> streamRequestsToApp =
      BehaviorSubject<dynamic>();
}

/// Requests and updates from app to the hub
class AppRequestsToHub {
  /// Stream controller of the requests from the hub
  static final hubRequestsStreamController =
      StreamController<RequestsAndStatusFromHub>();

  /// Stream of the requests from the hub
  static Stream<RequestsAndStatusFromHub> get hubRequestsStream =>
      hubRequestsStreamController.stream;
}
