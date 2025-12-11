import 'package:hive/hive.dart';

part 'academic_event_model.g.dart';

@HiveType(typeId: 12)
class AcademicEventModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String type; // 'Examen', 'Entrega', 'Estudio', etc.

  @HiveField(4)
  final String? subjectId;

  AcademicEventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.subjectId,
  });
}
