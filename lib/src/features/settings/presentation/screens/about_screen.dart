import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://synapsedev.cl');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ACERCA DE',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/project_cato_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              Text(
                'CATO: LIFE OS',
                style: GoogleFonts.spaceMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  'v1.0.0 (Stable)',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Divider(color: theme.dividerColor.withOpacity(0.2)),
              const SizedBox(height: 48),

              // Credits
              Text(
                'CREADO POR',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Synapse Dev Brand
              InkWell(
                onTap: _launchURL,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.code,
                        size: 40,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Synapse Dev',
                        style: GoogleFonts.spaceMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'synapsedev.cl',
                        style: GoogleFonts.inter(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Copyright
              Text(
                '© 2025 Synapse Dev. Todos los derechos reservados.\nArquitectura de Alto Rendimiento.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
