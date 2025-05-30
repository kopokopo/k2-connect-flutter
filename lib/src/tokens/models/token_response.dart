class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final int createdAt;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.createdAt,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      createdAt: json['created_at'],
    );
  }

  @override
  String toString() {
    return 'TokenResponse{accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, createdAt: $createdAt}';
  }
}
