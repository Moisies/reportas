# ReportAs 2.0 – Mobile Flutter

App Flutter para registro de gastos con foto de recibo, biometría e integración con la API Laravel.

## Requisitos

- Flutter 3.x (null safety)
- Android SDK 21+ / iOS 12+

## Setup rápido

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Correr en emulador Android (apunta al servidor local)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# 3. Correr en iOS Simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# 4. Producción
flutter run --dart-define=API_BASE_URL=https://tu-servidor.com/api/v1
```

## Credenciales de prueba

Usar las mismas del sistema Rebexa:
- Usuario: tu LoginName en REBEXADEV
- Contraseña: tu PasswordSalt en REBEXADEV
- Teléfono: el PhoneNumber registrado en la tabla User

## Template base

**Prodctivo** (App_code/Prodctivo) — productividad y formularios  
Seleccionado por: layout de formularios sin scroll, pantalla de upload,
flujo de login/welcome adaptable al diseño de ReportAs.

## Pantallas

| Pantalla           | Archivo                              | Descripción                                |
|--------------------|--------------------------------------|--------------------------------------------|
| LoginScreen        | features/auth/login_screen.dart      | Login + auto-biométrico al abrir           |
| ReceiptScreen      | features/expense/receipt_screen.dart | Formulario principal, sin scroll           |
| PhotoPreviewScreen | features/expense/photo_preview_screen.dart | Preview con pinch-to-zoom            |

## Permisos requeridos

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (Info.plist)
```
NSCameraUsageDescription → Para fotografiar recibos
NSFaceIDUsageDescription → Para autenticarte de forma segura
```

## Notas

- El `phone_number` en el login debe coincidir con el registrado en la tabla `User` de REBEXADEV
- El biometric token se guarda en `flutter_secure_storage` (encriptado) tras el primer login
- En Android 10+, el número de teléfono no es accesible programáticamente — el usuario debe ingresarlo manualmente en el campo de login
- Las imágenes se comprimen al 85% de calidad antes de enviarse (max 1920px de ancho)
