import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/rating_service.dart';
import '../domain/models/monthly_task_model.dart';

class ResponsibilityProvider extends ChangeNotifier {
  final StorageService _storageService;

  ResponsibilityProvider(this._storageService);

  Box<MonthlyTaskModel> get _box => _storageService.protocolsBox;
  Box get _settingsBox => _storageService.settingsBox;

  List<MonthlyTaskModel> get tasks => _box.values.toList();

  Future<void> init() async {
    final now = DateTime.now();
    final currentMonth = now.month;
    final lastMonth = _settingsBox.get('lastProtocolMonth', defaultValue: -1);

    if (lastMonth != currentMonth) {
      // New month logic
      await _resetTasks();
      await _settingsBox.put('lastProtocolMonth', currentMonth);
    }

    if (_box.isEmpty) {
      await _loadDefaultTasks();
    }

    notifyListeners();
  }

  Future<void> _resetTasks() async {
    for (var task in _box.values) {
      final updatedTask = MonthlyTaskModel(
        id: task.id,
        title: task.title,
        isCompleted: false,
        difficulty: task.difficulty,
      );
      await _box.put(task.id, updatedTask);
    }
    notifyListeners();
  }

  Future<void> _loadDefaultTasks() async {
    final defaults = [
      MonthlyTaskModel(
        id: 'rent',
        title: 'Pagar Arriendo/Dividendo',
        difficulty: 3,
      ),
      MonthlyTaskModel(
        id: 'bills',
        title: 'Pagar Cuentas Básicas',
        difficulty: 1,
      ),
      MonthlyTaskModel(
        id: 'tires',
        title: 'Revisar Presión Neumáticos',
        difficulty: 1,
      ),
      MonthlyTaskModel(id: 'backup', title: 'Respaldo Digital', difficulty: 2),
      MonthlyTaskModel(
        id: 'cleaning',
        title: 'Limpieza Profunda',
        difficulty: 3,
      ),
    ];

    for (var task in defaults) {
      await _box.put(task.id, task);
    }
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final wasCompleted = isMonthCompleted;

      final updatedTask = MonthlyTaskModel(
        id: task.id,
        title: task.title,
        isCompleted: !task.isCompleted,
        difficulty: task.difficulty,
      );
      await _box.put(id, updatedTask);
      notifyListeners();

      // Check if month just got completed
      if (!wasCompleted && isMonthCompleted) {
        _monthJustCompleted = true;
      }
    }
  }

  // Helper field for rating trigger
  bool _monthJustCompleted = false;

  /// Check and show rating for Adult Mode completion (call from screen)
  Future<void> checkRatingForCompletion(BuildContext context) async {
    if (_monthJustCompleted) {
      await RatingService.trackAdultModeComplete(context);
      _monthJustCompleted = false;
    }
  }

  Future<void> addTask(String title, int difficulty) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newTask = MonthlyTaskModel(
      id: id,
      title: title,
      isCompleted: false,
      difficulty: difficulty,
    );
    await _box.put(id, newTask);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> updateTask(String id, String newTitle, int newDifficulty) async {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = MonthlyTaskModel(
        id: task.id,
        title: newTitle,
        isCompleted: task.isCompleted,
        difficulty: newDifficulty,
      );
      await _box.put(id, updatedTask);
      notifyListeners();
    }
  }

  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }

  bool get isMonthCompleted => progress == 1.0;

  int calculatePotentialXP() {
    int totalXP = 0;
    for (var task in tasks) {
      switch (task.difficulty) {
        case 1:
          totalXP += 10;
          break;
        case 2:
          totalXP += 25;
          break;
        case 3:
          totalXP += 50;
          break;
        default:
          totalXP += 10;
      }
    }
    return totalXP;
  }
}
