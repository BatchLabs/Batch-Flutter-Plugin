import 'package:batch_flutter/batch_user.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //const MethodChannel coreChannel = MethodChannel('batch_flutter');
  const MethodChannel userChannel = MethodChannel('batch_flutter.user');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {
    userChannel.setMockMethodCallHandler(null);
  });

  test('getInstallationID', () async {
    userChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'user.getInstallationID') {
        return "abcdef-ghij";
      }
    });

    expect(await BatchUser.instance.installationID, 'abcdef-ghij');
  });
}
