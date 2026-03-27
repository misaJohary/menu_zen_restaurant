import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/enums/bloc_status.dart';
import '../../../../core/errors/failure.dart';
import '../../../datasources/models/role_model.dart';
import '../../../datasources/models/user_model.dart';
import '../../../domains/repositories/auth_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

@injectable
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final AuthRepository repo;

  UsersBloc(this.repo) : super(const UsersState()) {
    on<UsersFetched>(_onUsersFetched);
    on<UserCreated>(_onUserCreated);
    on<UserUpdated>(_onUserUpdated);
    on<UserDeleted>(_onUserDeleted);
    on<RolesFetched>(_onRolesFetched);
  }

  Future<void> _onUsersFetched(
    UsersFetched event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.getUsers();
    if (res.isSuccess) {
      emit(state.copyWith(status: BlocStatus.loaded, users: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onUserCreated(
    UserCreated event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.createUser(event.user);
    if (res.isSuccess) {
      add(const UsersFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onUserUpdated(
    UserUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.updateAnyUser(event.user);
    if (res.isSuccess) {
      add(const UsersFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onUserDeleted(
    UserDeleted event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.deleteUser(event.userId);
    if (res.isSuccess) {
      add(const UsersFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onRolesFetched(
    RolesFetched event,
    Emitter<UsersState> emit,
  ) async {
    final res = await repo.getRoles();
    if (res.isSuccess) {
      emit(state.copyWith(roles: res.getSuccess));
    }
  }
}
