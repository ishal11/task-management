import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _saveAuth(auth);
    return auth;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _saveAuth(auth);
    return auth;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      await _client.dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}
    await SecureStorage.clearAll();
  }

  Future<User?> getStoredUser() async {
    final userJson = await SecureStorage.getUser();
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAccessToken();
    return token != null;
  }

  Future<void> _saveAuth(AuthResponse auth) async {
    await SecureStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await SecureStorage.saveUser(jsonEncode(auth.user.toJson()));
  }
}
