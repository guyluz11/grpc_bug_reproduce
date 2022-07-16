import 'package:grpc_bug_reproduce_client_flutter/hub_client/hub_client.dart';

class GrpcBugReproduceClient {
  GrpcBugReproduceClient() {
    mimickingClientRequests();
  }

  int hubPort = 20061;

  Future<void> mimickingClientRequests() async {
    HubClient.createStreamWithHub('127.0.0.1', hubPort);
    HubRequestsToApp.hubRequestsStreamBroadcast.stream.listen((event) {
      print('Got from hub');
    });
  }
}
