import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../auth/auth_service.dart';
import '../auth/phone_verification_screen.dart';
import '../expense/receipt_screen.dart';

// Solo se muestra la primera vez. Después siempre usa BiometricLockScreen.
class LoginScreen extends ConsumerStatefulWidget {
  static const id = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool   _loading     = false;
  bool   _obscure     = true;
  String _deviceId    = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initDevice();
  }

  Future<void> _initDevice() async {
    final phone = await AuthService.getVerifiedPhone();
    if (phone == null) {
      // Sin teléfono verificado por OTP no se puede iniciar sesión
      if (mounted) Navigator.pushReplacementNamed(context, PhoneVerificationScreen.id);
      return;
    }
    if (mounted) setState(() => _phoneNumber = phone);

    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      _deviceId = info.id;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      _deviceId = info.identifierForVendor ?? info.name;
    }
  }

  Future<void> _changePhone() async {
    await AuthService.clearVerifiedPhone();
    if (mounted) Navigator.pushReplacementNamed(context, PhoneVerificationScreen.id);
  }

  Future<void> _login() async {
    final s = AppStrings.current;
    if (_loginCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showSnack(s.enterCredentials, isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await AuthService.login(
        loginName:   _loginCtrl.text.trim(),
        password:    _passCtrl.text,
        phoneNumber: _phoneNumber,
        deviceId:    _deviceId,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, ReceiptScreen.id);
      } else {
        _showSnack(result['message'] ?? s.invalidCredentials, isError: true);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        _showSnack(data['message'].toString(), isError: true);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        _showSnack(s.connectionError, isError: true);
      } else {
        _showSnack(s.serverError, isError: true);
      }
    } catch (_) {
      _showSnack(s.connectionError, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppConfig.errorColor : AppConfig.successColor,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Image.asset('assets/images/logo.png', width: 80, height: 80),
                const SizedBox(height: 8),
                const Text('ReportAs 2.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppConfig.textPrimary)),
                Text(AppStrings.current.appSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                const SizedBox(height: 48),

                _buildField(controller: _loginCtrl, label: AppStrings.current.username,
                    icon: Icons.person_outline),
                const SizedBox(height: 14),

                _buildField(
                  controller: _passCtrl,
                  label: AppStrings.current.password,
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppConfig.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(AppStrings.current.signIn,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                if (_phoneNumber.isNotEmpty)
                  TextButton(
                    onPressed: _loading ? null : _changePhone,
                    child: Text(
                      '${AppStrings.current.verifiedPhone}: +$_phoneNumber · ${AppStrings.current.changeNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppConfig.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppConfig.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppConfig.primary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppConfig.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConfig.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConfig.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConfig.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
