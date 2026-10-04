import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const verifiedPhoneKey = 'verified_phone';

  static Future<Map<String, dynamic>> login({
    required String loginName,
    required String password,
    required String phoneNumber,
    required String deviceId,
    String deviceName = 'ReportAs Mobile',
  }) async {
    final response = await ApiClient.instance.post('/auth/login', data: {
      'login_name':   loginName,
      'password':     password,
      'phone_number': phoneNumber,
      'device_id':    deviceId,
      'device_name':  deviceName,
    });

    final data = response.data;
    if (data['success'] == true) {
      await _storage.write(key: 'auth_token',      value: data['data']['token']);
      await _storage.write(key: 'biometric_token', value: data['data']['biometric_token']);
      await _storage.write(key: 'device_id',       value: deviceId);
    }
    return data;
  }

  static Future<Map<String, dynamic>?> biometricLogin() async {
    final deviceId       = await _storage.read(key: 'device_id');
    final biometricToken = await _storage.read(key: 'biometric_token');

    if (deviceId == null || biometricToken == null) return null;

    try {
      final response = await ApiClient.instance.post('/auth/biometric', data: {
        'device_id':       deviceId,
        'biometric_token': biometricToken,
      });

      final data = response.data;
      if (data['success'] == true) {
        await _storage.write(key: 'auth_token', value: data['data']['token']);
      }
      return data;
    } on DioException {
      return null;
    }
  }

  // ¿Tiene biometric_token? → mostrar pantalla biométrica
  static Future<bool> hasBiometricToken() async {
    final token = await _storage.read(key: 'biometric_token');
    return token != null && token.isNotEmpty;
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  // Logout: solo revoca auth_token, CONSERVA biometric_token y device_id
  // → próxima apertura usa biometría (como WhatsApp)
  static Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
    ApiClient.reset();
  }

  // Limpia la sesión completa pero conserva el teléfono verificado por OTP
  // (verificarlo de nuevo cuesta un SMS).
  static Future<void> clearAll() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'biometric_token');
    await _storage.delete(key: 'device_id');
    ApiClient.reset();
  }

  // Teléfono verificado por OTP (Firebase), guardado localmente y enviado al login.
  static Future<String?> getVerifiedPhone() async {
    final phone = await _storage.read(key: verifiedPhoneKey);
    return (phone == null || phone.isEmpty) ? null : phone;
  }

  // app_AuthenticateUser compara solo dígitos (código de país + número, ej. 50683930395)
  static Future<void> saveVerifiedPhone(String phone) =>
      _storage.write(key: verifiedPhoneKey, value: phone.replaceAll(RegExp(r'\D'), ''));

  static Future<void> clearVerifiedPhone() =>
      _storage.delete(key: verifiedPhoneKey);
}
