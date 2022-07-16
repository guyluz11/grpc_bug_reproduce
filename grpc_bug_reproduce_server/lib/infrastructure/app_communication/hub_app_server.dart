import 'dart:io';

import 'package:grpc/service_api.dart';
import 'package:grpc_bug_reproduce_server_1/grpc_bug_reproduce_server.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/app_communication/app_communication_repository.dart';
import 'package:grpc_bug_reproduce_server_1/infrastructure/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';

/// Server to get and send information to the app
class HubAppServer extends CbjHubServiceBase {
  /// The app call this method and getting stream of all the changes of the
  /// internet devices
  Stream<MapEntry<String, String>> streamOfChanges() async* {}

  @override
  Stream<RequestsAndStatusFromHub> clientTransferDevices(
    ServiceCall call,
    Stream<ClientStatusRequests> request,
  ) async* {
    try {
      print('Got new Client');

      StartServer.getFromApp(
        request: request,
        requestUrl: 'Error, Hub does not suppose to have request URL',
        isRemotePipes: false,
      );

      yield* HubRequestsToApp.streamRequestsToApp.map((dynamic entityDto) {
        return RequestsAndStatusFromHub(
          sendingType: SendingType.deviceType,
          allRemoteCommands: 'Test Data',
        );
      }).handleError((error) {
        print('Stream have error $error');
      });
    } catch (e) {
      print('Hub server error $e');
    }
  }

  @override
  Future<CompHubInfo> getCompHubInfo(
    ServiceCall call,
    CompHubInfo request,
  ) async {
    print('Hub info got requested');

    final CbjHubIno cbjHubIno = CbjHubIno(
      deviceName: 'cbj Hub',
      protoLastGenDate: 'Test Data 2',
      dartSdkVersion: Platform.version,
    );

    final CompHubSpecs compHubSpecs = CompHubSpecs(
      compOs: Platform.operatingSystem,
    );

    final CompHubInfo compHubInfo = CompHubInfo(
      cbjInfo: cbjHubIno,
      compSpecs: compHubSpecs,
    );
    return compHubInfo;
  }

  @override
  Stream<ClientStatusRequests> hubTransferDevices(
    ServiceCall call,
    Stream<RequestsAndStatusFromHub> request,
  ) async* {
    // TODO: implement registerHub
    throw UnimplementedError();
  }
}
