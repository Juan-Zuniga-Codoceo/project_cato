import 'package:hive_flutter/hive_flutter.dart';
import '../../features/garage/domain/models/vehicle.dart';
import '../../features/garage/domain/models/vehicle_document.dart';
import '../../features/garage/domain/models/maintenance.dart';
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/finance/domain/models/budget.dart'; // Nuevo
import '../../features/finance/domain/models/saving_goal.dart'; // Nuevo
import '../../features/finance/domain/models/subscription.dart'; // Nuevo
import '../../features/tasks/domain/models/task_model.dart';
import '../../features/responsibility/domain/models/monthly_task_model.dart';
import '../../features/social/domain/models/person_model.dart';
import '../../features/academic/domain/models/subject_model.dart';
import '../../features/academic/domain/models/evaluation_model.dart';
import '../../features/academic/domain/models/academic_event_model.dart';
import '../../features/habits/domain/models/habit_model.dart';
import '../../features/habits/domain/models/user_stats_model.dart';
import '../../features/gamification/domain/models/badge_model.dart';
import '../../features/gamification/domain/models/reward_model.dart'; // [NUEVO]
import '../../features/finance/domain/models/wallet_card.dart';

class StorageService {
  // Box Names
  static const String vehicleBoxName = 'vehicles';
  static const String maintenanceBoxName = 'maintenance';
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String budgetBoxName = 'budgets'; // Nuevo
  static const String savingBoxName = 'savings'; // Nuevo
  static const String subscriptionBoxName = 'subscriptions'; // Nuevo
  static const String taskBoxName = 'tasks';
  static const String habitBoxName = 'habits';
  static const String userStatsBoxName = 'user_stats';
  static const String settingsBoxName = 'settings';
  static const String lifestyleBoxName = 'lifestyle';
  static const String protocolsBoxName = 'protocols';
  static const String socialBoxName = 'social';
  static const String academicBoxName = 'academic';
  static const String academicEventsBoxName = 'academic_events';
  static const String achievementsBoxName = 'achievements';
  static const String rewardsBoxName = 'rewards'; // [NUEVO]
  static const String walletBoxName = 'wallet_cards';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(VehicleAdapter());
    Hive.registerAdapter(VehicleDocumentAdapter());
    Hive.registerAdapter(MaintenanceAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Finance Adapters (Sprint 132)
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SavingGoalAdapter());
    Hive.registerAdapter(SubscriptionAdapter());

    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(UserStatsModelAdapter());
    Hive.registerAdapter(MonthlyTaskModelAdapter());
    Hive.registerAdapter(PersonModelAdapter());
    Hive.registerAdapter(EvaluationModelAdapter());
    Hive.registerAdapter(SubjectModelAdapter());
    Hive.registerAdapter(AcademicEventModelAdapter());
    Hive.registerAdapter(BadgeModelAdapter());
    Hive.registerAdapter(RewardModelAdapter()); // [NUEVO]
    Hive.registerAdapter(WalletCardAdapter());

    // Open Boxes
    await Hive.openBox<Vehicle>(vehicleBoxName);
    await Hive.openBox<Maintenance>(maintenanceBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);

    // Open Finance Boxes (Sprint 132)
    await Hive.openBox<Budget>(budgetBoxName);
    await Hive.openBox<SavingGoal>(savingBoxName);
    await Hive.openBox<Subscription>(subscriptionBoxName);

    await Hive.openBox<TaskModel>(taskBoxName);
    await Hive.openBox<HabitModel>(habitBoxName);
    await Hive.openBox<UserStatsModel>(userStatsBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(lifestyleBoxName);
    await Hive.openBox<MonthlyTaskModel>(protocolsBoxName);
    await Hive.openBox<PersonModel>(socialBoxName);
    await Hive.openBox<SubjectModel>(academicBoxName);
    await Hive.openBox<AcademicEventModel>(academicEventsBoxName);
    await Hive.openBox<BadgeModel>(achievementsBoxName);
    await Hive.openBox<RewardModel>(rewardsBoxName); // [NUEVO]
    await Hive.openBox<WalletCard>(walletBoxName);
  }

  // Getters
  Box<Vehicle> get vehicleBox => Hive.box<Vehicle>(vehicleBoxName);
  Box<Maintenance> get maintenanceBox =>
      Hive.box<Maintenance>(maintenanceBoxName);
  Box<Transaction> get transactionBox =>
      Hive.box<Transaction>(transactionBoxName);
  Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);

  // Finance Getters
  Box<Budget> get budgetBox => Hive.box<Budget>(budgetBoxName);
  Box<SavingGoal> get savingBox => Hive.box<SavingGoal>(savingBoxName);
  Box<Subscription> get subscriptionBox =>
      Hive.box<Subscription>(subscriptionBoxName);

  Box<TaskModel> get taskBox => Hive.box<TaskModel>(taskBoxName);
  Box<HabitModel> get habitBox => Hive.box<HabitModel>(habitBoxName);
  Box<UserStatsModel> get userStatsBox =>
      Hive.box<UserStatsModel>(userStatsBoxName);
  Box get settingsBox => Hive.box(settingsBoxName);
  Box get lifestyleBox => Hive.box(lifestyleBoxName);
  Box<MonthlyTaskModel> get protocolsBox =>
      Hive.box<MonthlyTaskModel>(protocolsBoxName);
  Box<PersonModel> get socialBox => Hive.box<PersonModel>(socialBoxName);
  Box<SubjectModel> get academicBox => Hive.box<SubjectModel>(academicBoxName);
  Box<AcademicEventModel> get academicEventsBox =>
      Hive.box<AcademicEventModel>(academicEventsBoxName);
  Box<BadgeModel> get achievementsBox =>
      Hive.box<BadgeModel>(achievementsBoxName);
  Box<RewardModel> get rewardsBox =>
      Hive.box<RewardModel>(rewardsBoxName); // [NUEVO]
  Box<WalletCard> get walletBox => Hive.box<WalletCard>(walletBoxName);

  Future<void> clearAllData() async {
    await vehicleBox.clear();
    await maintenanceBox.clear();
    await transactionBox.clear();
    await categoryBox.clear();

    // Clear Finance Boxes
    await budgetBox.clear();
    await savingBox.clear();
    await subscriptionBox.clear();

    await taskBox.clear();
    await habitBox.clear();
    await userStatsBox.clear();
    await settingsBox.clear();
    await lifestyleBox.clear();
    await protocolsBox.clear();
    await socialBox.clear();
    await academicBox.clear();
    await academicEventsBox.clear();
    await achievementsBox.clear();
    await rewardsBox.clear(); // [NUEVO]
    await walletBox.clear();
  }
}
