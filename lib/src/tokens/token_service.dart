import 'package:k2_connect_flutter/k2_connect_flutter.dart';
import 'package:k2_connect_flutter/src/shared/api_response.dart';
import 'package:k2_connect_flutter/src/shared/api_service.dart';
import 'package:k2_connect_flutter/src/tokens/models/revoke_token_request.dart';
import 'package:k2_connect_flutter/src/utils/generate_url.dart';

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
    K2ConnectLogger.d('TokenService - Requesting access token');

    final request = TokenRequest(
      clientId: credentials.clientId,
      clientSecret: credentials.clientSecret,
    );

    final response = await sendRequest(
      requestType: HttpMethod.POST,
      url: generateUrl(baseUrl, 'oauth/token'),
      queryParameters: request.toJson(),
    );

    K2ConnectLogger.d(
        'TokenService requestAccessToken response - ${response?.body}');

    ApiResponse<TokenResponse> parsedResponse =
        await processResponse(response, (data) => TokenResponse.fromJson(data));

    return parsedResponse.data;
  }

  /// Revokes a given access token using the configured credentials.
  ///
  /// @param[accessToken] The access token you want to revoke
  ///
  /// Does not return any value if request succeeds.
  ///
  /// Throws an [Exception] if the credentials or base URL are not set,
  /// or if the request fails.
  Future<void> revokeAccessToken(String accessToken) async {
    K2ConnectLogger.d('TokenService - Revoking access token');

    final request = RevokeTokenRequest(
      clientId: credentials.clientId,
      clientSecret: credentials.clientSecret,
      accessToken: accessToken,
    );

    final response = await sendRequest(
      requestType: HttpMethod.POST,
      url: generateUrl(baseUrl, 'oauth/revoke'),
      queryParameters: request.toJson(),
    );

    K2ConnectLogger.d(
        'TokenService revokeAccessToken response - ${response?.body}');

    ApiResponse<Null> parsedResponse = await processResponse(response, null);

    return parsedResponse.data;
  }
}
