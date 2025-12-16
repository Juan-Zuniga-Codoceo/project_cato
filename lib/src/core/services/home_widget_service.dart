import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../../features/tasks/providers/task_provider.dart';

class HomeWidgetService {
  static const String appWidgetProvider = 'CatoWidgetProvider';

  static Future<void> updateData({
    int? level,
    int? xp,
    int? maxXp,
    String? topTask,
  }) async {
    if (level != null && level != -1) {
      await HomeWidget.saveWidgetData<int>('level', level);
    }
    if (xp != null && xp != -1 && maxXp != null && maxXp != -1) {
      await HomeWidget.saveWidgetData<int>(
        'xp_percent',
        (xp / maxXp * 100).toInt(),
      );
    }
    if (topTask != null) {
      await HomeWidget.saveWidgetData<String>('top_task', topTask);
    }
    await HomeWidget.updateWidget(
      name: appWidgetProvider,
      androidName: appWidgetProvider,
    );
  }

  static Future<void> syncAll(BuildContext context) async {
    print('🔄 Sincronizando Widget...');
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final stats = habitProvider.userStats;
    // Obtener tareas pendientes de hoy
    final pendingTasks = taskProvider.tasksForToday
        .where((t) => !t.isCompleted)
        .toList();

    String mission = "Sin misiones activas";

    if (pendingTasks.isNotEmpty) {
      final firstTask = pendingTasks.first.title;
      final remainingCount = pendingTasks.length - 1;

      if (remainingCount > 0) {
        mission = "$firstTask (+$remainingCount)";
      } else {
        mission = firstTask;
      }
    }

    await updateData(
      level: stats.currentLevel,
      xp: stats.totalXp,
      maxXp: habitProvider.xpForNextLevel,
      topTask: mission,
    );
  }
}
