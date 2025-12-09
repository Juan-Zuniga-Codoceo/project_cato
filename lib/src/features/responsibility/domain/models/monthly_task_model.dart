import 'package:hive/hive.dart';

part 'monthly_task_model.g.dart';

@HiveType(typeId: 8)
class MonthlyTaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  final int difficulty;

  MonthlyTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.difficulty = 1,
  });
}
