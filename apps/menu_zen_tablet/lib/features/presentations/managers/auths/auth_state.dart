part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = BlocStatus.init,
    this.authStatus = AuthStatus.initial,
    this.userRestaurant,
  });

  final BlocStatus status;
  final UserRestaurantEntity? userRestaurant;
  final AuthStatus authStatus;

  AuthState copyWith({
    BlocStatus? status,
    UserRestaurantEntity? userRestaurant,
    AuthStatus? authStatus,
  }) {
    return AuthState(
      status: status ?? this.status,
      userRestaurant: userRestaurant ?? this.userRestaurant,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  @override
  List<Object?> get props => [status, userRestaurant, authStatus];
}

enum AuthStatus { initial, authenticated, unauthenticated, error }
