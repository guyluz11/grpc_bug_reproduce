import 'dart:async';

import 'package:async/async.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_bug_reproduce_client/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';

class HubClient {
  static ClientChannel? channel;
  static CbjHubClient? stub;

  ///  Creates a stream with the Hub
  static Future createStreamWithHub(
    String addressToHub,
    int hubPort,
  ) async {
    await channel?.terminate();

    channel = await _createCbjHubClient(addressToHub, hubPort);
    stub = CbjHubClient(channel!);
    ResponseStream<RequestsAndStatusFromHub> response;

    try {
      response = stub!.clientTransferDevices(
        AppRequestsToHub.appRequestsToHubStreamBroadcast.stream,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      AppRequestsToHub.appRequestsToHubStreamController
          .add(ClientStatusRequests(sendingType: SendingType.firstConnection));

      HubRequestsToApp.hubRequestsStreamBroadcast.add(response);
    } catch (e) {
      print('Caught error while stream with hub\n$e');
      await channel?.shutdown();
    }
  }

  ///  Get Hub computer and software info
  static Future<CompHubInfo?> getHubCompInfo(
    String addressToHub,
    int hubPort,
    CompHubInfo compHubInfo,
  ) async {
    // channel = await _createCbjHubClient(addressToHub, hubPort);
    // stub = CbjHubClient(channel!);

    try {
      return await stub!.getCompHubInfo(compHubInfo);
    } catch (e) {
      print('Caught error while trying to get Hub comp info\n$e');
      await channel?.shutdown();
    }
    return null;
  }

  static Future<ClientChannel> _createCbjHubClient(
    String deviceIp,
    int hubPort,
  ) async {
    await channel?.shutdown();
    return ClientChannel(
      deviceIp,
      port: hubPort,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }
}

/// Requests and updates from hub to the app
class HubRequestsToApp {
  /// Stream of the requests from the hub
  /// Broadcast can be lisent multiple times
  static StreamGroup<RequestsAndStatusFromHub> hubRequestsStreamBroadcast =
      StreamGroup.broadcast();

  static bool boolListenWorking = false;

  /// Controller can be inserted multiple time
  static final hubRequestsStreamController =
      StreamController<RequestsAndStatusFromHub>();

  static lisenToApp() async {
    if (boolListenWorking) {
      return;
    }

    hubRequestsStreamBroadcast.add(hubRequestsStreamController.stream);
    boolListenWorking = true;

    ///TODO: delete if it was only for test
    hubRequestsStreamBroadcast.stream.listen((event) {
      print('Listen To Hub requests to App\n$event');
    });

    ///TODO: delete if it was only for test
    hubRequestsStreamBroadcast.stream.listen((event) {
      print('Listen To Hub requests to App2\n$event');
    });
  }
}

/// App requests for the hub to execute
class AppRequestsToHub {
  /// Stream controller of the app request for the hub

  static StreamGroup<ClientStatusRequests> appRequestsToHubStreamBroadcast =
      StreamGroup.broadcast();

  static bool boolListenWorking = false;

  static final appRequestsToHubStreamController =
      StreamController<ClientStatusRequests>();

  static lisenToApp() async {
    if (boolListenWorking) {
      return;
    }

    appRequestsToHubStreamBroadcast
        .add(appRequestsToHubStreamController.stream);
    boolListenWorking = true;

    ///TODO: delete if it was only for test
    appRequestsToHubStreamBroadcast.stream.listen((event) {
      print('Listen To App requests to Hub\n$event');
    });

    ///TODO: delete if it was only for test
    appRequestsToHubStreamBroadcast.stream.listen((event) {
      print('Listen To App requests to Hub2\n$event');
    });
  }
}
