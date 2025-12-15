import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 20)
class BadgeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  bool isUnlocked;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    this.isUnlocked = false,
  });
}
