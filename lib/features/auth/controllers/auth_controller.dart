import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/models/usuario.dart';
import '../../../core/models/auth_response.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

/// AuthController — Capa de Control (MVC) para Autenticación
/// Extiende ChangeNotifier para integrarse con Provider
/// También extiende Listenable para go_router refresh
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  final Box _cacheBox;

  AuthState _state = const AuthState.initial();
  Usuario? _currentUser;
  bool _isAuthenticated = false;

  AuthController({
    AuthRepository? repository,
  })  : _repository = repository ?? AuthRepository(),
        _cacheBox = Hive.box('app_cache') {
    _checkStoredSession();
  }

  // ─── Getters ──────────────────────────────────────────────────
  AuthState get state => _state;
  Usuario? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _state is AuthStateLoading;
  String? get errorMessage =>
      _state is AuthStateError ? (_state as AuthStateError).message : null;

  // ─── Verificar sesión almacenada ──────────────────────────────
  Future<void> _checkStoredSession() async {
    final token = _cacheBox.get(StorageKeys.accessToken);
    final userData = _cacheBox.get(StorageKeys.userData);

    if (token != null && userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        _currentUser = Usuario.fromJson(userMap);
        _isAuthenticated = true;
        _state = const AuthState.authenticated();
        notifyListeners();
      } catch (_) {
        await _clearSession();
      }
    }
  }

  // ─── Login ────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    _state = const AuthState.loading();
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _repository.login(request);

      await _saveSession(response);

      _currentUser = response.usuario;
      _isAuthenticated = true;
      _state = const AuthState.authenticated();
      notifyListeners();
    } on ApiException catch (e) {
      _state = AuthState.error(e.message);
      notifyListeners();
    } catch (e) {
      _state = AuthState.error('Error inesperado: ${e.toString()}');
      notifyListeners();
    }
  }

  // ─── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ignorar errores en logout remoto
    } finally {
      await _clearSession();
      _currentUser = null;
      _isAuthenticated = false;
      _state = const AuthState.initial();
      notifyListeners();
    }
  }

  // ─── Recuperar contraseña ─────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _state = const AuthState.loading();
    notifyListeners();

    try {
      await _repository.forgotPassword(email);
      _state = const AuthState.initial();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error(e.message);
      notifyListeners();
      return false;
    }
  }

  // ─── Actualizar perfil local ───────────────────────────────────
  Future<void> updateLocalUser(Usuario updatedUser) async {
    _currentUser = updatedUser;
    await _cacheBox.put(
      StorageKeys.userData,
      jsonEncode(updatedUser.toJson()),
    );
    notifyListeners();
  }

  // ─── Helpers privados ─────────────────────────────────────────
  Future<void> _saveSession(AuthResponse response) async {
    await _cacheBox.put(StorageKeys.accessToken, response.accessToken);
    if (response.refreshToken != null) {
      await _cacheBox.put(StorageKeys.refreshToken, response.refreshToken!);
    }
    await _cacheBox.put(
      StorageKeys.userData,
      jsonEncode(response.usuario.toJson()),
    );
    await _cacheBox.put(StorageKeys.userRole, response.usuario.rol);
  }

  Future<void> _clearSession() async {
    await _cacheBox.clear();
  }
}
