import 'package:data/services/customer_token_storage.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:domain/params/customer_login_params.dart';
import 'package:domain/params/customer_register_params.dart';
import 'package:domain/repositories/customer_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CustomerAuthRepository _auth;
  final CustomerTokenStorage _tokenStorage;

  AuthBloc({
    required CustomerAuthRepository auth,
    required CustomerTokenStorage tokenStorage,
  }) : _auth = auth,
       _tokenStorage = tokenStorage,
       super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSignedOut>(_onSignedOut);
    on<AuthTokenExpired>(_onTokenExpired);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final token = await _tokenStorage.read();
    if (token == null || token.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(const AuthSubmitting());
    final result = await _auth.me();
    if (result.isSuccess && result.getSuccess != null) {
      emit(AuthAuthenticated(result.getSuccess!));
    } else {
      // Token rejected by the server — drop it.
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());
    final result = await _auth.login(
      CustomerLoginParams(username: event.username, password: event.password),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(AuthAuthenticated(result.getSuccess!.customer));
    } else {
      emit(AuthUnauthenticated(errorMessage: result.getError?.message));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());
    final result = await _auth.register(
      CustomerRegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
      ),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(AuthAuthenticated(result.getSuccess!.customer));
    } else {
      emit(AuthUnauthenticated(errorMessage: result.getError?.message));
    }
  }

  Future<void> _onSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _tokenStorage.clear();
    emit(const AuthUnauthenticated());
  }
}
