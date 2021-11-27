import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_api/netease_api.dart';

void main() {
  const MethodChannel channel = MethodChannel('netease_api');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NeteaseApi.platformVersion, '42');
  });
}
