part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = BlocStatus.init,
    this.authStatus = AuthStatus.initial,
    this.userRestaurant,
    this.errorMessage,
  });

  final BlocStatus status;
  final UserRestaurantEntity? userRestaurant;
  final AuthStatus authStatus;
  final String? errorMessage;

  AuthState copyWith({
    BlocStatus? status,
    UserRestaurantEntity? userRestaurant,
    AuthStatus? authStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userRestaurant: userRestaurant ?? this.userRestaurant,
      authStatus: authStatus ?? this.authStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, userRestaurant, authStatus, errorMessage];
}

enum AuthStatus { initial, authenticated, unauthenticated, error }
