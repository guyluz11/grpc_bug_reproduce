import 'package:grpc_bug_reproduce_server_1/grpc_bug_reproduce_server_1.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });
}
