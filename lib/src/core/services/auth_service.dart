import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// 🔐 SERVICIO DE AUTENTICACIÓN BIOMÉTRICA
///
/// Este servicio encapsula toda la lógica de autenticación biométrica
/// para aislarla del resto de la aplicación.
///
/// ⚠️ IMPORTANTE: No modificar este archivo en refactorizaciones generales
/// de UI o cambios de diseño. Solo modificar si hay cambios en la API
/// de local_auth o requerimientos de seguridad.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo soporta biometría
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('❌ Error verificando biometría: $e');
      return false;
    }
  }

  /// Verifica si el dispositivo está habilitado para autenticación
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('❌ Error verificando soporte del dispositivo: $e');
      return false;
    }
  }

  /// Obtiene los tipos de biometría disponibles en el dispositivo
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('❌ Error obteniendo biometrías: $e');
      return [];
    }
  }

  /// Autentica al usuario usando biometría o PIN del dispositivo
  ///
  /// [localizedReason]: Mensaje que se mostrará al usuario
  /// [biometricOnly]: Si solo permitir biometría (no PIN/patrón)
  ///
  /// Returns: AuthenticationResult con el estado y mensaje
  Future<AuthenticationResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    // 1. Verificar si el dispositivo soporta biometría
    final isSupported = await isDeviceSupported();
    if (!isSupported) {
      return AuthenticationResult(
        success: false,
        message: 'Este dispositivo no soporta autenticación biométrica',
        errorCode: AuthErrorCode.notSupported,
      );
    }

    // 2. Verificar si la biometría está disponible
    final canCheck = await canCheckBiometrics();
    if (!canCheck && biometricOnly) {
      return AuthenticationResult(
        success: false,
        message: 'No hay biometría configurada en este dispositivo',
        errorCode: AuthErrorCode.notEnrolled,
      );
    }

    // 3. Intentar autenticación (Sintaxis local_auth 3.0.0 - SOLO parámetros soportados)
    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        return AuthenticationResult(
          success: true,
          message: 'Autenticación exitosa',
        );
      } else {
        return AuthenticationResult(
          success: false,
          message: 'Autenticación cancelada por el usuario',
          errorCode: AuthErrorCode.userCanceled,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Error en autenticación: $e');

      // Manejar errores específicos usando códigos de PlatformException
      String message;
      AuthErrorCode errorCode;

      switch (e.code) {
        case 'NotAvailable':
          message = 'Biometría no disponible en este momento';
          errorCode = AuthErrorCode.notAvailable;
          break;
        case 'NotEnrolled':
          message = 'No hay huellas dactilares registradas';
          errorCode = AuthErrorCode.notEnrolled;
          break;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          message = 'Biometría bloqueada. Usa PIN del dispositivo';
          errorCode = AuthErrorCode.lockedOut;
          break;
        case 'PasscodeNotSet':
          message = 'No hay PIN configurado en el dispositivo';
          errorCode = AuthErrorCode.notEnrolled;
          break;
        case 'authInProgress':
          // Ya hay una autenticación en progreso, ignorar
          message = 'Autenticación ya en curso';
          errorCode = AuthErrorCode.authInProgress;
          break;
        default:
          message = 'Error de autenticación: ${e.message ?? "desconocido"}';
          errorCode = AuthErrorCode.unknown;
      }

      return AuthenticationResult(
        success: false,
        message: message,
        errorCode: errorCode,
      );
    } catch (e) {
      debugPrint('❌ Error inesperado en autenticación: $e');
      return AuthenticationResult(
        success: false,
        message: 'Error de autenticación. Intenta nuevamente',
        errorCode: AuthErrorCode.unknown,
      );
    }
  }

  /// Cancela cualquier autenticación en progreso
  Future<bool> stopAuthentication() async {
    try {
      return await _auth.stopAuthentication();
    } catch (e) {
      debugPrint('❌ Error deteniendo autenticación: $e');
      return false;
    }
  }
}

/// Resultado de la autenticación
class AuthenticationResult {
  final bool success;
  final String message;
  final AuthErrorCode? errorCode;

  AuthenticationResult({
    required this.success,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => 'AuthResult(success: $success, message: $message)';
}

/// Códigos de error personalizados
enum AuthErrorCode {
  notSupported,
  notEnrolled,
  notAvailable,
  lockedOut,
  userCanceled,
  authInProgress,
  unknown,
}
