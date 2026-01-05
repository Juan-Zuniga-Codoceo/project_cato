import 'package:hive/hive.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 23)
class HealthRecordModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double cost;
  @HiveField(4)
  final String type; // 'Vacuna', 'Control', 'Cirugía', 'Medicamento', 'Otro'
  @HiveField(5)
  final String? transactionId; // Link to finance

  HealthRecordModel({
    required this.id,
    required this.date,
    required this.description,
    required this.cost,
    required this.type,
    this.transactionId,
  });
}

@HiveType(typeId: 22)
class PetModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final DateTime birthDate;
  @HiveField(3)
  final String? photoPath;
  @HiveField(4)
  final String? vetName;
  @HiveField(5)
  final List<HealthRecordModel> healthHistory;

  PetModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photoPath,
    this.vetName,
    this.healthHistory = const [],
  });

  PetModel copyWith({
    String? name,
    DateTime? birthDate,
    String? photoPath,
    String? vetName,
    List<HealthRecordModel>? healthHistory,
  }) {
    return PetModel(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      vetName: vetName ?? this.vetName,
      healthHistory: healthHistory ?? this.healthHistory,
    );
  }
}
