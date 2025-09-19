import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:k2_connect_flutter/k2_connect_flutter.dart';
import 'package:k2_connect_flutter/src/shared/k2_http_exception.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';
import 'package:k2_connect_flutter/src/stk/views/request_payment_bottom_sheet.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/success_request_payment.dart';
import 'package:k2_connect_flutter/src/utils/generate_url.dart';
import 'package:k2_connect_flutter/src/utils/utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/test_data_utils.dart';

@GenerateMocks([http.Client])
import 'stk_service_test.mocks.dart';

void main() {
  group('StkService', () {
    late MockClient mockClient;
    late StkService stkService;
    late StkPushRequest request;

    setUp(() {
      mockClient = MockClient();
    });

    group('requestPaymentBottomSheet()', () {
      Future<void> pumpBottomSheet(WidgetTester tester,
          {required StkService stkService,
          required StkPushRequest stkPushRequest}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => stkService.requestPaymentBottomSheet(
                  context,
                  stkPushRequest: stkPushRequest,
                ),
                child: const Text("Open"),
              ),
            ),
          ),
        );
        await tester.tap(find.text("Open"));
        await tester.pumpAndSettle();
      }

      void mockSuccessfulRequestPayment(
          MockClient testMockClient, StkPushRequest stkPushRequest) {
        // Mock successful requestPayment() request
        when(testMockClient.post(
          generateUrl(
              fakeBaseUrl, '${AppConfig.k2ConnectVersion}/incoming_payments'),
          headers: testHeaders(stkPushRequest.accessToken),
          body: jsonEncode(stkPushRequest.toJson()),
        )).thenAnswer(
          (_) async => http.Response('', 201,
              headers: {'location': fakeRequestStatusEndpoint}),
        );
      }

      testWidgets(
          "should show bottom sheet when requestPaymentBottomSheet is called",
          (tester) async {
        var stkPushRequest = StkPushRequest(
          tillNumber: "123456",
          companyName: fakeCompanyName,
          amount: Amount(value: "1000"),
          callbackUrl: "https://callback.test",
          accessToken: fakeAccessToken,
        );

        stkService = StkService(
          client: mockClient,
          baseUrl: fakeBaseUrl,
        );
        await pumpBottomSheet(tester,
            stkService: stkService, stkPushRequest: stkPushRequest);

        expect(find.byType(RequestPaymentBottomSheet), findsOneWidget);
        expect(find.text("Powered by"), findsOneWidget);
      });

      testWidgets("should start with RequestPaymentSection", (tester) async {
        var stkPushRequest = StkPushRequest(
          tillNumber: "123456",
          companyName: fakeCompanyName,
          amount: Amount(value: "1000"),
          callbackUrl: "https://callback.test",
          accessToken: fakeAccessToken,
        );

        stkService = StkService(
          client: mockClient,
          baseUrl: fakeBaseUrl,
        );

        await pumpBottomSheet(tester,
            stkService: stkService, stkPushRequest: stkPushRequest);

        expect(find.byType(RequestPaymentSection), findsOneWidget);
        expect(find.text('Lipa na M-PESA'), findsOneWidget);
        expect(find.text('Amount to pay'), findsOneWidget);
        expect(find.text('${AppConfig.defaultDisplayCurrency} 1000'),
            findsOneWidget);
        expect(find.text('Enter M-PESA phone number'), findsOneWidget);
        expect(find.text('Proceed to pay'), findsOneWidget);
      });

      group('when the initial request payment succeeds', () {
        testWidgets("should show SuccessRequestPayment on successful payment",
            (tester) async {
          var stkPushRequest = StkPushRequest(
            tillNumber: "123456",
            subscriber: Subscriber(phoneNumber: '712345678'),
            companyName: fakeCompanyName,
            amount: Amount(value: "1000"),
            callbackUrl: "https://callback.test",
            accessToken: fakeAccessToken,
          );

          mockSuccessfulRequestPayment(mockClient, stkPushRequest);

          final String successJsonResponse =
              File('./test/services/stk/request_status_success.json')
                  .readAsStringSync();

          when(mockClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer((_) async => http.Response(successJsonResponse, 200));

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          // Trigger requestPaymentBottomSheet
          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          // Enter phone number and submit
          await tester.enterText(find.byType(TextField), '712345678');
          await tester.tap(find.byType(ElevatedButton)); // submit
          await tester.pump(); // loading

          // Wait for the processing of the response
          await tester.pump(const Duration(seconds: 10));
          await tester.pump(); // transition

          expect(find.byType(SuccessRequestPayment), findsOneWidget);
          expect(find.textContaining('Redirecting', findRichText: true),
              findsOneWidget);
          expect(
              find.textContaining("You have paid KSh 1000 to $fakeCompanyName.",
                  findRichText: true),
              findsOneWidget);
          expect(find.text('Done'), findsOneWidget);
        });
      });

      testWidgets("should call onSuccess function when payment is successful",
          (tester) async {
        bool onSuccessCalled = false;
        var stkPushRequest = StkPushRequest(
            tillNumber: "123456",
            subscriber: Subscriber(phoneNumber: '712345678'),
            companyName: fakeCompanyName,
            amount: Amount(value: "1000"),
            callbackUrl: "https://callback.test",
            accessToken: fakeAccessToken,
            onSuccess: () => {onSuccessCalled = true});

        mockSuccessfulRequestPayment(mockClient, stkPushRequest);

        final String successJsonResponse =
            File('./test/services/stk/request_status_success.json')
                .readAsStringSync();

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(successJsonResponse, 200));

        final stkService = StkService(
          client: mockClient,
          baseUrl: fakeBaseUrl,
        );

        // Trigger requestPaymentBottomSheet
        await pumpBottomSheet(tester,
            stkService: stkService, stkPushRequest: stkPushRequest);

        // Enter phone number and submit
        await tester.enterText(find.byType(TextField), '712345678');
        await tester.tap(find.byType(ElevatedButton)); // submit
        await tester.pump(); // loading

        // Wait for the processing of the response
        await tester.pump(const Duration(seconds: 10));
        await tester.pump(); // transition
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(onSuccessCalled, isTrue);
      });

      testWidgets("should retry pending status once then succeed",
          (tester) async {
        var stkPushRequest = StkPushRequest(
          tillNumber: "123456",
          companyName: fakeCompanyName,
          amount: Amount(value: "1000"),
          callbackUrl: "https://callback.test",
          accessToken: fakeAccessToken,
          subscriber: Subscriber(phoneNumber: '711111111'),
        );

        mockSuccessfulRequestPayment(mockClient, stkPushRequest);

        final String pendingJsonResponse =
            File('./test/services/stk/request_status_pending.json')
                .readAsStringSync();

        final String successfulJsonResponse =
            File('./test/services/stk/request_status_success.json')
                .readAsStringSync();

        final responses = [
          http.Response(pendingJsonResponse, 200),
          http.Response(successfulJsonResponse, 200),
        ];

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => responses.removeAt(0));

        final stkService = StkService(
          client: mockClient,
          baseUrl: fakeBaseUrl,
        );

        await pumpBottomSheet(tester,
            stkService: stkService, stkPushRequest: stkPushRequest);

        await tester.enterText(find.byType(TextField), "711111111");
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 10)); // first check
        await tester.pump(const Duration(seconds: 30)); // retry
        await tester.pump();

        expect(find.byType(SuccessRequestPayment), findsOneWidget);
      });

      testWidgets("should show timeout error after max pending retries",
          (tester) async {
        var stkPushRequest = StkPushRequest(
          tillNumber: "123456",
          companyName: fakeCompanyName,
          amount: Amount(value: "1000"),
          callbackUrl: "https://callback.test",
          accessToken: fakeAccessToken,
          subscriber: Subscriber(phoneNumber: '711111111'),
        );

        mockSuccessfulRequestPayment(mockClient, stkPushRequest);

        final String pendingJsonResponse =
            File('./test/services/stk/request_status_pending.json')
                .readAsStringSync();

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(pendingJsonResponse, 200));

        final stkService = StkService(
          client: mockClient,
          baseUrl: fakeBaseUrl,
        );

        await pumpBottomSheet(tester,
            stkService: stkService, stkPushRequest: stkPushRequest);

        await tester.enterText(find.byType(TextField), "711111111");
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 10)); // first check
        await tester.pump(const Duration(seconds: 30)); // retry
        await tester.pump(const Duration(seconds: 30)); // retry
        await tester.pump();

        expect(find.text("Timed out while waiting for payment confirmation"),
            findsOneWidget);
      });
      group('when the initial request payment fails', () {
        testWidgets("should show error when requestPayment returns null",
            (tester) async {
          var stkPushRequest = StkPushRequest(
            tillNumber: "123456",
            companyName: fakeCompanyName,
            amount: Amount(value: "1000"),
            callbackUrl: "https://callback.test",
            accessToken: fakeAccessToken,
            subscriber: Subscriber(phoneNumber: '711111111'),
          );

          when(mockClient.post(
            generateUrl(
                fakeBaseUrl, '${AppConfig.k2ConnectVersion}/incoming_payments'),
            headers: testHeaders(stkPushRequest.accessToken),
            body: jsonEncode(stkPushRequest.toJson()),
          )).thenAnswer((_) async => http.Response('', 201));

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          await tester.enterText(find.byType(TextField), "711111111");
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text("Missing status location header"), findsOneWidget);
        });

        testWidgets("should show error message from K2HttpException",
            (tester) async {
          var stkPushRequest = StkPushRequest(
            tillNumber: "123456",
            companyName: fakeCompanyName,
            amount: Amount(value: "1000"),
            callbackUrl: "https://callback.test",
            accessToken: fakeAccessToken,
            subscriber: Subscriber(phoneNumber: '711111111'),
          );

          final String jsonResponse =
              File('./test/services/stk/request_payment_error.json')
                  .readAsStringSync();

          when(mockClient.post(
            generateUrl(
                fakeBaseUrl, '${AppConfig.k2ConnectVersion}/incoming_payments'),
            headers: testHeaders(stkPushRequest.accessToken),
            body: jsonEncode(stkPushRequest.toJson()),
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 400),
          );

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          await tester.enterText(find.byType(TextField), "711111111");
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(find.text("Subscriber phone number is an invalid number"),
              findsOneWidget);
        });

        testWidgets(
            "should call onError function when K2HttpException is thrown",
            (tester) async {
          bool onErrorCalled = false;
          var stkPushRequest = StkPushRequest(
              tillNumber: "123456",
              companyName: fakeCompanyName,
              amount: Amount(value: "1000"),
              callbackUrl: "https://callback.test",
              accessToken: fakeAccessToken,
              onError: (error) => {onErrorCalled = true});

          final String jsonResponse =
              File('./test/services/stk/request_payment_error.json')
                  .readAsStringSync();

          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 400),
          );

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          await tester.enterText(find.byType(TextField), "711111111");
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();

          expect(onErrorCalled, isTrue);
        });

        testWidgets("should show generic error message on Exception",
            (tester) async {
          var stkPushRequest = StkPushRequest(
              tillNumber: "123456",
              companyName: fakeCompanyName,
              amount: Amount(value: "1000"),
              callbackUrl: "https://callback.test",
              accessToken: fakeAccessToken);

          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenThrow(Exception("network error"));

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          await tester.enterText(find.byType(TextField), "711111111");
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();

          expect(
              find.textContaining("An unknown error occured"), findsOneWidget);
        });

        testWidgets(
            "should call onError function when a generic Exception is thrown",
            (tester) async {
          bool onErrorCalled = false;
          var stkPushRequest = StkPushRequest(
              tillNumber: "123456",
              companyName: fakeCompanyName,
              amount: Amount(value: "1000"),
              callbackUrl: "https://callback.test",
              accessToken: fakeAccessToken,
              onError: (error) => {onErrorCalled = true});

          when(mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          )).thenThrow(Exception("network error"));

          final stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );

          await pumpBottomSheet(tester,
              stkService: stkService, stkPushRequest: stkPushRequest);

          await tester.enterText(find.byType(TextField), "711111111");
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();

          expect(onErrorCalled, isTrue);
        });
      });
    });

    group('requestPayment()', () {
      group('valid request payment', () {
        setUp(() {
          request = StkPushRequest(
            tillNumber: fakeTillNumber,
            subscriber: Subscriber(phoneNumber: fakePhoneNumber),
            amount: Amount(value: fakeAmount),
            callbackUrl: '',
            accessToken: fakeAccessToken,
          );

          stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );
        });

        test('returns 201', () async {
          final uri = Uri.https(fakeBaseUrl, '/api/v1/incoming_payments');

          when(mockClient.post(
            uri,
            headers: {
              'User-Agent': 'Kopokopo-Dart-SDK',
              'Authorization': 'Bearer ${request.accessToken}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )).thenAnswer(
            (_) async => http.Response('', 201,
                headers: {'location': '$fakeBaseUrl/my_callback'}),
          );

          final locationUrl =
              await stkService.requestPayment(stkPushRequest: request);

          verify(mockClient.post(
            uri,
            headers: {
              'User-Agent': 'Kopokopo-Dart-SDK',
              'Authorization': 'Bearer ${request.accessToken}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )).called(1);

          expect(locationUrl, equals('$fakeBaseUrl/my_callback'));
        });
      });

      group('invalid request payment', () {
        setUp(() {
          request = StkPushRequest(
            tillNumber: fakeTillNumber,
            subscriber: Subscriber(phoneNumber: fakeInvalidPhoneNumber),
            amount: Amount(value: fakeAmount),
            callbackUrl: '',
            accessToken: fakeAccessToken,
          );

          stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );
        });

        test('returns 400 Bad request', () async {
          final uri = Uri.https(fakeBaseUrl, '/api/v1/incoming_payments');

          final String jsonResponse =
              File('./test/services/stk/request_payment_error.json')
                  .readAsStringSync();

          when(mockClient.post(
            uri,
            headers: {
              'User-Agent': 'Kopokopo-Dart-SDK',
              'Authorization': 'Bearer ${request.accessToken}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 400),
          );

          expect(
              () async =>
                  await stkService.requestPayment(stkPushRequest: request),
              throwsA(
                isA<K2HttpException>().having(
                    (e) => e.body['error_message'],
                    'error_message',
                    'Subscriber phone number is an invalid number'),
              ));
        });
      });
    });
    group('requestStatus()', () {
      group('Valid request status', () {
        setUp(() {
          request = StkPushRequest(
              tillNumber: fakeTillNumber,
              subscriber: Subscriber(phoneNumber: fakePhoneNumber),
              amount: Amount(value: fakeAmount),
              callbackUrl: '',
              accessToken: fakeAccessToken);

          stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );
        });

        test('returns success', () async {
          final uri = Uri.parse(fakeRequestStatusEndpoint);

          final String jsonResponse =
              File('./test/services/stk/request_status_success.json')
                  .readAsStringSync();

          when(mockClient.get(
            headers: testHeaders(request.accessToken),
            uri,
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 200),
          );

          final response = await stkService.requestStatus(
            uri: fakeRequestStatusEndpoint,
            accessToken: request.accessToken,
          );

          verify(mockClient.get(
            uri,
            headers: testHeaders(request.accessToken),
          )).called(1);

          expect(response.attributes.status, equals('Success'));
        });
      });

      group('Pending request status', () {
        setUp(() {
          request = StkPushRequest(
              tillNumber: fakeTillNumber,
              subscriber: Subscriber(phoneNumber: fakePhoneNumber),
              amount: Amount(value: fakeAmount),
              callbackUrl: '',
              accessToken: fakeAccessToken);

          stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );
        });

        test('returns pending', () async {
          final uri = Uri.parse(fakeRequestStatusEndpoint);

          final String jsonResponse =
              File('./test/services/stk/request_status_pending.json')
                  .readAsStringSync();

          when(mockClient.get(
            headers: testHeaders(request.accessToken),
            uri,
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 200),
          );

          final response = await stkService.requestStatus(
            uri: fakeRequestStatusEndpoint,
            accessToken: request.accessToken,
          );

          verify(mockClient.get(
            uri,
            headers: testHeaders(request.accessToken),
          )).called(1);

          expect(response.attributes.status, equals('Pending'));
        });
      });

      group('Failed request status', () {
        setUp(() {
          request = StkPushRequest(
              tillNumber: fakeTillNumber,
              subscriber: Subscriber(phoneNumber: fakePhoneNumber),
              amount: Amount(value: fakeAmount),
              callbackUrl: '',
              accessToken: fakeAccessToken);

          stkService = StkService(
            client: mockClient,
            baseUrl: fakeBaseUrl,
          );
        });

        test('returns failed', () async {
          final uri = Uri.parse(fakeRequestStatusEndpoint);

          final String jsonResponse =
              File('./test/services/stk/request_status_failed.json')
                  .readAsStringSync();

          when(mockClient.get(
            headers: testHeaders(request.accessToken),
            uri,
          )).thenAnswer(
            (_) async => http.Response(jsonResponse, 200),
          );

          final response = await stkService.requestStatus(
            uri: fakeRequestStatusEndpoint,
            accessToken: request.accessToken,
          );

          verify(mockClient.get(
            uri,
            headers: testHeaders(request.accessToken),
          )).called(1);

          expect(response.attributes.status, equals('Failed'));
          expect(response.attributes.event?.errors,
              equals('The initiator information is invalid.'));
        });
      });
    });
  });
}
