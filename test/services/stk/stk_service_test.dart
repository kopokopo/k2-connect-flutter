import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:k2_connect_flutter/src/shared/amount.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/subscriber.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/error_request_payment.dart';
import 'package:k2_connect_flutter/src/stk/views/widgets/request_payment_section.dart';
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
            body: ErrorRequestPayment(
              error: 'Test error occurred',
              onError: () {
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

    testWidgets('renders fallback error message when error is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRequestPayment(
              error: null,
              onError: () {},
            ),
          ),
        ),
      );

      expect(find.text('An error occurred'), findsOneWidget);
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
  });
}
