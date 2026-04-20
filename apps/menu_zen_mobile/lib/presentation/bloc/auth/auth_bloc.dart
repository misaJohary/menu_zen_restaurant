import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data/models/user_model.dart';
import 'package:domain/entities/user_restaurant_entity.dart';
import 'package:domain/params/login_params.dart';
import 'package:domain/repositories/auth_repository.dart';

import '../../../core/enums/bloc_status.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(const AuthState()) {
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthUserGot>(_onAuthUserGot);
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  Future<void> _onAuthLoggedIn(
    AuthLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    final res = await repo.login(event.loginParams);
    if (res.isSuccess) {
      emit(state.copyWith(authStatus: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(
        status: BlocStatus.failed,
        authStatus: AuthStatus.unauthenticated,
        errorMessage:
            res.getError?.message ?? 'Identifiants incorrects',
      ));
    }
  }

  Future<void> _onAuthLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.logout();
    if (res.isSuccess) {
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        status: BlocStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  Future<void> _onAuthUserGot(
    AuthUserGot event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.getUser();
    if (res.isSuccess) {
      emit(state.copyWith(
        userRestaurant: res.getSuccess,
        authStatus: AuthStatus.authenticated,
        status: BlocStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.updateUser(event.user);
    if (res.isSuccess) {
      emit(state.copyWith(
        userRestaurant: res.getSuccess,
        status: BlocStatus.loaded,
      ));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }
}
