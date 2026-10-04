package com.rebexa.reportas

import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.rebexa.reportas/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBiometricSettings" -> { openBiometricSettings(); result.success(null) }
                    else                    -> result.notImplemented()
                }
            }
    }

    private fun openBiometricSettings() {
        val intent = when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                    putExtra(
                        Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                        android.hardware.biometrics.BiometricManager.Authenticators.BIOMETRIC_STRONG or
                        android.hardware.biometrics.BiometricManager.Authenticators.BIOMETRIC_WEAK
                    )
                }
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.P ->
                Intent(Settings.ACTION_FINGERPRINT_ENROLL)
            else ->
                Intent(Settings.ACTION_SECURITY_SETTINGS)
        }
        try { startActivity(intent) } catch (e: Exception) {
            startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
        }
    }
}
