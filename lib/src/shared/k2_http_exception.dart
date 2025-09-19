class K2HttpException implements Exception {
  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, String> headers;

  K2HttpException(this.statusCode, this.body, this.headers);

  @override
  String toString() =>
      'HttpException: statusCode=$statusCode, body=$body, headers=$headers';
}
