class CustomerPasswordChangeParams {
  final String oldPassword;
  final String newPassword;

  const CustomerPasswordChangeParams({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'old_password': oldPassword,
    'new_password': newPassword,
  };
}
