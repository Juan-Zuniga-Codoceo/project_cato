import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 14)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double limitAmount;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
  });
}
