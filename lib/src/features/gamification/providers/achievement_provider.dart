import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../habits/domain/models/user_stats_model.dart';
import '../domain/models/badge_model.dart';

class AchievementProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  AchievementProvider(this._storageService, this._notificationService) {
    _initializeBadges();
  }

  List<BadgeModel> get badges =>
      _storageService.achievementsBox.values.toList();

  void _initializeBadges() {
    if (_storageService.achievementsBox.isEmpty) {
      final defaultBadges = [
        BadgeModel(
          id: 'badge_level_5',
          title: 'Veterano',
          description: 'Alcanza el nivel 5 de Operador.',
          iconPath: 'assets/badges/badge_level_5.png',
        ),
        BadgeModel(
          id: 'badge_rich',
          title: 'Magnate',
          description: 'Acumula un saldo positivo de \$100,000.',
          iconPath: 'assets/badges/badge_rich.png',
        ),
        BadgeModel(
          id: 'badge_streak',
          title: 'Imparable',
          description: 'Mantén una racha de 7 días en cualquier hábito.',
          iconPath: 'assets/badges/badge_streak.png',
        ),
      ];

      final newBadges = [
        BadgeModel(
          id: 'badge_scholar',
          title: 'Erudito',
          description: 'Mantén un promedio académico superior a 6.0.',
          iconPath: 'assets/badges/badge_scholar.png',
        ),
        BadgeModel(
          id: 'badge_mechanic',
          title: 'Mecánico',
          description: 'Realiza al menos un mantenimiento a tu vehículo.',
          iconPath: 'assets/badges/badge_mechanic.png',
        ),
      ];

      // Add default badges
      for (var badge in defaultBadges) {
        if (!_storageService.achievementsBox.containsKey(badge.id)) {
          _storageService.achievementsBox.put(badge.id, badge);
        }
      }

      // Add new badges (ensure they are added if they don't exist)
      for (var badge in newBadges) {
        if (!_storageService.achievementsBox.containsKey(badge.id)) {
          _storageService.achievementsBox.put(badge.id, badge);
        }
      }
    } else {
      // Check for missing badges in existing box (migration support)
      final missingBadges = [
        BadgeModel(
          id: 'badge_scholar',
          title: 'Erudito',
          description: 'Mantén un promedio académico superior a 6.0.',
          iconPath: 'assets/badges/badge_scholar.png',
        ),
        BadgeModel(
          id: 'badge_mechanic',
          title: 'Mecánico',
          description: 'Realiza al menos un mantenimiento a tu vehículo.',
          iconPath: 'assets/badges/badge_mechanic.png',
        ),
      ];

      for (var badge in missingBadges) {
        if (!_storageService.achievementsBox.containsKey(badge.id)) {
          _storageService.achievementsBox.put(badge.id, badge);
        }
      }
    }
  }

  void checkAchievements({
    required UserStatsModel userStats,
    required double balance,
    required int maxStreak,
    required double academicAverage,
    required int maintenanceCount,
  }) {
    bool hasChanges = false;

    // Level 5 Badge
    if (userStats.currentLevel >= 5) {
      hasChanges |= _unlockBadge('badge_level_5');
    }

    // Rich Badge
    if (balance >= 100000) {
      hasChanges |= _unlockBadge('badge_rich');
    }

    // Streak Badge
    if (maxStreak >= 7) {
      hasChanges |= _unlockBadge('badge_streak');
    }

    // Scholar Badge
    if (academicAverage >= 6.0) {
      hasChanges |= _unlockBadge('badge_scholar');
    }

    // Mechanic Badge
    if (maintenanceCount >= 1) {
      hasChanges |= _unlockBadge('badge_mechanic');
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  bool _unlockBadge(String badgeId) {
    final badge = _storageService.achievementsBox.get(badgeId);
    if (badge != null && !badge.isUnlocked) {
      badge.isUnlocked = true;
      badge.save();

      _notificationService.showNotification(
        id: badgeId.hashCode,
        title: '¡LOGRO DESBLOQUEADO!',
        body: 'Has obtenido la medalla: ${badge.title}',
      );
      return true;
    }
    return false;
  }
}
