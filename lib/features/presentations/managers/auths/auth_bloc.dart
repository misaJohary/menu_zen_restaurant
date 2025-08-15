import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/datasources/login_params.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/auth_repository.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../domains/entities/user_restaurant_entity.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthState()) {
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthUserGot>(_onAuthUserGot);
  }

  _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.login(event.loginParams);
    if (res.isSuccess) {
      emit(
        state.copyWith(
          authStatus: AuthStatus.authenticated,
        ),
      );
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
}
