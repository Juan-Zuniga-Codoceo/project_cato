import 'package:hive_flutter/hive_flutter.dart';
import '../../features/garage/domain/models/vehicle.dart';
import '../../features/garage/domain/models/vehicle_document.dart';
import '../../features/garage/domain/models/maintenance.dart';
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';

import '../../features/tasks/domain/models/task_model.dart';
import '../../features/habits/domain/models/habit_model.dart';
import '../../features/habits/domain/models/user_stats_model.dart';

class StorageService {
  static const String vehicleBoxName = 'vehicles';
  static const String maintenanceBoxName = 'maintenance';
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String taskBoxName = 'tasks';
  static const String habitBoxName = 'habits';
  static const String userStatsBoxName = 'user_stats';

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(VehicleAdapter());
    Hive.registerAdapter(VehicleDocumentAdapter());
    Hive.registerAdapter(MaintenanceAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(UserStatsModelAdapter());

    await Hive.openBox<Vehicle>(vehicleBoxName);
    await Hive.openBox<Maintenance>(maintenanceBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<TaskModel>(taskBoxName);
    await Hive.openBox<HabitModel>(habitBoxName);
    await Hive.openBox<UserStatsModel>(userStatsBoxName);
  }

  Box<Vehicle> get vehicleBox => Hive.box<Vehicle>(vehicleBoxName);
  Box<Maintenance> get maintenanceBox =>
      Hive.box<Maintenance>(maintenanceBoxName);
  Box<Transaction> get transactionBox =>
      Hive.box<Transaction>(transactionBoxName);
  Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);
  Box<TaskModel> get taskBox => Hive.box<TaskModel>(taskBoxName);
  Box<HabitModel> get habitBox => Hive.box<HabitModel>(habitBoxName);
  Box<UserStatsModel> get userStatsBox =>
      Hive.box<UserStatsModel>(userStatsBoxName);
}
