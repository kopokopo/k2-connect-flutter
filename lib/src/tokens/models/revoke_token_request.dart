class RevokeTokenRequest {
  final String clientId;
  final String clientSecret;
  final String accessToken;

  RevokeTokenRequest({
    required this.clientId,
    required this.clientSecret,
    required this.accessToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_secret': clientSecret,
      'token': accessToken,
    };
  }
}
