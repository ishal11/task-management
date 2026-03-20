import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static const baseUrl = 'http://10.5.76.8:5000';

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await SecureStorage.getRefreshToken();
            if (refreshToken == null) return handler.next(error);

            final response = await _dio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
              options: Options(headers: {'Authorization': null}),
            );

            final newAccess = response.data['accessToken'] as String;
            final newRefresh = response.data['refreshToken'] as String;

            await SecureStorage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );

            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccess';
            final retryResponse = await _dio.fetch(opts);
            return handler.resolve(retryResponse);
          } catch (e) {
            await SecureStorage.clearAll();
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Dio get dio => _dio;
}
