import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/biometric_lock_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/phone_verification_screen.dart';
import 'features/expense/receipt_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Sin config de Firebase la app abre igual; solo falla la verificación por OTP
    debugPrint('Firebase init failed: $e');
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: ReportAsApp()));
}

class ReportAsApp extends StatelessWidget {
  const ReportAsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReportAs 2.0',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primary),
        scaffoldBackgroundColor: AppConfig.background,
        useMaterial3: true,
      ),
      home: const _StartupRouter(),
      routes: {
        LoginScreen.id:              (_) => const LoginScreen(),
        PhoneVerificationScreen.id:  (_) => const PhoneVerificationScreen(),
        BiometricLockScreen.id:      (_) => const BiometricLockScreen(),
        ReceiptScreen.id:        (_) => const ReceiptScreen(),
      },
    );
  }
}

// Decide la pantalla inicial sin mostrar nada al usuario
class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final hasBio = await AuthService.hasBiometricToken();

    if (!mounted) return;

    if (hasBio) {
      // Ya se logueó antes → biometría (incluso después de cerrar sesión)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BiometricLockScreen()),
      );
    } else {
      // Primera vez → verificar teléfono por OTP y luego credenciales
      final hasPhone = await AuthService.getVerifiedPhone() != null;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => hasPhone ? const LoginScreen() : const PhoneVerificationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Splash mientras decide
    return Scaffold(
      backgroundColor: AppConfig.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 72, height: 72),
            SizedBox(height: 16),
            CircularProgressIndicator(color: AppConfig.primary),
          ],
        ),
      ),
    );
  }
}
