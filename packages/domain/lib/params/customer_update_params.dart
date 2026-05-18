class CustomerUpdateParams {
  final String? phone;
  final String? fullName;
  final String? avatar;

  const CustomerUpdateParams({this.phone, this.fullName, this.avatar});

  Map<String, dynamic> toJson() => {
    if (phone != null) 'phone': phone,
    if (fullName != null) 'full_name': fullName,
    if (avatar != null) 'avatar': avatar,
  };
}
