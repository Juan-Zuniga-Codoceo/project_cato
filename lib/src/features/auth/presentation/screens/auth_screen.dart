import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;
  String _statusMessage = 'Inicializando protocolos de seguridad...';

  @override
  void initState() {
    super.initState();
    // Retraso para asegurar que el contexto esté listo (como en commit 2392bc7)
    Future.delayed(const Duration(seconds: 1), _authenticate);
  }

  /// Autenticar usando el servicio
  Future<void> _authenticate() async {
    if (!mounted) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Escaneando biometría...';
    });

    final result = await _authService.authenticate(
      localizedReason: 'Identifícate para acceder a CATO OS',
      biometricOnly: true, // Restaurado a true como en versión anterior
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    if (result.success) {
      setState(() => _statusMessage = 'ACCESO CONCEDIDO');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Manejar diferentes tipos de error
      String errorMessage;
      switch (result.errorCode) {
        case AuthErrorCode.notSupported:
          errorMessage = 'DISPOSITIVO NO COMPATIBLE';
          break;
        case AuthErrorCode.notEnrolled:
          errorMessage = 'SIN BIOMETRÍA CONFIGURADA';
          break;
        case AuthErrorCode.lockedOut:
          errorMessage = 'BIOMETRÍA BLOQUEADA';
          break;
        case AuthErrorCode.userCanceled:
          errorMessage = 'AUTENTICACIÓN CANCELADA';
          break;
        case AuthErrorCode.authInProgress:
          errorMessage = 'AUTENTICACIÓN EN CURSO';
          break;
        default:
          errorMessage = 'ACCESO DENEGADO';
      }

      setState(() => _statusMessage = errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Diseño Cyberpunk
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1E1E1E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(
                      color: const Color(0xFFFFC107).withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC107).withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Color(0xFFFFC107),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'CATO: LIFE OS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 16,
                    letterSpacing: 3.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ACCESO RESTRINGIDO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceMono(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        _statusMessage.contains('DENEGADO') ||
                            _statusMessage.contains('Error')
                        ? Colors.redAccent
                        : (_statusMessage.contains('CONCEDIDO')
                              ? Colors.green
                              : Colors.grey),
                  ),
                ),
                const Spacer(),
                if (!_isAuthenticating)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.lock_open),
                      label: Text(
                        'AUTENTICAR MANUALMENTE',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFC107),
                        side: const BorderSide(color: Color(0xFFFFC107)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'ID: OPERADOR PRINCIPAL',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: Colors.white24,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
