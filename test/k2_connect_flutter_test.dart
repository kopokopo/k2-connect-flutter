import 'package:flutter_test/flutter_test.dart';
import 'package:k2_connect_flutter/k2_connect_flutter.dart';
import 'package:k2_connect_flutter/src/shared/k2_connect_logger.dart';

void main() {
  group('K2ConnectFlutter', () {
    const testBaseUrl = 'https://api.example.com';
    final testCredentials = K2ConnectCredentials(
      clientId: 'test-client-id',
      clientSecret: 'test-secret',
      apiKey: 'test-api-key',
    );

    setUp(() {
      K2ConnectFlutter.initialize(
        baseUrl: testBaseUrl,
        credentials: testCredentials,
      );
    });

    test('initialize sets baseUrl and credentials', () async {
      await K2ConnectFlutter.initialize(
        baseUrl: testBaseUrl,
        credentials: testCredentials,
        loggingEnabled: true,
      );
    });

    test('K2ConnectFlutter factory constructor returns singleton instance', () {
      final instance1 = K2ConnectFlutter();
      final instance2 = K2ConnectFlutter();

      expect(instance1, same(instance2));
    });

    test('K2ConnectLogger factory constructor returns singleton instance',
        () async {
      await K2ConnectFlutter.initialize(
        baseUrl: testBaseUrl,
        credentials: testCredentials,
        loggingEnabled: true,
      );

      final instance1 = K2ConnectLogger();
      final instance2 = K2ConnectLogger();

      expect(instance1, same(instance2));
    });
  });
}
