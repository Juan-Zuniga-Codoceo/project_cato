import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/finance_provider.dart';
import '../../core/providers/garage_provider.dart';
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/garage/domain/models/vehicle.dart';
import '../../features/garage/domain/models/maintenance.dart';
import '../../features/gamification/providers/achievement_provider.dart';
import '../../features/academic/providers/academic_provider.dart';
import '../../features/academic/domain/models/subject_model.dart';
import '../../features/academic/domain/models/evaluation_model.dart';
import '../services/home_widget_service.dart';
import '../../features/tasks/providers/task_provider.dart';
import '../../features/tasks/domain/models/task_model.dart';

class DataSeeder {
  static const Uuid _uuid = Uuid();

  static Future<void> seedData(BuildContext context) async {
    print('🌱 Iniciando inyección de datos de prueba...');

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final garageProvider = Provider.of<GarageProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(
      context,
      listen: false,
    );
    final academicProvider = Provider.of<AcademicProvider>(
      context,
      listen: false,
    );

    // 1. RPG Stats (Level 5)
    print('🎮 Inyectando datos RPG...');
    final stats = habitProvider.userStats;
    stats.currentLevel = 5;
    stats.totalXp = 450;
    stats.strengthXp = 200;
    stats.intellectXp = 150;
    stats.disciplineXp = 100;
    stats.vitalityXp = 0;
    stats.avatarPath = 'assets/avatars/hero_valkyrie.png';
    stats.save();
    // Force notify listeners to update UI
    // habitProvider.notifyListeners(); // Protected member, cannot call directly.

    // 2. Finance (Transactions)
    print('💰 Inyectando datos Financieros...');
    // Ensure categories exist or fetch them
    // We'll assume default categories are loaded.
    // Helper to find category by name or use first
    CategoryModel getCategory(String name) {
      try {
        return financeProvider.categories.firstWhere(
          (c) => c.name.toLowerCase().contains(name.toLowerCase()),
          orElse: () => financeProvider.categories.first,
        );
      } catch (e) {
        // Fallback if no categories
        return CategoryModel(
          id: 'default',
          name: 'General',
          iconCode: 0xe574,
          colorValue: 0xFF9E9E9E,
        );
      }
    }

    final salaryCat = getCategory('Salary'); // Or Ingresos
    final foodCat = getCategory('Food'); // Or Alimentación
    final transportCat = getCategory('Transport'); // Or Transporte
    final entertainmentCat = getCategory('Entertainment'); // Or Entretenimiento

    final transactions = [
      Transaction(
        id: _uuid.v4(),
        title: 'Sueldo Mensual',
        amount: 1500.0,
        isExpense: false,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: salaryCat,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Supermercado',
        amount: 300.0,
        isExpense: true,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: foodCat,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Gasolina',
        amount: 50.0,
        isExpense: true,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: transportCat,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Netflix',
        amount: 15.0,
        isExpense: true,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: entertainmentCat,
      ),
    ];

    for (var tx in transactions) {
      await financeProvider.addTransaction(tx);
    }

    // 3. Habits
    print('📅 Inyectando Hábitos...');
    habitProvider.createHabit(
      title: 'Leer 20 min',
      attribute: 'Disciplina',
      targetFrequency: 7,
      iconCode: 0xe0ef, // book
      colorCode: 0xFF9C27B0, // Purple
    );
    // We need to manually set streaks for the newly created habit, but createHabit doesn't return the ID easily without refactor.
    // However, we can just create it. Setting streaks would require finding it.
    // Let's try to find it by title to update streaks.
    try {
      final readingHabit = habitProvider.habits.firstWhere(
        (h) => h.title == 'Leer 20 min',
      );
      final updatedReading = readingHabit.copyWith(
        currentStreak: 5,
        bestStreak: 5,
      );
      habitProvider.updateHabit(updatedReading);
    } catch (e) {
      print('Error updating reading habit streak: $e');
    }

    habitProvider.createHabit(
      title: 'Gym',
      attribute: 'Fuerza',
      targetFrequency: 4,
      iconCode: 0xeb43, // fitness_center
      colorCode: 0xFFF44336, // Red
    );
    try {
      final gymHabit = habitProvider.habits.firstWhere((h) => h.title == 'Gym');
      final updatedGym = gymHabit.copyWith(currentStreak: 3, bestStreak: 3);
      habitProvider.updateHabit(updatedGym);
    } catch (e) {
      print('Error updating gym habit streak: $e');
    }

    // 4. Garage
    print('🚗 Inyectando Vehículo...');
    final vehicleId = _uuid.v4();
    final vehicle = Vehicle(
      id: vehicleId,
      name: 'Moto Cyber',
      brand: 'Yamaha',
      model: 'MT-09',
      year: 2024,
      currentMileage: 1500,
      plate: 'CYB-2077',
      imagePath: null, // No image for now
    );
    garageProvider.addVehicle(vehicle);

    final maintenance = Maintenance(
      id: _uuid.v4(),
      vehicleId: vehicleId,
      type: 'Cambio de Aceite',
      date: DateTime.now().subtract(const Duration(days: 30)),
      mileage: 1000,
      cost: 80.0,
      notes: 'Primer servicio',
    );
    garageProvider.addMaintenance(maintenance);

    // 7. Sync Widget
    print('🔄 Sincronizando Widget...');
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Buscar la tarea prioritaria real
    final topTask = taskProvider.tasksForToday.isNotEmpty
        ? taskProvider.tasksForToday.first.title
        : "Sin misiones activas";

    await HomeWidgetService.updateData(
      level: 5,
      xp: 450,
      maxXp: 500,
      topTask: topTask,
    );

    // 5. Academic (Scholar Badge)
    print('🎓 Inyectando datos Académicos...');
    if (academicProvider.subjects.isEmpty) {
      await academicProvider.addSubject(
        'Inteligencia Artificial',
        passingGrade: 4.0,
        targetGrade: 7.0,
        gradingScale: 0,
        examWeight: 0.3,
        exemptionGrade: 5.5,
      );

      // Add a good grade to the newly created subject
      // We need to find it first since addSubject doesn't return the ID
      try {
        final subject = academicProvider.subjects.firstWhere(
          (s) => s.name == 'Inteligencia Artificial',
        );
        await academicProvider.addEvaluation(subject.id, 'Parcial 1', 7.0, 0.5);
      } catch (e) {
        print('Error adding evaluation: $e');
      }
    }

    // 6. Check Achievements
    print('🏆 Verificando Logros...');
    achievementProvider.checkAchievements(
      userStats: habitProvider.userStats,
      balance: financeProvider.totalBalance,
      maxStreak: 5, // Based on seeded data
      academicAverage: 7.0,
      maintenanceCount: 1,
    );
  }
}
