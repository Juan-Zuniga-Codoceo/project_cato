import 'package:hive/hive.dart';

part 'evaluation_model.g.dart';

@HiveType(typeId: 10)
class EvaluationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double grade;

  @HiveField(3)
  final double weight;

  EvaluationModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.weight,
  });
}
