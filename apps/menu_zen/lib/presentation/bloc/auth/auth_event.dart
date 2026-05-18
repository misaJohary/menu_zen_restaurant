part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;
  final String? phone;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
  });
}

class AuthSignedOut extends AuthEvent {}

class AuthTokenExpired extends AuthEvent {}
