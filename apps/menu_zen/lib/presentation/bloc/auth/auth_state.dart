part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

/// First frame before we know whether a token is on disk.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A login, register, or boot-time profile fetch is in flight.
class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

class AuthAuthenticated extends AuthState {
  final CustomerEntity customer;

  const AuthAuthenticated(this.customer);
}

class AuthUnauthenticated extends AuthState {
  /// Set when the unauthenticated state is the result of a failed
  /// login/register attempt. Cleared on the next attempt.
  final String? errorMessage;

  const AuthUnauthenticated({this.errorMessage});
}

/// A token is on disk but the device is offline, so we can't verify it.
/// The router lands on a "connect to sign in" screen until connectivity
/// returns and `AuthStarted` is re-dispatched.
class AuthOffline extends AuthState {
  const AuthOffline();
}
