import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:domain/params/login_params.dart';
import 'package:domain/repositories/auth_repository.dart';
import 'package:data/models/restaurant_model.dart';
import 'package:data/models/user_model.dart';

import '../../../../core/enums/bloc_status.dart';
import 'package:domain/entities/user_restaurant_entity.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthState()) {
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthUserGot>(_onAuthUserGot);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    on<AuthRestaurantUpdated>(_onAuthRestaurantUpdated);
  }

  _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.login(event.loginParams);
    if (res.isSuccess) {
      emit(state.copyWith(authStatus: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.logout();
    if (res.isSuccess) {
      emit(
        state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          status: BlocStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onAuthUserGot(AuthUserGot event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.getUser();
    if (res.isSuccess) {
      emit(
        state.copyWith(
          userRestaurant: res.getSuccess,
          authStatus: AuthStatus.authenticated,
          status: BlocStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.updateUser(event.user);
    if (res.isSuccess) {
      emit(
        state.copyWith(
          userRestaurant: res.getSuccess,
          status: BlocStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onAuthRestaurantUpdated(
    AuthRestaurantUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.updateRestaurant(event.restaurant);
    if (res.isSuccess) {
      // Re-fetch full user data to ensure state consistency
      final fullData = await repo.getUser();
      if (fullData.isSuccess) {
        emit(
          state.copyWith(
            userRestaurant: fullData.getSuccess,
            status: BlocStatus.loaded,
          ),
        );
      } else {
        emit(state.copyWith(status: BlocStatus.loaded));
      }
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }
}
