import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 6)
class HabitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int targetFrequency; // Days per week (7 = daily)

  @HiveField(4)
  final List<DateTime> completedDates;

  @HiveField(5)
  final int currentStreak;

  @HiveField(6)
  final int bestStreak;

  @HiveField(7)
  final int colorCode;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9, defaultValue: 0xe0b1)
  final int iconCode;

  @HiveField(10, defaultValue: 'Disciplina')
  final String attribute;

  @HiveField(11, defaultValue: false)
  final bool hasReminder;

  @HiveField(12)
  final int? reminderHour;

  @HiveField(13)
  final int? reminderMinute;

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    required this.targetFrequency,
    required this.completedDates,
    required this.currentStreak,
    required this.bestStreak,
    required this.colorCode,
    required this.createdAt,
    this.iconCode = 0xe0b1,
    this.attribute = 'Disciplina',
    this.hasReminder = false,
    this.reminderHour,
    this.reminderMinute,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    int? targetFrequency,
    List<DateTime>? completedDates,
    int? currentStreak,
    int? bestStreak,
    int? colorCode,
    DateTime? createdAt,
    int? iconCode,
    String? attribute,
    bool? hasReminder,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      colorCode: colorCode ?? this.colorCode,
      createdAt: createdAt ?? this.createdAt,
      iconCode: iconCode ?? this.iconCode,
      attribute: attribute ?? this.attribute,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
