import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _buildDio();
    return _instance!;
  }

  static Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final path = error.requestOptions.path;
        final isAuthEndpoint = path.contains('/auth/login') || path.contains('/auth/biometric');
        if (error.response?.statusCode == 401 && !isAuthEndpoint) {
          // 401 en un endpoint autenticado = sesión expirada/revocada.
          // 401 en login/biometric = credenciales incorrectas, no borrar el biometric_token existente.
          await _storage.delete(key: 'auth_token');
          await _storage.delete(key: 'biometric_token');
          await _storage.delete(key: 'device_id');
          // Caller handles navigation on 401
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static void reset() => _instance = null;
}
