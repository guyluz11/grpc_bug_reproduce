import 'package:grpc_bug_reproduce_client/grpc_bug_reproduce_client.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });
}
