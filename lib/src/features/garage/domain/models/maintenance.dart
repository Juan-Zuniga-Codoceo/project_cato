import 'package:hive/hive.dart';

part 'maintenance.g.dart';

@HiveType(typeId: 1)
class Maintenance {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String vehicleId;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final double mileage;
  @HiveField(5)
  final double cost;
  @HiveField(6)
  final String notes;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.notes,
  });
}
