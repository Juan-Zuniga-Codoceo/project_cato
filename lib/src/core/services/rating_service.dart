import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'storage_service.dart';

/// Servicio centralizado para gestionar solicitudes de valoración contextual
class RatingService {
  static const String _hasRatedKey = 'hasRated';
  static const String _dontShowAgainKey = 'dontShowRating';
  static const String _lastPromptDateKey = 'lastRatingPromptDate';
  static const String _significantEventsKey = 'significantEvents';
  static const String _appLaunchCountKey = 'appLaunchCount';
  static const String _firstLaunchDateKey = 'firstLaunchDate';

  // Criterios para mostrar
  static const int _minEventsRequired = 3;
  static const int _daysBetweenPrompts = 3;

  /// Incrementa el contador de lanzamientos de la app
  static Future<void> trackAppLaunch() async {
    final box = Hive.box(StorageService.settingsBoxName);

    // Registrar primera fecha de lanzamiento
    if (!box.containsKey(_firstLaunchDateKey)) {
      box.put(_firstLaunchDateKey, DateTime.now().toIso8601String());
    }

    int launchCount = box.get(_appLaunchCountKey, defaultValue: 0);
    box.put(_appLaunchCountKey, launchCount + 1);
  }

  /// Registra un evento significativo y retorna true si debe mostrar el prompt
  static Future<bool> trackSignificantEvent(
    BuildContext context, {
    required String eventName,
    String? customMessage,
  }) async {
    final box = Hive.box(StorageService.settingsBoxName);

    // Si ya calificó o eligió no volver a mostrar, salir
    if (box.get(_hasRatedKey, defaultValue: false) ||
        box.get(_dontShowAgainKey, defaultValue: false)) {
      return false;
    }

    // Incrementar contador de eventos
    int events = box.get(_significantEventsKey, defaultValue: 0);
    box.put(_significantEventsKey, events + 1);

    // Verificar si debe mostrar
    if (await _shouldShowPrompt()) {
      _showRatingDialog(context, customMessage: customMessage);
      return true;
    }

    return false;
  }

  /// Verifica si se deben cumplir los criterios para mostrar el prompt
  static Future<bool> _shouldShowPrompt() async {
    final box = Hive.box(StorageService.settingsBoxName);

    // Verificar flags
    if (box.get(_hasRatedKey, defaultValue: false)) return false;
    if (box.get(_dontShowAgainKey, defaultValue: false)) return false;

    // Verificar eventos significativos
    int events = box.get(_significantEventsKey, defaultValue: 0);
    if (events < _minEventsRequired) return false;

    // Verificar última vez que se mostró
    String? lastPromptStr = box.get(_lastPromptDateKey);
    if (lastPromptStr != null) {
      final lastPrompt = DateTime.parse(lastPromptStr);
      final daysSince = DateTime.now().difference(lastPrompt).inDays;
      if (daysSince < _daysBetweenPrompts) return false;
    }

    return true;
  }

  /// Muestra el dialog de valoración
  static void _showRatingDialog(BuildContext context, {String? customMessage}) {
    final box = Hive.box(StorageService.settingsBoxName);

    // Actualizar fecha del último prompt
    box.put(_lastPromptDateKey, DateTime.now().toIso8601String());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "¡PROTOCOLO COMPLETADO!",
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customMessage ?? "Has alcanzado un nuevo hito en CATO OS.",
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "Si la app te está ayudando a organizar tu vida, ¿nos regalarías 5 estrellas? ⭐",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              box.put(_dontShowAgainKey, true);
              Navigator.pop(ctx);
            },
            child: Text(
              "No volver a mostrar",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Más tarde"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              box.put(_hasRatedKey, true);
              Navigator.pop(ctx);
              _openPlayStore();
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text("VALORAR"),
          ),
        ],
      ),
    );
  }

  /// Abre la Play Store para valorar
  static Future<void> _openPlayStore() async {
    final url = Uri.parse("market://details?id=com.example.mens_lifestyle_app");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback a navegador si Play Store no está disponible
      final webUrl = Uri.parse(
        "https://play.google.com/store/apps/details?id=com.example.mens_lifestyle_app",
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// Eventos específicos rastreables

  static Future<void> trackLevelUp(BuildContext context, int newLevel) async {
    await trackSignificantEvent(
      context,
      eventName: 'level_up',
      customMessage:
          '¡Alcanzaste el nivel $newLevel! Tu progreso es impresionante.',
    );
  }

  static Future<void> trackStreak(BuildContext context, int days) async {
    if (days >= 7) {
      await trackSignificantEvent(
        context,
        eventName: 'streak_$days',
        customMessage: '¡$days días de racha! Tu disciplina es admirable.',
      );
    }
  }

  static Future<void> trackAdultModeComplete(BuildContext context) async {
    await trackSignificantEvent(
      context,
      eventName: 'adult_mode_complete',
      customMessage: '¡Completaste todas tus responsabilidades del mes!',
    );
  }

  static Future<void> trackCreditCardPaid(
    BuildContext context,
    String cardName,
  ) async {
    await trackSignificantEvent(
      context,
      eventName: 'credit_paid',
      customMessage:
          '¡Pagaste completamente $cardName! Excelente gestión financiera.',
    );
  }

  static Future<void> trackGoalReached(
    BuildContext context,
    String goalName,
  ) async {
    await trackSignificantEvent(
      context,
      eventName: 'goal_reached',
      customMessage: '¡Alcanzaste tu meta: $goalName!',
    );
  }

  static Future<void> trackFirstWeek(BuildContext context) async {
    final box = Hive.box(StorageService.settingsBoxName);
    String? firstLaunchStr = box.get(_firstLaunchDateKey);

    if (firstLaunchStr != null) {
      final firstLaunch = DateTime.parse(firstLaunchStr);
      final daysSince = DateTime.now().difference(firstLaunch).inDays;

      if (daysSince == 7) {
        await trackSignificantEvent(
          context,
          eventName: 'first_week',
          customMessage:
              '¡Una semana usando CATO OS! Gracias por confiar en nosotros.',
        );
      }
    }
  }

  /// Resetear para testing
  static Future<void> resetForTesting() async {
    final box = Hive.box(StorageService.settingsBoxName);
    box.delete(_hasRatedKey);
    box.delete(_dontShowAgainKey);
    box.delete(_lastPromptDateKey);
    box.delete(_significantEventsKey);
  }
}
