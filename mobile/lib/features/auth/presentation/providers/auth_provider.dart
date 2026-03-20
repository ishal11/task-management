import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_models.dart';
import '../../data/auth_repository.dart';
import '../../../../core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearUser = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repo.getStoredUser();
    if (user != null) state = state.copyWith(user: user);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = await _repo.login(email: email, password: password);
      state = state.copyWith(user: auth.user, isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = await _repo.register(name: name, email: email, password: password);
      state = state.copyWith(user: auth.user, isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  String _parseError(Exception e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'] as String;
      if (e.response?.statusCode == 401) return 'Invalid credentials';
      if (e.response?.statusCode == 409) return 'Email already registered';
      if (e.type == DioExceptionType.connectionTimeout) return 'Connection timed out';
      if (e.type == DioExceptionType.unknown) return 'Cannot connect to server';
    }
    return 'Something went wrong';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
