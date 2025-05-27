class Amount {
  final String? currency;
  final String value;

  Amount({
    this.currency = 'KES',
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'value': value,
    };
  }
}