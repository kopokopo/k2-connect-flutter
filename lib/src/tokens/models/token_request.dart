class TokenRequest {
  final String clientId;
  final String clientSecret;
  final String grantType;

  TokenRequest({
    required this.clientId,
    required this.clientSecret,
    this.grantType = 'client_credentials',
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': grantType,
    };
  }
}
