import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_bug_reproduce_client_flutter/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';
import 'package:grpc_bug_reproduce_client_flutter/hub_client/hub_client.dart';

class GrpcBugReproduceClient {
  GrpcBugReproduceClient() {
    navigateRequest();
  }

  static int hubPort = 20061;

  static int connectionToHubDelaySeconds = 0;

  static StreamSubscription<RequestsAndStatusFromHub>?
      requestsFromHubSubscription;

  static Stream<ConnectivityResult>? connectivityChangedStream;

  static bool areWeRunning = false;

  // static int numberOfCrashes = 0;
  static int numberOfConnactivityChange = 0;

  static Future<void> mimickingClientRequests() async {
    // TODO: Change to computer IP
    HubClient.createStreamWithHub('192.168.31.66', hubPort);
    HubRequestsToApp.hubRequestsStreamBroadcast.stream.listen((event) {
      print('Got from hub');
    });
  }

  static Future<void> navigateRequest() async {
    AppRequestsToHub.lisenToApp();
    HubRequestsToApp.lisenToApp();
    if (areWeRunning) {
      return;
    }

    await Future.delayed(Duration(seconds: connectionToHubDelaySeconds));

    if (areWeRunning) {
      return;
    }
    areWeRunning = true;

    // await requestsFromHubSubscription?.cancel();
    // requestsFromHubSubscription = null;
    connectivityChangedStream = null;

    requestsFromHubSubscription = HubRequestsToApp
        .hubRequestsStreamBroadcast.stream
        .listen((RequestsAndStatusFromHub requestsAndStatusFromHub) {
      connectionToHubDelaySeconds = 3;

      print('Got from Hub ');
    });
    requestsFromHubSubscription?.onError((error) async {
      connectionToHubDelaySeconds += 5;
      if (error is GrpcError && error.code == 1) {
        print('Hub have disconnected');
      } else {
        print('Hub stream error: $error');
        if (error.toString().contains('errorCode: 10')) {
          areWeRunning = false;

          navigateRequest();
        }
      }
    });

    connectivityChangedStream = Connectivity().onConnectivityChanged;
    connectivityChangedStream?.listen((ConnectivityResult event) async {
      numberOfConnactivityChange++;
      print(
        'Connectivity changed ${event.name} And $event',
      );
      if (event == ConnectivityResult.none || numberOfConnactivityChange <= 1) {
        return;
      }
      areWeRunning = false;
      navigateRequest();
    });
    mimickingClientRequests();
  }
}
