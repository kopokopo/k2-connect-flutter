class Links {
  final String callbackUrl;
  final String self;

  Links({
    required this.callbackUrl,
    required this.self,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(callbackUrl: json['callback_url'], self: json['self']);
  }
}
