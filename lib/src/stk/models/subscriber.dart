class Subscriber {
  final String? firstName;
  final String? lastName;
  final String phoneNumber;
  final String? email;

  Subscriber({
    this.firstName,
    this.lastName,
    required this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
    };
  }
}
