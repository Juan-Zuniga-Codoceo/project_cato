import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatelessWidget {
  final VoidCallback onAuthenticate;
  final String statusMessage;
  final bool isAuthenticating;

  const AuthScreen({
    super.key,
    required this.onAuthenticate,
    required this.statusMessage,
    required this.isAuthenticating,
  });

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
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        statusMessage.contains('DENEGADO') ||
                            statusMessage.contains('Error') ||
                            statusMessage.contains('BLOQUEADA') ||
                            statusMessage.contains('CANCELADA')
                        ? Colors.redAccent
                        : (statusMessage.contains('CONCEDIDO')
                              ? Colors.green
                              : Colors.grey),
                  ),
                ),
                const Spacer(),
                if (!isAuthenticating)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onAuthenticate,
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
                  )
                else
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFC107),
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
