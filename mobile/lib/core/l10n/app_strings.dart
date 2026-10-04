import 'dart:ui' show PlatformDispatcher;

abstract class AppStrings {
  const AppStrings();

  static AppStrings get current {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return code == 'es' ? const EsStrings() : const EnStrings();
  }

  // Shared
  String get appSubtitle;

  // Login
  String get username;
  String get password;
  String get signIn;
  String get enterCredentials;
  String get invalidCredentials;
  String get connectionError;
  String get serverError;

  // Phone verification
  String get verifyPhoneTitle;
  String get verifyPhoneSubtitle;
  String get phoneNumberLabel;
  String get phoneNumberHint;
  String get sendCode;
  String get invalidPhone;
  String get codeSentTo;
  String get smsCodeLabel;
  String get verifyCode;
  String get invalidCode;
  String get codeExpired;
  String get tooManyRequests;
  String get phoneVerifyFailed;
  String get changeNumber;
  String get verifiedPhone;
  String get resendCode;

  // Biometric
  String get noBiometricTitle;
  String get noBiometricSubtitle;
  String get setupBiometric;
  String get autoRetry;
  String get tryAgain;
  String get tapToAuth;
  String get useBiometrics;
  String get biometricReason;
  String get useCredentialsInstead;

  // Receipt
  String get registerExpense;
  String get loadError;
  String get retry;
  String get companyOptional;
  String get allCompanies;
  String get project;
  String get expenseType;
  String get amount;
  String get searching;
  String get exchangeRateLabel;
  String get expenseDate;
  String get description;
  String get takePhoto;
  String get changePhoto;
  String get selectProject;
  String get selectExpenseType;
  String get enterValidAmount;
  String get takeReceiptPhoto;
  String get expenseRegistered;
  String get registrationError;
  String get sendError;

  String descriptionLabel(int count) => '$description  ($count/255)';
  String exchangeRateWithCurrency(String currency) => '$exchangeRateLabel ($currency)';

  // My receipts
  String get myReceipts;
  String get noReceiptsYet;
  String get deleteReceipt;
  String get deleteReceiptConfirm;
  String get cancel;
  String get delete;
  String get receiptDeleted;
  String get deleteError;
}

class EsStrings extends AppStrings {
  const EsStrings();

  @override String get appSubtitle        => 'Registro de Gastos';
  @override String get username           => 'Usuario';
  @override String get password           => 'Contraseña';
  @override String get signIn             => 'Iniciar Sesión';
  @override String get enterCredentials   => 'Ingresa usuario y contraseña';
  @override String get invalidCredentials => 'Credenciales inválidas';
  @override String get connectionError    => 'Error de conexión';
  @override String get serverError        => 'Error del servidor. Intenta más tarde.';

  @override String get verifyPhoneTitle    => 'Verifica tu teléfono';
  @override String get verifyPhoneSubtitle => 'Te enviaremos un código por SMS para confirmar tu número.';
  @override String get phoneNumberLabel    => 'Número de teléfono';
  @override String get phoneNumberHint     => '+50688887777';
  @override String get sendCode            => 'Enviar código';
  @override String get invalidPhone        => 'Ingresa el número con código de país, por ejemplo +50688887777';
  @override String get codeSentTo          => 'Código enviado a';
  @override String get smsCodeLabel        => 'Código de 6 dígitos';
  @override String get verifyCode          => 'Verificar';
  @override String get invalidCode         => 'Código incorrecto';
  @override String get codeExpired         => 'El código expiró. Solicita uno nuevo.';
  @override String get tooManyRequests     => 'Demasiados intentos. Intenta más tarde.';
  @override String get phoneVerifyFailed   => 'No se pudo verificar el teléfono. Intenta de nuevo.';
  @override String get changeNumber        => 'Cambiar número';
  @override String get verifiedPhone       => 'Teléfono verificado';
  @override String get resendCode          => 'Reenviar código';

  @override String get noBiometricTitle    => 'No tienes huella configurada\nen tu dispositivo';
  @override String get noBiometricSubtitle => 'Configura tu huella o Face ID\npara acceder a la app';
  @override String get setupBiometric      => 'Configurar biometría';
  @override String get autoRetry           => 'Al volver a la app se intentará\nautomáticamente';
  @override String get tryAgain            => 'Inténtalo de nuevo';
  @override String get tapToAuth           => 'Toca para autenticarte';
  @override String get useBiometrics       => 'Usar biometría';
  @override String get biometricReason     => 'Confirma tu identidad para continuar';
  @override String get useCredentialsInstead => 'Usar usuario y contraseña';

