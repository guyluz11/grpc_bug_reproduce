import 'package:grpc_bug_reproduce_client/hub_client/hub_client.dart';

class GrpcBugReproduceClient {
  GrpcBugReproduceClient() {
    mimickingClientRequests();
  }

  int hubPort = 50055;

  Future<void> mimickingClientRequests() async {
    HubClient.createStreamWithHub('127.0.0.1', hubPort);
  }
}
