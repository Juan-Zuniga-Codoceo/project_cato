import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

// Services
import 'storage_service.dart';

// Models
import '../../features/habits/domain/models/user_stats_model.dart';
import '../../features/habits/domain/models/habit_model.dart';
import '../../features/tasks/domain/models/task_model.dart';
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/finance/domain/models/budget.dart'; // Nuevo
import '../../features/finance/domain/models/saving_goal.dart'; // Nuevo
import '../../features/finance/domain/models/subscription.dart'; // Nuevo
import '../../features/garage/domain/models/vehicle.dart';
import '../../features/garage/domain/models/maintenance.dart';
import '../../features/garage/domain/models/vehicle_document.dart';
import '../../features/social/domain/models/person_model.dart';
import '../../features/academic/domain/models/subject_model.dart';
import '../../features/academic/domain/models/evaluation_model.dart';
import '../../features/academic/domain/models/academic_event_model.dart';
import '../../features/responsibility/domain/models/monthly_task_model.dart';
import '../../features/gamification/domain/models/badge_model.dart';

class BackupService {
  static Future<void> createBackup(BuildContext context) async {
    try {
      final storageService = Provider.of<StorageService>(
        context,
        listen: false,
      );

      // 1. Collect Data
      final backupData = <String, dynamic>{
        'version': 2, // Incrementamos versión por nuevos campos
        'timestamp': DateTime.now().toIso8601String(),
        'user_stats': _serializeUserStats(storageService.userStatsBox),
        'habits': _serializeHabits(storageService.habitBox),
        'tasks': _serializeTasks(storageService.taskBox),
        // Finance V2
        'transactions': _serializeTransactions(storageService.transactionBox),
        'categories': _serializeCategories(storageService.categoryBox),
        'budgets': _serializeBudgets(storageService.budgetBox),
        'savings': _serializeSavings(storageService.savingBox),
        'subscriptions': _serializeSubscriptions(
          storageService.subscriptionBox,
        ),
        // Other modules
        'vehicles': _serializeVehicles(storageService.vehicleBox),
        'maintenance': _serializeMaintenance(storageService.maintenanceBox),
        'social': _serializeSocial(storageService.socialBox),
        'academic_subjects': _serializeSubjects(storageService.academicBox),
        'academic_events': _serializeAcademicEvents(
          storageService.academicEventsBox,
        ),
        'responsibility': _serializeResponsibility(storageService.protocolsBox),
        'achievements': _serializeAchievements(storageService.achievementsBox),
      };

      // 2. Convert to JSON
      final jsonString = jsonEncode(backupData);

      // 3. Save to Temp File
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/cato_backup_$dateStr.json');
      await file.writeAsString(jsonString);

      // 4. Share
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Copia de Seguridad CATO - $dateStr');
    } catch (e) {
      print('Backup Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear respaldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> restoreBackup(BuildContext context) async {
    try {
      // 1. Pick File
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 2. Validate
      if (!data.containsKey('version') || !data.containsKey('user_stats')) {
        throw Exception('Archivo de respaldo inválido o corrupto.');
      }

      // 3. Clear Current Data
      final storageService = Provider.of<StorageService>(
        context,
        listen: false,
      );
      await storageService.clearAllData();

      // 4. Rehydrate Data
      await _restoreUserStats(storageService.userStatsBox, data['user_stats']);
      await _restoreHabits(storageService.habitBox, data['habits']);
      await _restoreTasks(storageService.taskBox, data['tasks']);

      // Finance V2 Restore
      if (data.containsKey('categories')) {
        await _restoreCategories(
          storageService.categoryBox,
          data['categories'],
        );
      }
      // Transactions depend on categories being loaded or embedded logic
      await _restoreTransactions(
        storageService.transactionBox,
        data['transactions'],
        storageService.categoryBox,
      );
      if (data.containsKey('budgets')) {
        await _restoreBudgets(storageService.budgetBox, data['budgets']);
      }
      if (data.containsKey('savings')) {
        await _restoreSavings(storageService.savingBox, data['savings']);
      }
      if (data.containsKey('subscriptions')) {
        await _restoreSubscriptions(
          storageService.subscriptionBox,
          data['subscriptions'],
        );
      }

      await _restoreVehicles(storageService.vehicleBox, data['vehicles']);
      await _restoreMaintenance(
        storageService.maintenanceBox,
        data['maintenance'],
      );
      await _restoreSocial(storageService.socialBox, data['social']);
      await _restoreSubjects(
        storageService.academicBox,
        data['academic_subjects'],
      );
      await _restoreAcademicEvents(
        storageService.academicEventsBox,
        data['academic_events'],
      );
      await _restoreResponsibility(
        storageService.protocolsBox,
        data['responsibility'],
      );
      await _restoreAchievements(
        storageService.achievementsBox,
        data['achievements'],
      );

      // Success handled by calling widget (SnackBar + Soft Restart)
    } catch (e) {
      print('Restore Error: $e');
      // Re-throw to let UI handle the error state
      throw Exception('Error al procesar el archivo: $e');
    }
  }

  // --- SERIALIZATION HELPERS ---

  static Map<String, dynamic> _serializeUserStats(Box<UserStatsModel> box) {
    final stats = box.get('current');
    if (stats == null) return {};
    return {
      'totalXp': stats.totalXp,
      'currentLevel': stats.currentLevel,
      'strengthXp': stats.strengthXp,
      'intellectXp': stats.intellectXp,
      'vitalityXp': stats.vitalityXp,
      'disciplineXp': stats.disciplineXp,
      'userName': stats.userName,
      'avatarPath': stats.avatarPath,
      'age': stats.age,
      'gender': stats.gender,
    };
  }

  static List<Map<String, dynamic>> _serializeHabits(Box<HabitModel> box) {
    return box.values
        .map(
          (h) => {
            'id': h.id,
            'title': h.title,
            'description': h.description,
            'targetFrequency': h.targetFrequency,
            'completedDates': h.completedDates
                .map((d) => d.toIso8601String())
                .toList(),
            'currentStreak': h.currentStreak,
            'bestStreak': h.bestStreak,
            'colorCode': h.colorCode,
            'createdAt': h.createdAt.toIso8601String(),
            'iconCode': h.iconCode,
            'attribute': h.attribute,
            'hasReminder': h.hasReminder,
            'reminderHour': h.reminderHour,
            'reminderMinute': h.reminderMinute,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeTasks(Box<TaskModel> box) {
    return box.values
        .map(
          (t) => {
            'id': t.id,
            'title': t.title,
            'description': t.description,
            'dueDate': t.dueDate.toIso8601String(),
            'isCompleted': t.isCompleted,
            'associatedCost': t.associatedCost,
            'isExpense': t.isExpense,
            'isIncome': t.isIncome,
            'categoryId': t.categoryId,
            'relatedTransactionId': t.relatedTransactionId,
          },
        )
        .toList();
  }

  // Finance Serialization
  static List<Map<String, dynamic>> _serializeTransactions(
    Box<Transaction> box,
  ) {
    return box.values
        .map(
          (t) => {
            'id': t.id,
            'title': t.title,
            'amount': t.amount,
            'isExpense': t.isExpense,
            'date': t.date.toIso8601String(),
            'category': {
              'id': t.category.id,
              'name': t.category.name,
              'iconCode': t.category.iconCode,
              'colorValue': t.category.colorValue,
              'isDefault': t.category.isDefault,
            },
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeCategories(
    Box<CategoryModel> box,
  ) {
    return box.values
        .map(
          (c) => {
            'id': c.id,
            'name': c.name,
            'iconCode': c.iconCode,
            'colorValue': c.colorValue,
            'isDefault': c.isDefault,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeBudgets(Box<Budget> box) {
    return box.values
        .map(
          (b) => {
            'id': b.id,
            'categoryId': b.categoryId,
            'limitAmount': b.limitAmount,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeSavings(Box<SavingGoal> box) {
    return box.values
        .map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'targetAmount': s.targetAmount,
            'currentAmount': s.currentAmount,
            'deadline': s.deadline?.toIso8601String(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeSubscriptions(
    Box<Subscription> box,
  ) {
    return box.values
        .map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'price': s.price,
            'paymentDay': s.paymentDay,
            'iconCode': s.iconCode,
            'colorValue': s.colorValue,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeVehicles(Box<Vehicle> box) {
    return box.values
        .map(
          (v) => {
            'id': v.id,
            'name': v.name,
            'brand': v.brand,
            'model': v.model,
            'year': v.year,
            'plate': v.plate,
            'imagePath': v.imagePath,
            'currentMileage': v.currentMileage,
            'documents': v.documents
                .map(
                  (d) => {
                    'id': d.id,
                    'name': d.name,
                    'imagePath': d.imagePath,
                    'dateAdded': d.dateAdded.toIso8601String(),
                    'expirationDate': d.expirationDate?.toIso8601String(),
                  },
                )
                .toList(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeMaintenance(
    Box<Maintenance> box,
  ) {
    return box.values
        .map(
          (m) => {
            'id': m.id,
            'vehicleId': m.vehicleId,
            'type': m.type,
            'cost': m.cost,
            'date': m.date.toIso8601String(),
            'mileage': m.mileage,
            'notes': m.notes,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeSocial(Box<PersonModel> box) {
    return box.values
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'relationship': p.relationship,
            'birthday': p.birthday?.toIso8601String(),
            'anniversary': p.anniversary?.toIso8601String(),
            'giftIdeas': p.giftIdeas,
            'lastContactDate': p.lastContactDate?.toIso8601String(),
            'contactFrequency': p.contactFrequency,
            'photoPath': p.photoPath,
            'phoneNumber': p.phoneNumber,
            'isFavorite': p.isFavorite,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeSubjects(Box<SubjectModel> box) {
    return box.values
        .map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'passingGrade': s.passingGrade,
            'targetGrade': s.targetGrade,
            'gradingScale': s.gradingScale,
            'totalClasses': s.totalClasses,
            'attendedClasses': s.attendedClasses,
            'minAttendance': s.minAttendance,
            'examWeight': s.examWeight,
            'exemptionGrade': s.exemptionGrade,
            'evaluations': s.evaluations
                .map(
                  (e) => {
                    'id': e.id,
                    'name': e.name,
                    'grade': e.grade,
                    'weight': e.weight,
                  },
                )
                .toList(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeAcademicEvents(
    Box<AcademicEventModel> box,
  ) {
    return box.values
        .map(
          (e) => {
            'id': e.id,
            'subjectId': e.subjectId,
            'title': e.title,
            'type': e.type,
            'date': e.date.toIso8601String(),
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeResponsibility(
    Box<MonthlyTaskModel> box,
  ) {
    return box.values
        .map(
          (t) => {
            'id': t.id,
            'title': t.title,
            'isCompleted': t.isCompleted,
            'difficulty': t.difficulty,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _serializeAchievements(
    Box<BadgeModel> box,
  ) {
    return box.values
        .map(
          (b) => {
            'id': b.id,
            'title': b.title,
            'description': b.description,
            'iconPath': b.iconPath,
            'isUnlocked': b.isUnlocked,
          },
        )
        .toList();
  }

  // --- RESTORATION HELPERS ---

  static Future<void> _restoreUserStats(
    Box<UserStatsModel> box,
    Map<String, dynamic>? data,
  ) async {
    if (data == null) return;
    final stats = UserStatsModel(
      totalXp: data['totalXp'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      strengthXp: data['strengthXp'] ?? 0,
      intellectXp: data['intellectXp'] ?? 0,
      vitalityXp: data['vitalityXp'] ?? 0,
      disciplineXp: data['disciplineXp'] ?? 0,
      userName: data['userName'] ?? 'Guerrero',
      avatarPath: data['avatarPath'] ?? 'assets/avatars/hero_1.jpg',
      age: data['age'],
      gender: data['gender'] ?? 'male',
    );
    await box.put('current', stats);
  }

  static Future<void> _restoreHabits(
    Box<HabitModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final habit = HabitModel(
        id: item['id'],
        title: item['title'],
        description: item['description'],
        targetFrequency: item['targetFrequency'],
        completedDates: (item['completedDates'] as List)
            .map((d) => DateTime.parse(d))
            .toList(),
        currentStreak: item['currentStreak'],
        bestStreak: item['bestStreak'],
        colorCode: item['colorCode'],
        createdAt: DateTime.parse(item['createdAt']),
        iconCode: item['iconCode'],
        attribute: item['attribute'],
        hasReminder: item['hasReminder'],
        reminderHour: item['reminderHour'],
        reminderMinute: item['reminderMinute'],
      );
      await box.put(habit.id, habit);
    }
  }

  static Future<void> _restoreTasks(
    Box<TaskModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final task = TaskModel(
        id: item['id'],
        title: item['title'],
        description: item['description'],
        dueDate: DateTime.parse(item['dueDate']),
        isCompleted: item['isCompleted'],
        associatedCost: item['associatedCost'],
        isExpense: item['isExpense'],
        isIncome: item['isIncome'],
        categoryId: item['categoryId'],
        relatedTransactionId: item['relatedTransactionId'],
      );
      await box.put(task.id, task);
    }
  }

  // Finance Restore Helpers
  static Future<void> _restoreCategories(
    Box<CategoryModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final cat = CategoryModel(
        id: item['id'],
        name: item['name'],
        iconCode: item['iconCode'],
        colorValue: item['colorValue'],
        isDefault: item['isDefault'],
      );
      await box.put(cat.id, cat);
    }
  }

  static Future<void> _restoreTransactions(
    Box<Transaction> box,
    List<dynamic>? list,
    Box<CategoryModel> catBox,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final catMap = item['category'];
      final category = CategoryModel(
        id: catMap['id'],
        name: catMap['name'],
        iconCode: catMap['iconCode'],
        colorValue: catMap['colorValue'],
        isDefault: catMap['isDefault'],
      );
      // Ensure category exists
      if (!catBox.containsKey(category.id)) {
        await catBox.put(category.id, category);
      }

      final transaction = Transaction(
        id: item['id'],
        title: item['title'],
        amount: item['amount'],
        isExpense: item['isExpense'],
        date: DateTime.parse(item['date']),
        category: category,
      );
      await box.put(transaction.id, transaction);
    }
  }

  static Future<void> _restoreBudgets(
    Box<Budget> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final budget = Budget(
        id: item['id'],
        categoryId: item['categoryId'],
        limitAmount: item['limitAmount'],
      );
      await box.put(budget.id, budget);
    }
  }

  static Future<void> _restoreSavings(
    Box<SavingGoal> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final saving = SavingGoal(
        id: item['id'],
        name: item['name'],
        targetAmount: item['targetAmount'],
        currentAmount: item['currentAmount'],
        deadline: item['deadline'] != null
            ? DateTime.parse(item['deadline'])
            : null,
      );
      await box.put(saving.id, saving);
    }
  }

  static Future<void> _restoreSubscriptions(
    Box<Subscription> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final sub = Subscription(
        id: item['id'],
        name: item['name'],
        price: item['price'],
        paymentDay: item['paymentDay'],
        iconCode: item['iconCode'],
        colorValue: item['colorValue'],
      );
      await box.put(sub.id, sub);
    }
  }

  static Future<void> _restoreVehicles(
    Box<Vehicle> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final documents =
          (item['documents'] as List?)
              ?.map(
                (d) => VehicleDocument(
                  id: d['id'],
                  name: d['name'],
                  imagePath: d['imagePath'],
                  dateAdded: DateTime.parse(d['dateAdded']),
                  expirationDate: d['expirationDate'] != null
                      ? DateTime.parse(d['expirationDate'])
                      : null,
                ),
              )
              .toList() ??
          [];

      final vehicle = Vehicle(
        id: item['id'],
        name: item['name'],
        brand: item['brand'],
        model: item['model'],
        year: item['year'],
        plate: item['plate'],
        imagePath: item['imagePath'],
        currentMileage: item['currentMileage'],
        documents: documents,
      );
      await box.put(vehicle.id, vehicle);
    }
  }

  static Future<void> _restoreMaintenance(
    Box<Maintenance> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final maintenance = Maintenance(
        id: item['id'],
        vehicleId: item['vehicleId'],
        type: item['type'],
        cost: item['cost'],
        date: DateTime.parse(item['date']),
        mileage: item['mileage'],
        notes: item['notes'],
      );
      await box.put(maintenance.id, maintenance);
    }
  }

  static Future<void> _restoreSocial(
    Box<PersonModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final person = PersonModel(
        id: item['id'],
        name: item['name'],
        relationship: item['relationship'],
        birthday: item['birthday'] != null
            ? DateTime.parse(item['birthday'])
            : null,
        anniversary: item['anniversary'] != null
            ? DateTime.parse(item['anniversary'])
            : null,
        giftIdeas: List<String>.from(item['giftIdeas'] ?? []),
        lastContactDate: item['lastContactDate'] != null
            ? DateTime.parse(item['lastContactDate'])
            : null,
        contactFrequency: item['contactFrequency'],
        photoPath: item['photoPath'],
        phoneNumber: item['phoneNumber'],
        isFavorite: item['isFavorite'] ?? false,
      );
      await box.put(person.id, person);
    }
  }

  static Future<void> _restoreSubjects(
    Box<SubjectModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final evaluations =
          (item['evaluations'] as List?)
              ?.map(
                (e) => EvaluationModel(
                  id: e['id'],
                  name: e['name'],
                  grade: e['grade'],
                  weight: e['weight'],
                ),
              )
              .toList() ??
          [];

      final subject = SubjectModel(
        id: item['id'],
        name: item['name'],
        evaluations: evaluations,
        passingGrade: item['passingGrade'],
        targetGrade: item['targetGrade'],
        gradingScale: item['gradingScale'],
        totalClasses: item['totalClasses'],
        attendedClasses: item['attendedClasses'],
        minAttendance: item['minAttendance'],
        examWeight: item['examWeight'],
        exemptionGrade: item['exemptionGrade'],
      );
      await box.put(subject.id, subject);
    }
  }

  static Future<void> _restoreAcademicEvents(
    Box<AcademicEventModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final event = AcademicEventModel(
        id: item['id'],
        subjectId: item['subjectId'],
        title: item['title'],
        type: item['type'],
        date: DateTime.parse(item['date']),
      );
      await box.put(event.id, event);
    }
  }

  static Future<void> _restoreResponsibility(
    Box<MonthlyTaskModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final task = MonthlyTaskModel(
        id: item['id'],
        title: item['title'],
        isCompleted: item['isCompleted'],
        difficulty: item['difficulty'] ?? 1,
      );
      await box.put(task.id, task);
    }
  }

  static Future<void> _restoreAchievements(
    Box<BadgeModel> box,
    List<dynamic>? list,
  ) async {
    if (list == null) return;
    for (var item in list) {
      final badge = BadgeModel(
        id: item['id'],
        title: item['title'],
        description: item['description'],
        iconPath: item['iconPath'],
        isUnlocked: item['isUnlocked'],
      );
      await box.put(badge.id, badge);
    }
  }
}
