import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/config/app_config.dart';
import '../../core/l10n/app_strings.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../expense/receipt_screen.dart';

class BiometricLockScreen extends StatefulWidget {
  static const id = '/biometric-lock';
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.rebexa.reportas/device');
  final _localAuth = LocalAuthentication();

  bool _loading          = false;
  bool _failed           = false;
  bool _notEnrolled      = false; // dispositivo sin huella configurada

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndAuthenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Cuando el usuario vuelve de los ajustes de huella, reintenta automáticamente
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _notEnrolled) {
      _checkAndAuthenticate();
    }
  }

  Future<void> _checkAndAuthenticate() async {
    setState(() { _loading = true; _failed = false; _notEnrolled = false; });

    final isSupported = await _localAuth.isDeviceSupported();
    final hasEnrolled = await _localAuth.canCheckBiometrics;
    final available   = await _localAuth.getAvailableBiometrics();

    print('[BIO] isDeviceSupported=$isSupported');
    print('[BIO] canCheckBiometrics=$hasEnrolled');
    print('[BIO] availableBiometrics=$available');

    if (!isSupported) {
      print('[BIO] → no soporta biometria, va a login');
      await _clearAndGoLogin();
      return;
    }

    if (!hasEnrolled) {
      print('[BIO] → no tiene huella registrada, muestra setup');
      if (mounted) setState(() { _loading = false; _notEnrolled = true; });
      return;
    }

    print('[BIO] → tiene biometria, autenticando...');
    await _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() { _loading = true; _failed = false; });
    print('[BIO] authenticate() start');

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppStrings.current.biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      print('[BIO] authenticate() result=$authenticated');

      if (!authenticated) {
        setState(() { _loading = false; _failed = true; });
        return;
      }

      print('[BIO] calling biometricLogin API...');
      final result = await AuthService.biometricLogin();
      print('[BIO] biometricLogin result=$result');

      if (!mounted) return;

      if (result != null && result['success'] == true) {
        print('[BIO] → SUCCESS, going to ReceiptScreen');
        Navigator.pushReplacementNamed(context, ReceiptScreen.id);
      } else {
        print('[BIO] → FAILED token, going to LoginScreen');
        await _clearAndGoLogin();
      }
    } catch (e) {
      print('[BIO] EXCEPTION: $e');
      if (mounted) setState(() { _loading = false; _failed = true; });
    }
  }

  Future<void> _openBiometricSettings() async {
    try {
      await _channel.invokeMethod('openBiometricSettings');
    } catch (_) {}
  }

  Future<void> _clearAndGoLogin() async {
    await AuthService.clearAll();
    if (mounted) Navigator.pushReplacementNamed(context, LoginScreen.id);
  }

  // Login manual sin borrar biometric_token: la próxima apertura sigue ofreciendo huella
  void _goToLoginKeepingBiometric() {
    Navigator.pushReplacementNamed(context, LoginScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 88, height: 88),
                const SizedBox(height: 16),
                const Text('ReportAs 2.0',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
                        color: AppConfig.textPrimary)),
                Text(AppStrings.current.appSubtitle,
                    style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                const SizedBox(height: 64),

                if (_loading)
                  const CircularProgressIndicator(color: AppConfig.primary)

                else if (_notEnrolled)
                  _buildSetupBiometrics()

                else
                  _buildAuthPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pantalla cuando el dispositivo no tiene huella configurada
  Widget _buildSetupBiometrics() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fingerprint, size: 48, color: Colors.orange),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.current.noBiometricTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppConfig.textPrimary,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.current.noBiometricSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _openBiometricSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
            label: Text(AppStrings.current.setupBiometric,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.current.autoRetry,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _goToLoginKeepingBiometric,
          child: Text(AppStrings.current.useCredentialsInstead,
              style: const TextStyle(color: AppConfig.primary, fontSize: 14)),
        ),
      ],
    );
  }

  // Pantalla normal de autenticación biométrica
  Widget _buildAuthPrompt() {
    return Column(
      children: [
        GestureDetector(
          onTap: _authenticate,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: (_failed ? AppConfig.errorColor : AppConfig.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fingerprint, size: 48,
                color: _failed ? AppConfig.errorColor : AppConfig.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _failed ? AppStrings.current.tryAgain : AppStrings.current.tapToAuth,
          style: TextStyle(
              fontSize: 15,
              color: _failed ? AppConfig.errorColor : AppConfig.textSecondary),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _authenticate,
            icon: const Icon(Icons.fingerprint, color: Colors.white),
            label: Text(AppStrings.current.useBiometrics,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _goToLoginKeepingBiometric,
          child: Text(AppStrings.current.useCredentialsInstead,
              style: const TextStyle(color: AppConfig.primary, fontSize: 14)),
        ),
      ],
    );
  }
}
