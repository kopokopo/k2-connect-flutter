import 'package:k2_connect_flutter/src/shared/k2_connect_credentials.dart';

final fakeBaseUrl = 'api.example.com';
final fakeCredentials = K2ConnectCredentials(
  clientId: 'test-client-id',
  clientSecret: 'test-client-secret',
  apiKey: 'test-api-key',
);
final fakeAccessToken = 'test-access-token';
final fakeTillNumber = 'K000000';
final fakePhoneNumber = '254712345678';
final fakeInvalidPhoneNumber = '2547123456782334';
final fakeAmount = '10';
final fakeCompanyName = 'Test Company';
final String fakeRequestStatusEndpoint =
    'https://example.test.com/api/v1/incoming_payments/my_test_reference';

Map<String, String> testHeaders(accessToken) {
  return {
    'User-Agent': 'Kopokopo-Dart-SDK',
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
