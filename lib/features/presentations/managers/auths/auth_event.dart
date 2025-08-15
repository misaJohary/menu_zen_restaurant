part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthLoggedIn extends AuthEvent {
  final LoginParams loginParams;

  const AuthLoggedIn(this.loginParams);

  @override
  List<Object?> get props => [loginParams];
}

class AuthLoggedOut extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class AuthUserGot extends AuthEvent {
  const AuthUserGot();

  @override
  List<Object?> get props => [];
}
