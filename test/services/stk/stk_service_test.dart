import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:k2_connect_flutter/src/shared/amount.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_alert.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_status.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/success_request_payment.dart';
import 'package:k2_connect_flutter/src/utils/utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/test_data_utils.dart';

@GenerateMocks([http.Client])
import 'stk_service_test.mocks.dart';

void main() {
  group('RequestPaymentSection', () {
    late TextEditingController phoneNumberController;
    late bool paymentRequested;

    setUp(() {
      phoneNumberController = TextEditingController();
      paymentRequested = false;
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: RequestPaymentSection(
            amount: fakeAmount,
            phoneNumberController: phoneNumberController,
            requestPayment: () {
              paymentRequested = true;
            },
          ),
        ),
      );
    }

    testWidgets('renders request payment bottom sheet correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Lipa na MPESA'), findsOneWidget);
      expect(find.text('Amount to pay'), findsOneWidget);
      expect(find.text('${AppConfig.defaultDisplayCurrency} $fakeAmount'),
          findsOneWidget);
      expect(find.text('Enter M-PESA phone number'), findsOneWidget);
      expect(find.text('Proceed to pay'), findsOneWidget);
    });

    testWidgets('invokes requestPayment callback on button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Proceed to pay'));
      await tester.pump();

      expect(paymentRequested, isTrue);
    });

    testWidgets('shows +254 prefix', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('+254'), findsOneWidget);
    });

    testWidgets('can enter phone number', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      final phoneField = find.byType(TextFormField);
      expect(phoneField, findsOneWidget);

      await tester.enterText(phoneField, '712345678');
      expect(phoneNumberController.text, '712 345 678');
    });
  });

  group('Error request payment widget', () {
    testWidgets('renders error message and calls onError on Done tap',
        (WidgetTester tester) async {
      bool onErrorCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RequestPaymentAlert(
              iconColour: K2Colors.error,
              label: 'Payment declined',
              description: 'Test error occurred',
              action: () {
                onErrorCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Payment declined'), findsOneWidget);
      expect(find.text('Test error occurred'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(onErrorCalled, isTrue);
    });
  });

  group('Success request payment widget', () {
    testWidgets('renders success message and countdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessRequestPayment(
              companyName: fakeCompanyName,
              amount: fakeAmount,
              onSuccess: () {},
            ),
          ),
        ),
      );

      final richTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();

      final matches = richTexts.where((richText) {
        final span = richText.text as TextSpan;
        final combined = span.children?.map((s) => s.toPlainText()).join() ??
            span.toPlainText();
        return combined ==
            'You have paid ${AppConfig.defaultDisplayCurrency} $fakeAmount to $fakeCompanyName.';
      });

      expect(matches.length, 1,
          reason: 'Should find exactly one success message RichText');

      final match = matches.single;
      final span = match.text as TextSpan;
      final combined = span.children?.map((s) => s.toPlainText()).join() ??
          span.toPlainText();

      expect(
        combined,
        'You have paid ${AppConfig.defaultDisplayCurrency} $fakeAmount to $fakeCompanyName.',
      );
      expect(find.textContaining('Redirecting'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('calls onSuccess when Done is tapped',
        (WidgetTester tester) async {
      bool onSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuccessRequestPayment(
              companyName: fakeCompanyName,
              amount: fakeAmount,
              onSuccess: () {
                onSuccessCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(onSuccessCalled, isTrue);
    });
  });

  group('Request payment status widget', () {
    testWidgets('shows progress indicator and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RequestPaymentStatus(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(find.text('Processing payment'), findsOneWidget);
    });
  });

  group('StkService', () {
    late MockClient mockClient;
    late StkService stkService;
    late StkPushRequest request;

    setUp(() {
      mockClient = MockClient();
    });

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
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        )).thenAnswer(
          (_) async => http.Response('', 201),
        );

        final response = await stkService.requestPayment(request);

        verify(mockClient.post(
          uri,
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        )).called(1);

        expect(response?.statusCode, equals(201));
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
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        )).thenAnswer(
          (_) async => http.Response(jsonResponse, 400),
        );

        final response = await stkService.requestPayment(request);
        final body = jsonDecode(response?.body ?? '{}');

        verify(mockClient.post(
          uri,
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        )).called(1);

        expect(body['error_message'],
            equals('Subscriber phone number is an invalid number'));
        expect(response?.statusCode, equals(400));
      });
    });

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

      test('returns received', () async {
        final uri = Uri.parse(fakeRequestStatusEndpoint);

        final String jsonResponse =
            File('./test/services/stk/request_status_received.json')
                .readAsStringSync();

        when(mockClient.get(
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )).called(1);

        expect(response.attributes.status, equals('Received'));
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
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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
            File('./test/services/stk/request_status_error.json')
                .readAsStringSync();

        when(mockClient.get(
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )).called(1);

        expect(response.attributes.status, equals('Failed'));
        expect(response.attributes.event?.errors, equals('An error occured.'));
      });
    });

    group('Successful request status', () {
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

      test('returns sent', () async {
        final uri = Uri.parse(fakeRequestStatusEndpoint);

        final String jsonResponse =
            File('./test/services/stk/request_status_sent.json')
                .readAsStringSync();

        when(mockClient.get(
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
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
          headers: {
            'Authorization': 'Bearer ${request.accessToken}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )).called(1);

        expect(response.attributes.status, equals('Sent'));
      });
    });
  });
}
