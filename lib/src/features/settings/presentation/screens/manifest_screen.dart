import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManifestScreen extends StatelessWidget {
  const ManifestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'MANUAL DE OPERACIONES',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            context,
            'PROTOCOLO CATO',
            'Este sistema no es una simple agenda. Es un Sistema Operativo de Vida (Life OS) diseñado para maximizar tu eficiencia, disciplina y crecimiento personal. Trata cada módulo como un componente crítico de tu "hardware" humano.',
            Icons.settings_system_daydream,
            Colors.cyanAccent,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'RPG SYSTEM',
            'La vida es un juego de rol donde tú eres el protagonista. Tus hábitos diarios son las misiones que te otorgan experiencia (XP). \n\n- FUERZA: Entrenamiento físico y resistencia.\n- INTELECTO: Lectura, estudio y aprendizaje.\n- VITALIDAD: Salud, sueño y nutrición.\n- DISCIPLINA: Constancia y fuerza de voluntad.',
            Icons.shield,
            Colors.amberAccent,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'FINANZAS TÁCTICAS',
            'El dinero es munición. El control de flujo de caja es esencial para la supervivencia y la expansión. Registra cada movimiento. Mantén tus costos fijos (Suscripciones) bajo vigilancia constante.',
            Icons.attach_money,
            Colors.greenAccent,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'ESTOICISMO',
            '"No es lo que te pasa, sino cómo reaccionas". \n\nEl control interno es tu mayor arma. Enfócate solo en lo que puedes controlar. Acepta lo que no puedes cambiar (Amor Fati) y recuerda que tu tiempo es limitado (Memento Mori).',
            Icons.account_balance,
            Colors.purpleAccent,
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'CATO OS v1.0',
              style: GoogleFonts.spaceMono(
                color: theme.disabledColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.spaceMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
