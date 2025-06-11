import '../../k2_connect_flutter.dart';
import '../shared/api_service.dart';

import '../shared/k2_connect_logger.dart';
import 'models/token_request.dart';

class TokenService extends ApiService {
  final String baseUrl;
  final K2ConnectCredentials credentials;

  TokenService({
    super.client,
    required this.baseUrl,
    required this.credentials,
  });

  /// Requests an access token using the configured credentials.
  ///
  /// Returns a [TokenResponse] containing the access token and related metadata.
  ///
  /// Throws an [Exception] if the credentials or base URL are not set,
  /// or if the request fails.
  Future<TokenResponse> requestAccessToken() async {
    final request = TokenRequest(
      clientId: credentials.clientId,
      clientSecret: credentials.clientSecret,
    );

    final response = await sendRequest(
      requestType: HttpMethod.POST,
      baseUrl: baseUrl,
      endpoint: 'oauth/token',
      queryParameters: request.toJson(),
    );

    K2ConnectLogger.d('TokenService Response: ${response?.body}');

    return processResponse<TokenResponse>(
      response,
      (data) => TokenResponse.fromJson(data),
    );
  }
}
