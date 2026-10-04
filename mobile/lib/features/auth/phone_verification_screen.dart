import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import 'auth_service.dart';
import 'login_screen.dart';

// Verifica el teléfono por OTP (Firebase) antes del login. El número verificado
// queda guardado localmente y es el que se envía al SP de autenticación.
class PhoneVerificationScreen extends StatefulWidget {
  static const id = '/phone-verification';
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  static final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

  final _phoneCtrl = TextEditingController();
  final _codeCtrl  = TextEditingController();

  bool    _loading        = false;
  bool    _codeSent       = false;
  String  _phone          = '';
  String? _verificationId;
  int?    _resendToken;

  String _normalize(String raw) => raw.replaceAll(RegExp(r'[\s\-()]'), '');

  Future<void> _sendCode() async {
    final s = AppStrings.current;
    final phone = _normalize(_phoneCtrl.text);
    if (!_e164.hasMatch(phone)) {
      _showSnack(s.invalidPhone, isError: true);
      return;
    }
    setState(() { _loading = true; _phone = phone; });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        // Android puede leer el SMS solo y verificar sin que el usuario escriba el código
        verificationCompleted: (credential) => _signInWith(credential),
        verificationFailed: (e) {
          if (!mounted) return;
          setState(() => _loading = false);
          _showSnack(_messageFor(e), isError: true);
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken    = resendToken;
            _codeSent       = true;
            _loading        = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(s.phoneVerifyFailed, isError: true);
    }
  }

  Future<void> _verifyCode() async {
    final s = AppStrings.current;
    final code = _codeCtrl.text.trim();
    final verificationId = _verificationId;
    if (code.length != 6 || verificationId == null) {
      _showSnack(s.invalidCode, isError: true);
      return;
    }
    setState(() => _loading = true);
    await _signInWith(
      PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code),
    );
  }

  // Firebase solo se usa como prueba de que el usuario controla el número:
  // se cierra su sesión de inmediato, la app sigue autenticando contra el backend.
  Future<void> _signInWith(PhoneAuthCredential credential) async {
    final s = AppStrings.current;
    try {
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final verified = result.user?.phoneNumber ?? _phone;
      await FirebaseAuth.instance.signOut();
      await AuthService.saveVerifiedPhone(verified);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(_messageFor(e), isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(s.phoneVerifyFailed, isError: true);
    }
  }

  String _messageFor(FirebaseAuthException e) {
    final s = AppStrings.current;
    switch (e.code) {
      case 'invalid-phone-number':
        return s.invalidPhone;
      case 'invalid-verification-code':
        return s.invalidCode;
      case 'session-expired':
      case 'code-expired':
        return s.codeExpired;
      case 'too-many-requests':
      case 'quota-exceeded':
        return s.tooManyRequests;
      case 'network-request-failed':
        return s.connectionError;
      default:
        return s.phoneVerifyFailed;
    }
  }

  void _changeNumber() {
    setState(() {
      _codeSent       = false;
      _verificationId = null;
      _resendToken    = null;
      _codeCtrl.clear();
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppConfig.errorColor : AppConfig.successColor,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return Scaffold(
      backgroundColor: AppConfig.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', width: 80, height: 80),
                const SizedBox(height: 8),
                Text(s.verifyPhoneTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppConfig.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  _codeSent ? '${s.codeSentTo} $_phone' : s.verifyPhoneSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary),
                ),
                const SizedBox(height: 40),

                if (!_codeSent) ...[
                  _buildField(
                    controller: _phoneCtrl,
                    label: s.phoneNumberLabel,
                    hint: s.phoneNumberHint,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 28),
                  _buildButton(s.sendCode, _sendCode),
                ] else ...[
                  _buildField(
                    controller: _codeCtrl,
                    label: s.smsCodeLabel,
                    icon: Icons.sms_outlined,
                    keyboardType: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildButton(s.verifyCode, _verifyCode),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : _sendCode,
                    child: Text(s.resendCode,
                        style: const TextStyle(color: AppConfig.primary)),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _changeNumber,
                    child: Text(s.changeNumber,
                        style: const TextStyle(color: AppConfig.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: const TextStyle(color: AppConfig.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppConfig.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppConfig.primary, size: 20),
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
