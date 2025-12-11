import 'package:hive/hive.dart';
import 'evaluation_model.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 11)
class SubjectModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<EvaluationModel> evaluations;

  @HiveField(3)
  final double passingGrade;

  @HiveField(4)
  final double? targetGrade;

  @HiveField(5, defaultValue: 0)
  final int gradingScale;

  @HiveField(6, defaultValue: 0)
  final int totalClasses;

  @HiveField(7, defaultValue: 0)
  final int attendedClasses;

  @HiveField(8, defaultValue: 0.75)
  final double minAttendance;

  @HiveField(9, defaultValue: 0.3)
  final double examWeight;

  @HiveField(10)
  final double? exemptionGrade;

  SubjectModel({
    required this.id,
    required this.name,
    required this.evaluations,
    this.passingGrade = 4.0,
    this.targetGrade,
    this.gradingScale = 0,
    this.totalClasses = 0,
    this.attendedClasses = 0,
    this.minAttendance = 0.75,
    this.examWeight = 0.3,
    this.exemptionGrade = 5.0,
  });
}
