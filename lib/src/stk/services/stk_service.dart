import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:k2_connect_flutter/src/shared/api_service.dart';
import 'package:k2_connect_flutter/src/shared/k2_connect_logger.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request_status.dart';
import 'package:k2_connect_flutter/src/stk/views/request_payment_bottom_sheet.dart';
import 'package:k2_connect_flutter/src/utils/generate_url.dart';

import '../../utils/utils.dart';

class StkService extends ApiService {
  final String baseUrl;

  StkService({
    super.client,
    required this.baseUrl,
  });

  /// Displays a modal bottom sheet UI to initiate an STK Push payment request.
  ///
  /// This is the user-facing flow that shows a confirmation UI before sending
  /// the payment request to the K2 Connect API.
  ///
  /// It uses the values provided in the [StkPushRequest] object passed to
  /// the [StkService], including:
  /// - [companyName]: Displayed in the UI (optional).
  /// - [tillNumber]: The business till number to receive the payment.
  /// - [amount]: The amount to be charged (with currency).
  /// - [callbackUrl]: A URL to receive payment status updates.
  /// - [metadata]: Optional custom data.
  /// - [onSuccess]: Callback when the payment completes successfully.
  /// - [onError]: Callback when the payment fails.
  ///
  /// This method must be called with a valid [BuildContext], and typically
  /// runs in response to a user action (e.g. button tap).
  Future<void> requestPaymentBottomSheet(BuildContext context,
      {required StkPushRequest request}) async {
    await showModalBottomSheet<void>(
      backgroundColor: K2Theme.themeData(
        K2Theme.lightColorScheme,
        K2Colors.darkBlue,
      ).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Theme(
          data: K2Theme.themeData(
            K2Theme.lightColorScheme,
            K2Colors.darkBlue,
          ),
          child: RequestPaymentBottomSheet(
            companyName: request.companyName ?? '',
            accessToken: request.accessToken,
            baseUrl: baseUrl,
            tillNumber: request.tillNumber,
            currency: request.amount.currency,
            amount: request.amount.value,
            callbackUrl: request.callbackUrl,
            metadata: request.metadata,
            onSuccess: request.onSuccess,
            onError: request.onError,
          ),
        );
      },
    );
  }

  /// Sends a direct STK Push payment request to the K2 Connect API without showing any UI.
  ///
  /// This method is suitable for background operations or custom UIs where you do not want to
  /// present a bottom sheet. It constructs a `POST` request with the payload defined in the
  /// associated [StkPushRequest].
  ///
  /// A valid [accessToken] must be provided when initializing the [StkService].
  ///
  /// Returns a [Response] object that contains the API’s raw HTTP response.
  ///
  /// Example:
  /// ```dart
  /// final response = await stkService.requestPayment();
  /// if (response?.statusCode == 201) {
  ///   print('Payment initiated successfully');
  /// }
  /// ```
  Future<Response?> requestPayment(StkPushRequest request) async {
    final response = await sendRequest(
        otherHeaders: {
          'Authorization': 'Bearer ${request.accessToken}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        requestType: HttpMethod.POST,
        url: generateUrl(
            baseUrl, '${AppConfig.k2ConnectVersion}/incoming_payments'),
        queryParameters: jsonEncode(request.toJson()));

    K2ConnectLogger.d('StkService Request payment response: $response');

    return response;
  }

  /// Checks the status of a previously initiated STK Push payment request.
  ///
  /// This method is used to verify the result of an STK Push request by querying
  /// the status endpoint provided in the `location` header of the payment initiation
  /// response. This allows clients to determine whether a payment was received,
  /// failed, or is still pending.
  ///
  /// The [uri] parameter is a full URL typically obtained via:
  /// ```dart
  /// final String uri = response.headers['location']!;
  /// ```
  ///
  /// A valid [accessToken] must also be provided.
  ///
  /// Returns a [StkPushRequestStatus] object which contains the full details of the
  /// payment, including status, timestamp, metadata, and callback links.
  ///
  /// Example:
  /// ```dart
  /// final status = await stkService.requestStatus(
  ///   uri: result.headers['location']!,
  ///   accessToken: accessToken,
  /// );
  ///
  /// if (status.attributes.status == 'Received') {
  ///   print('Payment successful');
  /// } else if (status.attributes.status == 'Failed') {
  ///   print('Payment failed');
  /// }
  /// ```
  Future<StkPushRequestStatus> requestStatus({
    required String uri,
    required String accessToken,
  }) async {
    final response = await sendRequest(
      otherHeaders: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      requestType: HttpMethod.GET,
      url: Uri.parse(uri),
    );

    if (response == null) {
      throw Exception('No response received');
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return StkPushRequestStatus.fromJson(json['data']);
  }
}
