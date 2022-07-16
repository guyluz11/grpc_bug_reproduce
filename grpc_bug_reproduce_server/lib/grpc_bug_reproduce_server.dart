import 'package:grpc/grpc.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/app_communication/app_communication_repository.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/app_communication/hub_app_server.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';

class StartServer {
  StartServer() {
    startLocalServer();
    sendDataToClients();
  }

  /// Port to connect to the cbj hub, will change according to the current
  /// running environment
  int hubPort = 50055;

  Future startLocalServer() async {
    final server = Server([HubAppServer()]);
    await server.serve(port: hubPort);
    print('Hub Server listening for apps clients on port ${server.port}...');
  }

  static Future<void> getFromApp({
    required Stream<ClientStatusRequests> request,
    required String requestUrl,
    required bool isRemotePipes,
  }) async {
    request.listen((event) async {
      print('Got From App');
    }).onError((error) {
      if (error is GrpcError && error.code == 1) {
        print('Client have disconnected');
      } else if (error is GrpcError && error.code == 14) {
        final String errorMessage = error.message!;

        if (error.message == null || !isRemotePipes) {
          print('Client stream error without message\n$error');
        } else if (!errorMessage.contains('errorCode: 0')) {
          print('Closing last stream\n$error');
        }

        /// Request reached the internet but the didn't arrive to remote pipes
        /// service
        else if (!errorMessage.contains('errno = -2')) {
          print(
            'Remote Pipes service does not exist, check URL\n'
            '$error',
          );
        }

        /// Request didn't reached the internet
        else if (!errorMessage.contains('errno = -3')) {
          print(
            'Device does not have network\n'
            '$error',
          );
        } else {
          print(
            'Un none errno number\n'
            '$error',
          );
        }
      } else {
        if (error is GrpcError &&
            isRemotePipes &&
            error.message != null &&
            !error.message!.contains('errorCode: 0')) {
          print('Client stream got terminated to create new one\n$error');
        } else {
          print('Client stream error\n$error');
        }
      }
    });
  }

  Future<void> sendDataToClients() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      print('Send Test data');
      HubRequestsToApp.streamRequestsToApp.sink.add('Test data');
    }
  }
}
