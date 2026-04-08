part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class UsersFetched extends UsersEvent {
  const UsersFetched();
}

class UserCreated extends UsersEvent {
  final UserModel user;
  const UserCreated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserUpdated extends UsersEvent {
  final UserModel user;
  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UsersEvent {
  final int userId;
  const UserDeleted(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RolesFetched extends UsersEvent {
  const RolesFetched();
}
