import 'package:grpc/grpc.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/app_communication/hub_app_server.dart';

class StartServer {
  StartServer() {
    startLocalServer();
  }

  /// Port to connect to the cbj hub, will change according to the current
  /// running environment
  int hubPort = 50055;

  Future startLocalServer() async {
    final server = Server([HubAppServer()]);
    await server.serve(port: hubPort);
    print('Hub Server listening for apps clients on port ${server.port}...');
  }
}
