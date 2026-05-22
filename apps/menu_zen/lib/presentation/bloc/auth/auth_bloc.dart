import 'package:data/local/datasources/customer_orders_local_datasource.dart';
import 'package:data/local/datasources/customer_reservations_local_datasource.dart';
import 'package:data/local/datasources/favorites_local_datasource.dart';
import 'package:data/services/customer_token_storage.dart';
import 'package:domain/entities/customer_entity.dart';
import 'package:domain/params/customer_login_params.dart';
import 'package:domain/params/customer_register_params.dart';
import 'package:domain/repositories/customer_auth_repository.dart';
import 'package:domain/services/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CustomerAuthRepository _auth;
  final CustomerTokenStorage _tokenStorage;
  final ConnectivityService _connectivity;
  final CustomerOrdersLocalDatasource _ordersLocal;
  final CustomerReservationsLocalDatasource _reservationsLocal;
  final FavoritesLocalDatasource _favoritesLocal;

  AuthBloc({
    required CustomerAuthRepository auth,
    required CustomerTokenStorage tokenStorage,
    required ConnectivityService connectivity,
    required CustomerOrdersLocalDatasource ordersLocal,
    required CustomerReservationsLocalDatasource reservationsLocal,
    required FavoritesLocalDatasource favoritesLocal,
  }) : _auth = auth,
       _tokenStorage = tokenStorage,
       _connectivity = connectivity,
       _ordersLocal = ordersLocal,
       _reservationsLocal = reservationsLocal,
       _favoritesLocal = favoritesLocal,
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
    // Don't blow away a valid session because the user happens to be offline
    // on launch. Plan: when offline with a token on disk, sit in AuthOffline
    // and let the user retry once connectivity returns.
    if (!await _connectivity.isOnline()) {
      emit(const AuthOffline());
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
    if (!await _connectivity.isOnline()) {
      emit(const AuthUnauthenticated(
        errorMessage:
            "You're offline. Connect to the internet to sign in.",
      ));
      return;
    }
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
    if (!await _connectivity.isOnline()) {
      emit(const AuthUnauthenticated(
        errorMessage:
            "You're offline. Connect to the internet to register.",
      ));
      return;
    }
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
    // Logout requires the server so it can invalidate the token. If the
    // device is offline, keep the session intact and surface that to the
    // caller via the unchanged state.
    if (!await _connectivity.isOnline()) {
      return;
    }
    await _auth.logout();
    // Explicit logout: wipe the customer-only caches so the next user on
    // this device doesn't see prior history. Public reads (restaurants,
    // menus, reviews) survive — they're not user-scoped.
    await _clearCustomerCaches();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Server rejected the token — drop it but keep cached reads so the
    // next sign-in lands on a warm app instead of an empty one.
    await _tokenStorage.clear();
    emit(const AuthUnauthenticated());
  }

  Future<void> _clearCustomerCaches() async {
    await Future.wait([
      _ordersLocal.clearAll(),
      _reservationsLocal.clearAll(),
      _favoritesLocal.clearAll(),
    ]);
  }
}
