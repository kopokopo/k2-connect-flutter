import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:k2_connect_flutter/src/tokens/models/revoke_token_request.dart';
import 'package:k2_connect_flutter/src/tokens/models/token_request.dart';
import 'package:k2_connect_flutter/src/tokens/token_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/test_data_utils.dart';

@GenerateMocks([http.Client])
import 'token_service_test.mocks.dart';

void main() {
  group('TokenService', () {
    late MockClient mockClient;
    late TokenService tokenService;

    setUp(() async {
      mockClient = MockClient();
      tokenService = TokenService(
        client: mockClient,
        baseUrl: fakeBaseUrl,
        credentials: fakeCredentials,
      );
    });

    group('request access token', () {
      final tokenRequest = TokenRequest(
        clientId: fakeCredentials.clientId,
        clientSecret: fakeCredentials.clientSecret,
      );

      group('when response is valid', () {
        test('returns TokenResponse with correct values', () async {
          final uri = Uri.https(fakeBaseUrl, '/oauth/token');

          final String jsonResponse =
              File('./test/services/tokens/tokens_success.json')
                  .readAsStringSync();

          mockCall() => mockClient.post(uri,
              headers: {'User-Agent': 'Kopokopo-Dart-SDK'},
              body: tokenRequest.toJson());

          when(mockCall())
              .thenAnswer((_) async => http.Response(jsonResponse, 200));

          final response = await tokenService.requestAccessToken();

          verify(mockCall()).called(1);
          expect(response.accessToken, equals('test-access-token'));
          expect(response.tokenType, equals('Bearer'));
          expect(response.createdAt, equals('1010'));
          expect(response.expiresIn, equals(10));
        });
      });

      group('when response is invalid', () {
        test('throws an exception if status code is not 200', () async {
          final uri = Uri.https(fakeBaseUrl, '/oauth/token');

          mockCall() => mockClient.post(uri,
              headers: {'User-Agent': 'Kopokopo-Dart-SDK'},
              body: tokenRequest.toJson());

          when(mockCall()).thenAnswer((_) async => http.Response('{}', 400));

          expect(
            () => tokenService.requestAccessToken(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('HTTP error: 400'),
              ),
            ),
          );

          verify(mockCall()).called(1);
        });
      });
    });

    group('revoke access token', () {
      final revokeTokenRequest = RevokeTokenRequest(
        clientId: fakeCredentials.clientId,
        clientSecret: fakeCredentials.clientSecret,
        accessToken: fakeAccessToken,
      );

      group('when response is valid', () {
        test('returns TokenResponse with correct values', () async {
          final uri = Uri.https(fakeBaseUrl, '/oauth/revoke');

          final String jsonResponse =
              File('./test/shared/base_responses/empty_response.json')
                  .readAsStringSync();

          mockCall() => mockClient.post(uri,
              headers: {'User-Agent': 'Kopokopo-Dart-SDK'},
              body: revokeTokenRequest.toJson());

          when(mockCall())
              .thenAnswer((_) async => http.Response(jsonResponse, 200));

          await tokenService.revokeAccessToken(fakeAccessToken);

          verify(mockCall()).called(1);
        });
      });

      group('when response is invalid', () {
        test('throws an exception if status code is not 200', () async {
          final uri = Uri.https(fakeBaseUrl, '/oauth/revoke');

          mockCall() => mockClient.post(uri,
              headers: {'User-Agent': 'Kopokopo-Dart-SDK'},
              body: revokeTokenRequest.toJson());

          when(mockCall()).thenAnswer((_) async => http.Response('{}', 400));

          expect(
            () => tokenService.revokeAccessToken(fakeAccessToken),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('HTTP error: 400'),
              ),
            ),
          );

          verify(mockCall()).called(1);
        });
      });
    });
  });
}
