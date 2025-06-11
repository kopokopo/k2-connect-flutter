library;

import 'k2_connect_credentials.dart';
import 'src/shared/k2_connect_logger.dart';
import 'src/tokens/token_service.dart';

export 'k2_connect_credentials.dart';
export 'src/tokens/models/token_response.dart';
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
}
