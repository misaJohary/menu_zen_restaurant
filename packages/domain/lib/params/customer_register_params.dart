class CustomerRegisterParams {
  final String email;
  final String? phone;
  final String? fullName;
  final String password;

  const CustomerRegisterParams({
    required this.email,
    this.phone,
    this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
    if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
    'password': password,
  };
}
