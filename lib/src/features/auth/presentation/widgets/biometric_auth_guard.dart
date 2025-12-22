import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../screens/auth_screen.dart';

class BiometricAuthGuard extends StatefulWidget {
  final Widget child;

  const BiometricAuthGuard({super.key, required this.child});

  @override
  State<BiometricAuthGuard> createState() => _BiometricAuthGuardState();
}

class _BiometricAuthGuardState extends State<BiometricAuthGuard>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String _statusMessage = 'Inicializando protocolos de seguridad...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay de 1 segundo para asegurar que la Activity esté lista (evita onSaveInstanceState error)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _authenticate();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Si la app vuelve a primer plano y no estamos autenticados, reintentar
      if (!_isAuthenticated && !_isAuthenticating) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (!mounted || _isAuthenticated || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Escaneando biometría...';
    });

    try {
      final result = await _authService.authenticate(
        localizedReason: 'Identifícate para acceder a CATO OS',
        biometricOnly: true,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
          _statusMessage = 'ACCESO CONCEDIDO';
        });
      } else {
        setState(() {
          _isAuthenticating = false;
          _statusMessage = _mapErrorCodeToMessage(result.errorCode);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'ERROR DE SISTEMA: $e';
      });
    }
  }

  String _mapErrorCodeToMessage(AuthErrorCode? code) {
    if (code == null) return 'ACCESO DENEGADO';

    switch (code) {
      case AuthErrorCode.notSupported:
        return 'DISPOSITIVO NO COMPATIBLE';
      case AuthErrorCode.notEnrolled:
        return 'SIN BIOMETRÍA CONFIGURADA';
      case AuthErrorCode.lockedOut:
        return 'BIOMETRÍA BLOQUEADA';
      case AuthErrorCode.userCanceled:
        return 'AUTENTICACIÓN CANCELADA';
      case AuthErrorCode.authInProgress:
        return 'AUTENTICACIÓN EN CURSO';
      default:
        return 'ACCESO DENEGADO';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return AuthScreen(
      onAuthenticate: _authenticate,
      statusMessage: _statusMessage,
      isAuthenticating: _isAuthenticating,
    );
  }
}
