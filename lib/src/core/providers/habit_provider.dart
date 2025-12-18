import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../features/habits/domain/models/habit_model.dart';
import '../../features/habits/domain/models/user_stats_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import '../services/home_widget_service.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

  @override
  void dispose() {
    _levelUpController.close();
    super.dispose();
  }

  HabitProvider(this._storageService, this._notificationService);

  UserStatsModel get userStats {
    if (_storageService.userStatsBox.isEmpty) {
      _storageService.userStatsBox.put(
        'current',
        UserStatsModel(totalXp: 0, currentLevel: 1),
      );
    }
    return _storageService.userStatsBox.get('current')!;
  }

  int get xpForNextLevel => userStats.currentLevel * 100;

  List<HabitModel> get habits =>
      _storageService.habitBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void createHabit({
    required String title,
    String? description,
    int targetFrequency = 7,
    int colorCode = 0xFF2196F3, // Default Blue
    int iconCode = 0xe0b1,
    String attribute = 'Disciplina',
    bool hasReminder = false,
    int? reminderHour,
    int? reminderMinute,
  }) {
    final newHabit = HabitModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetFrequency: targetFrequency,
      completedDates: [],
      currentStreak: 0,
      bestStreak: 0,
      colorCode: colorCode,
      createdAt: DateTime.now(),
      iconCode: iconCode,
      attribute: attribute,
      hasReminder: hasReminder,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );

    _storageService.habitBox.put(newHabit.id, newHabit);

    // Schedule notification if reminder is enabled
    if (hasReminder && reminderHour != null && reminderMinute != null) {
      _notificationService.scheduleDailyNotification(
        id: newHabit.id.hashCode,
        title: '\u23f0 Recordatorio: ${newHabit.title}',
        body: '\u00a1Es hora de completar tu h\u00e1bito!',
        time: TimeOfDay(hour: reminderHour, minute: reminderMinute),
      );
    }

    notifyListeners();
  }

  void updateHabit(HabitModel habit) {
    _storageService.habitBox.put(habit.id, habit);

    // Handle notification scheduling
    if (habit.hasReminder &&
        habit.reminderHour != null &&
        habit.reminderMinute != null) {
      // Schedule or update notification
      _notificationService.scheduleDailyNotification(
        id: habit.id.hashCode,
        title: '\u23f0 Recordatorio: ${habit.title}',
        body: '\u00a1Es hora de completar tu h\u00e1bito!',
        time: TimeOfDay(
          hour: habit.reminderHour!,
          minute: habit.reminderMinute!,
        ),
      );
    } else {
      // Cancel notification if reminder is disabled
      _notificationService.cancelNotification(habit.id.hashCode);
    }

    notifyListeners();
  }

  void deleteHabit(String id) {
    // Cancel notification before deleting
    _notificationService.cancelNotification(id.hashCode);
    _storageService.habitBox.delete(id);
    notifyListeners();
  }

  void toggleCompletion(String habitId, DateTime date) {
    final habit = _storageService.habitBox.get(habitId);
    if (habit != null) {
      // Normalize date to remove time
      final dateNormalized = DateTime(date.year, date.month, date.day);

      List<DateTime> newCompletedDates = List.from(habit.completedDates);

      // Check if date exists (ignoring time)
      final existingIndex = newCompletedDates.indexWhere(
        (d) =>
            d.year == dateNormalized.year &&
            d.month == dateNormalized.month &&
            d.day == dateNormalized.day,
      );

      final stats = userStats;
      final oldLevel = stats.currentLevel;

      if (existingIndex != -1) {
        // Undo completion
        newCompletedDates.removeAt(existingIndex);

        // Remove XP (prevent negative XP)
        stats.totalXp = (stats.totalXp - 10).clamp(0, double.infinity).toInt();

        // Remove attribute-specific XP
        switch (habit.attribute) {
          case 'Fuerza':
            stats.strengthXp = (stats.strengthXp - 10)
                .clamp(0, double.infinity)
                .toInt();
            break;
          case 'Intelecto':
            stats.intellectXp = (stats.intellectXp - 10)
                .clamp(0, double.infinity)
                .toInt();
            break;
          case 'Vitalidad':
            stats.vitalityXp = (stats.vitalityXp - 10)
                .clamp(0, double.infinity)
                .toInt();
            break;
          case 'Disciplina':
            stats.disciplineXp = (stats.disciplineXp - 10)
                .clamp(0, double.infinity)
                .toInt();
            break;
        }
      } else {
        // Add completion
        newCompletedDates.add(dateNormalized);

        // Add global XP
        stats.totalXp += 10;

        // Add attribute-specific XP
        switch (habit.attribute) {
          case 'Fuerza':
            stats.strengthXp += 10;
            break;
          case 'Intelecto':
            stats.intellectXp += 10;
            break;
          case 'Vitalidad':
            stats.vitalityXp += 10;
            break;
          case 'Disciplina':
            stats.disciplineXp += 10;
            break;
        }

        // Check Level Up
        if (stats.totalXp >= xpForNextLevel) {
          stats.currentLevel++;
        }
      }

      // Save stats
      stats.save();

      // Check for level up event
      if (stats.currentLevel > oldLevel) {
        _levelUpController.add(stats.currentLevel);
      }

      // Update avatar based on dominant archetype
      _updateArchetype();

      // Recalculate streaks
      final newStreak = _calculateStreak(newCompletedDates);
      final newBestStreak = newStreak > habit.bestStreak
          ? newStreak
          : habit.bestStreak;

      final updatedHabit = habit.copyWith(
        completedDates: newCompletedDates,
        currentStreak: newStreak,
        bestStreak: newBestStreak,
      );

      updateHabit(updatedHabit);
      // notifyListeners() is called inside updateHabit

      // Update Home Widget
      HomeWidgetService.updateData(
        level: stats.currentLevel,
        xp: stats.totalXp,
        maxXp: xpForNextLevel,
        topTask:
            'Tu Mejor Versión', // Default or fetch from TaskProvider if possible
      );
    }
  }

  int _calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    // Normalize dates and sort descending
    final dates =
        completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(
      const Duration(days: 1),
    );

    // Check if streak is active (completed today or yesterday)
    // If the last completion was before yesterday, streak is broken (0)
    if (dates.first.isBefore(yesterdayNormalized)) {
      return 0;
    }

    int currentStreak = 0;

    // Check if completed today
    if (dates.contains(todayNormalized)) {
      currentStreak++;
    }

    // Check consecutive days backwards starting from yesterday
    DateTime checkDate = yesterdayNormalized;
    while (dates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return currentStreak;
  }

  /// Update user's custom name
  void updateUserName(String newName) {
    final stats = userStats;
    stats.userName = newName;
    stats.save();
    notifyListeners();
  }

  /// Update user's profile (name, age, gender)
  void updateUserProfile({String? name, int? age, String? gender}) {
    final stats = userStats;
    if (name != null) stats.userName = name;
    if (age != null) stats.age = age;
    if (gender != null) stats.gender = gender;
    stats.save();
    notifyListeners();
  }

  /// Update user's gender
  void updateUserGender(String gender) {
    final stats = userStats;
    stats.gender = gender;
    stats.save();
    notifyListeners();
  }

  /// Update user's avatar
  void updateAvatar(String newPath) {
    final stats = userStats;
    stats.avatarPath = newPath;
    stats.save();
    notifyListeners();
  }

  /// Automatically update avatar based on dominant attribute
  void _updateArchetype() {
    final stats = userStats;

    // Determine the dominant attribute based on XP
    // Priority on ties: Fuerza > Disciplina > Intelecto > Vitalidad
    int maxXp = stats.strengthXp;
    String newAvatar = 'assets/avatars/hero_1.jpg'; // Fuerza (Guerrero)

    if (stats.disciplineXp > maxXp) {
      maxXp = stats.disciplineXp;
      newAvatar = 'assets/avatars/hero_2.jpg'; // Disciplina (Magnate/Rey)
    }

    if (stats.intellectXp > maxXp) {
      maxXp = stats.intellectXp;
      newAvatar = 'assets/avatars/hero_3.png'; // [FIX] Intelecto es PNG
    }

    if (stats.vitalityXp > maxXp) {
      maxXp = stats.vitalityXp;
      newAvatar = 'assets/avatars/hero_5.png'; // [FIX] Vitalidad es PNG
    }

    // Only update if the avatar has changed
    if (stats.avatarPath != newAvatar) {
      stats.avatarPath = newAvatar;
      stats.save();
      // No need to call notifyListeners() here as it will be called by updateHabit
    }
  }

  Future<void> factoryReset() async {
    await _storageService.clearAllData();
    // Reiniciar stats básicos para evitar errores de null en la UI inmediata
    _storageService.userStatsBox.put(
      'current',
      UserStatsModel(totalXp: 0, currentLevel: 1),
    );
    notifyListeners();
  }
}
