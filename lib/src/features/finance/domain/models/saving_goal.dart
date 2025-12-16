import 'package:hive/hive.dart';

part 'saving_goal.g.dart';

@HiveType(typeId: 13)
class SavingGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  final DateTime? deadline;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
  });

  // Cálculo del progreso (0.0 a 1.0)
  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentAmount >= targetAmount;
}
