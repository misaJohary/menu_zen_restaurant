part of 'users_bloc.dart';

class UsersState extends Equatable {
  final List<UserEntity> users;
  final List<RoleEntity> roles;
  final BlocStatus status;
  final Failure? failure;

  const UsersState({
    this.users = const [],
    this.roles = const [],
    this.status = BlocStatus.init,
    this.failure,
  });

  UsersState copyWith({
    List<UserEntity>? users,
    List<RoleEntity>? roles,
    BlocStatus? status,
    Failure? failure,
  }) {
    return UsersState(
      users: users ?? this.users,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [users, roles, status, failure];
}
