package com.example.synapse_health

import android.accounts.AccountManager
import android.accounts.AccountManagerCallback
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.synapse_health/google_accounts"
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {

                // Retorna todos los emails Google registrados en el dispositivo
                "getGoogleAccounts" -> {
                    try {
                        val am = AccountManager.get(this)
                        val accounts = am.getAccountsByType("com.google")
                        result.success(accounts.map { it.name })
                    } catch (e: Exception) {
                        result.error("ACCOUNT_ERROR", "No se pudieron obtener las cuentas: ${e.message}", null)
                    }
                }

                // Obtiene un token OAuth2 de Google directamente via AccountManager
                // (sin mostrar el selector nativo de Google si ya tiene sesión)
                "getGoogleAuthToken" -> {
                    val email = call.argument<String>("email")
                    if (email == null) {
                        result.error("INVALID_ARG", "Se requiere el parámetro email", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val am = AccountManager.get(this)
                        val account = am.getAccountsByType("com.google").firstOrNull { it.name == email }

                        if (account == null) {
                            result.error("NO_ACCOUNT", "Cuenta no encontrada en el dispositivo: $email", null)
                            return@setMethodCallHandler
                        }

                        val scope = "oauth2:https://www.googleapis.com/auth/userinfo.email " +
                                "https://www.googleapis.com/auth/userinfo.profile openid"

                        // Obtener token de forma asíncrona, usando la Activity para mostrar
                        // diálogo de autorización si es la primera vez
                        am.getAuthToken(
                            account,
                            scope,
                            null,
                            this@MainActivity,
                            AccountManagerCallback { future ->
                                try {
                                    val bundle = future.result
                                    val token = bundle.getString(AccountManager.KEY_AUTHTOKEN)
                                    mainHandler.post {
                                        if (token != null) {
                                            result.success(token)
                                        } else {
                                            result.error("NO_TOKEN", "AccountManager no devolvió token", null)
                                        }
                                    }
                                } catch (e: Exception) {
                                    mainHandler.post {
                                        result.error("TOKEN_ERROR", e.message, null)
                                    }
                                }
                            },
                            null
                        )
                    } catch (e: Exception) {
                        result.error("AUTH_ERROR", "Error al obtener token: ${e.message}", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