  @override String get registerExpense   => 'Registrar Gasto';
  @override String get loadError         => 'Error al cargar datos. Verifica tu conexión.';
  @override String get retry             => 'Reintentar';
  @override String get companyOptional   => 'Empresa (opcional)';
  @override String get allCompanies      => 'Todas las empresas';
  @override String get project           => 'Proyecto';
  @override String get expenseType       => 'Tipo de Gasto';
  @override String get amount            => 'Monto';
  @override String get searching         => 'Buscando...';
  @override String get exchangeRateLabel => 'T. Cambio';
  @override String get expenseDate       => 'Fecha del gasto';
  @override String get description       => 'Descripción';
  @override String get takePhoto         => 'Tomar Foto\ndel Recibo';
  @override String get changePhoto       => 'Cambiar\nFoto';
  @override String get selectProject     => 'Selecciona un proyecto';
  @override String get selectExpenseType => 'Selecciona el tipo de gasto';
  @override String get enterValidAmount  => 'Ingresa un monto válido';
  @override String get takeReceiptPhoto  => 'Toma una foto del recibo';
  @override String get expenseRegistered => 'Gasto registrado correctamente';
  @override String get registrationError => 'Error al registrar';
  @override String get sendError         => 'Error al enviar. Intenta de nuevo.';

  @override String get myReceipts           => 'Mis Recibos';
  @override String get noReceiptsYet        => 'Todavía no has registrado gastos';
  @override String get deleteReceipt        => 'Eliminar recibo';
  @override String get deleteReceiptConfirm => '¿Seguro que quieres eliminar este recibo? Esta acción no se puede deshacer.';
  @override String get cancel               => 'Cancelar';
  @override String get delete               => 'Eliminar';
  @override String get receiptDeleted       => 'Recibo eliminado';
  @override String get deleteError          => 'Error al eliminar el recibo';
}

class EnStrings extends AppStrings {
  const EnStrings();

  @override String get appSubtitle        => 'Expense Tracker';
  @override String get username           => 'Username';
  @override String get password           => 'Password';
  @override String get signIn             => 'Sign In';
  @override String get enterCredentials   => 'Enter username and password';
  @override String get invalidCredentials => 'Invalid credentials';
  @override String get connectionError    => 'Connection error';
  @override String get serverError        => 'Server error. Please try again later.';

  @override String get verifyPhoneTitle    => 'Verify your phone';
  @override String get verifyPhoneSubtitle => "We'll send you an SMS code to confirm your number.";
  @override String get phoneNumberLabel    => 'Phone number';
  @override String get phoneNumberHint     => '+50688887777';
  @override String get sendCode            => 'Send code';
  @override String get invalidPhone        => 'Enter the number with country code, e.g. +50688887777';
  @override String get codeSentTo          => 'Code sent to';
  @override String get smsCodeLabel        => '6-digit code';
  @override String get verifyCode          => 'Verify';
  @override String get invalidCode         => 'Incorrect code';
  @override String get codeExpired         => 'The code expired. Request a new one.';
  @override String get tooManyRequests     => 'Too many attempts. Try again later.';
  @override String get phoneVerifyFailed   => 'Could not verify the phone. Please try again.';
  @override String get changeNumber        => 'Change number';
  @override String get verifiedPhone       => 'Verified phone';
  @override String get resendCode          => 'Resend code';

  @override String get noBiometricTitle    => 'No fingerprint configured\non your device';
  @override String get noBiometricSubtitle => 'Set up your fingerprint or Face ID\nto access the app';
  @override String get setupBiometric      => 'Set up biometrics';
  @override String get autoRetry           => 'The app will retry automatically\nwhen you return';
  @override String get tryAgain            => 'Try again';
  @override String get tapToAuth           => 'Tap to authenticate';
  @override String get useBiometrics       => 'Use biometrics';
  @override String get biometricReason     => 'Confirm your identity to continue';
  @override String get useCredentialsInstead => 'Use username and password';

  @override String get registerExpense   => 'Register Expense';
  @override String get loadError         => 'Error loading data. Check your connection.';
  @override String get retry             => 'Retry';
  @override String get companyOptional   => 'Company (optional)';
  @override String get allCompanies      => 'All companies';
  @override String get project           => 'Project';
  @override String get expenseType       => 'Expense Type';
  @override String get amount            => 'Amount';
  @override String get searching         => 'Searching...';
  @override String get exchangeRateLabel => 'Ex. Rate';
  @override String get expenseDate       => 'Expense date';
  @override String get description       => 'Description';
  @override String get takePhoto         => 'Take Photo\nof Receipt';
  @override String get changePhoto       => 'Change\nPhoto';
  @override String get selectProject     => 'Select a project';
  @override String get selectExpenseType => 'Select expense type';
  @override String get enterValidAmount  => 'Enter a valid amount';
  @override String get takeReceiptPhoto  => 'Take a photo of the receipt';
  @override String get expenseRegistered => 'Expense registered successfully';
  @override String get registrationError => 'Registration error';
  @override String get sendError         => 'Error sending. Please try again.';

  @override String get myReceipts           => 'My Receipts';
  @override String get noReceiptsYet        => "You haven't registered any expenses yet";
  @override String get deleteReceipt        => 'Delete receipt';
  @override String get deleteReceiptConfirm => 'Are you sure you want to delete this receipt? This cannot be undone.';
  @override String get cancel               => 'Cancel';
  @override String get delete               => 'Delete';
  @override String get receiptDeleted       => 'Receipt deleted';
  @override String get deleteError          => 'Error deleting receipt';
}
