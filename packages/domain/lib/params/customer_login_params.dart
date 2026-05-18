/// OAuth2 password flow — `username` may be the customer's email or phone.
class CustomerLoginParams {
  final String username;
  final String password;

  const CustomerLoginParams({required this.username, required this.password});
}
