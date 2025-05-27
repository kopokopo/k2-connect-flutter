library;

import 'package:k2_connect_flutter/k2_connect_credentials.dart';
import 'package:k2_connect_flutter/src/shared/k2_connect_logger.dart';
import 'package:k2_connect_flutter/src/stk/models/stk_push_request.dart';
import 'package:k2_connect_flutter/src/stk/services/stk_service.dart';
import 'package:k2_connect_flutter/src/tokens/token_service.dart';

export 'k2_connect_credentials.dart';
export 'src/tokens/models/token_response.dart';
export 'src/stk/models/stk_push_request.dart';
export 'src/shared/amount.dart';
export 'src/stk/models/subscriber.dart';
export 'src/tokens/token_service.dart';

/// A singleton class that provides access to K2 Connect features.
///
/// Before any other method can be called, the [initialize] method must be
/// called to set the base URL and client credentials.
class K2ConnectFlutter {
  static String? _baseUrl;
  static K2ConnectCredentials? _credentials;

  /// Initializes the K2 Connect Flutter client.
  ///
  /// This method must be called before making any requests.
  ///
  /// - @param[baseUrl] is the API base URL, e.g., `sandbox.kopokopo.com`.
  /// - @param[credentials] is an instance of [K2ConnectCredentials] containing
  /// the client ID and secret.
  /// - @param[loggingEnabled] controls whether internal logs are printed;
  /// defaults to `false`.
  ///
  /// Example usage:
  /// ```dart
  /// await K2ConnectFlutter.initialize(
  ///   baseUrl: 'https://api.example.com',
  ///   credentials: K2ConnectCredentials(
  ///     clientId: 'your-client-id',
  ///     clientSecret: 'your-client-secret',
  ///     apiKey: 'your-api-key',
  ///   ),
  ///   loggingEnabled: true,
  /// );
  static Future<void> initialize({
    required String baseUrl,
    required K2ConnectCredentials credentials,
    bool loggingEnabled = false,
  }) async {
    _baseUrl = baseUrl;
    _credentials = credentials;

    await K2ConnectLogger.init(shouldLog: loggingEnabled);
  }

  /// Retrieves an instance of [TokenService] to manage access tokens. This
  /// service provides functionalities to request new access tokens and revoke
  /// existing ones.
  ///
  /// Before calling this method, ensure that [K2ConnectFlutter] has been
  /// properly initialized.
  ///
  /// Example usage:
  /// ```dart
  /// final tokenService = K2ConnectFlutter.tokenService();
  /// try {
  ///   final tokenResponse = await tokenService.requestAccessToken();
  ///   print('Access Token: ${tokenResponse.accessToken}');
  /// } catch (e) {
  ///   print('Error requesting token: ${e.message}');
  /// }
  /// ```
  static TokenService tokenService() {
    _checkIfRequiredValuesSet();

    return TokenService(
      baseUrl: _baseUrl!,
      credentials: _credentials!,
    );
  }

  static void _checkIfRequiredValuesSet() {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Call initialize() first.');
    }

    if (_credentials == null) {
      throw Exception('Credentials not set. Call initialize() first.');
    }
  }

  K2ConnectFlutter._internal();

  static final K2ConnectFlutter _instance = K2ConnectFlutter._internal();

  factory K2ConnectFlutter() {
    return _instance;
  }

  /// Creates and returns an instance of [StkService] configured to handle
  /// M-Pesa STK Push payment requests using the K2 Connect API.
  ///
  /// The returned service exposes two main methods:
  ///
  /// ### 1. `requestPaymentBottomSheet(BuildContext context)`
  /// - Launches a modal bottom sheet UI where the customer can confirm and complete
  ///   the payment request interactively.
  /// - Internally, it passes the following parameters to the bottom sheet widget:
  ///   - [companyName]: Display name in the UI (optional).
  ///   - [accessToken]: Auth token used for making requests.
  ///   - [baseUrl]: API base URL (e.g., sandbox or production).
  ///   - [tillNumber]: The receiving business till.
  ///   - [currency]: The currency code, e.g. `"KES"`.
  ///   - [amount]: Amount to be charged.
  ///   - [callbackUrl]: Webhook URL for status updates.
  ///   - [metadata]: Additional payload data.
  ///   - [onSuccess]: Called if the payment completes successfully.
  ///   - [onError]: Called if the payment fails or is rejected.
  ///
  /// ### 2. `requestPayment()`
  /// - Sends the [StkPushRequest] payload directly to the Kopo Kopo API without UI.
  /// - Use this if you don’t want to show a UI and have already collected customer input.
  ///
  /// ---
  ///
  /// **Preconditions**
  /// - You must call `K2ConnectFlutter.initialize(...)` first.
  /// - You must obtain a valid access token using
  ///   `K2ConnectFlutter.tokenService().requestAccessToken()` before calling this.
  ///
  /// ---
  ///
  /// **Example usage:**
  /// ```dart
  /// final tokenService = K2ConnectFlutter.tokenService();
  /// final token = await tokenService.requestAccessToken();
  ///
  /// final request = StkPushRequest(
  ///   companyName: 'Acme Corp',
  ///   tillNumber: 'K000123',
  ///   amount: Amount(value: '100.00'),
  ///   callbackUrl: 'https://webhook.site/your-url',
  ///   metadata: {'order_id': '1234'},
  ///   accessToken: token.accessToken
  /// );
  ///
  /// final stkService = K2ConnectFlutter.stkService();
  ///
  /// // Launch UI
  /// await stkService.requestPaymentBottomSheet(context, request: request);
  ///
  /// // Or just send directly
  /// final response = await stkService.requestPayment(request);
  /// ```
  static StkService stkService() {
    _checkIfRequiredValuesSet();

    return StkService(
      baseUrl: _baseUrl!,
    );
  }
}
