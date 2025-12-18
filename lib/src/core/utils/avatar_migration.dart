import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/habits/domain/models/user_stats_model.dart';

/// Script de migración ONE-TIME para actualizar avatares de .jpg a .png
class AvatarMigration {
  static Future<void> migrateAvatarPaths() async {
    try {
      final box = await Hive.openBox<UserStatsModel>('userStatsBox');
      final stats = box.get('current');

      if (stats != null) {
        String oldPath = stats.avatarPath;
        String newPath = oldPath;

        // Mapeo de rutas antiguas a nuevas
        if (oldPath == 'assets/avatars/hero_3.jpg') {
          newPath = 'assets/avatars/hero_3.png';
        } else if (oldPath == 'assets/avatars/hero_4.jpg') {
          newPath = 'assets/avatars/hero_4.png';
        } else if (oldPath == 'assets/avatars/hero_5.jpg') {
          newPath = 'assets/avatars/hero_5.png';
        }

        if (oldPath != newPath) {
          stats.avatarPath = newPath;
          await stats.save();
          debugPrint('✅ Avatar migrado: $oldPath → $newPath');
        } else {
          debugPrint('✅ Avatar ya está actualizado: $oldPath');
        }
      }
    } catch (e) {
      debugPrint('❌ Error en migración de avatar: $e');
    }
  }
}
