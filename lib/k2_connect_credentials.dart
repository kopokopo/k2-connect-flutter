class K2ConnectCredentials {
  final String clientId;
  final String clientSecret;
  final String apiKey;

  K2ConnectCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.apiKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_secret': clientSecret,
      'api_key': apiKey,
    };
  }
}
