import 'package:k2_connect_flutter/k2_connect_credentials.dart';

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
final fakeRequestStatusEndpoint = 'https://sandbox.kopokopo.com/api/v1/incoming_payments/91a36c47-346d-4f89-bab7-7d779x1864996df';
