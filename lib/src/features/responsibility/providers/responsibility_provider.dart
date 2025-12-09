import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/storage_service.dart';
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
      );
      await _box.put(task.id, updatedTask);
    }
    notifyListeners();
  }

  Future<void> _loadDefaultTasks() async {
    final defaults = [
      MonthlyTaskModel(id: 'bills', title: 'Pagar cuentas'),
      MonthlyTaskModel(id: 'tires', title: 'Revisar neumáticos'),
      MonthlyTaskModel(id: 'backup', title: 'Respaldo digital'),
      MonthlyTaskModel(id: 'cleaning', title: 'Limpieza profunda'),
      MonthlyTaskModel(id: 'budget', title: 'Revisar presupuesto'),
    ];

    for (var task in defaults) {
      await _box.put(task.id, task);
    }
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = MonthlyTaskModel(
        id: task.id,
        title: task.title,
        isCompleted: !task.isCompleted,
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
}
