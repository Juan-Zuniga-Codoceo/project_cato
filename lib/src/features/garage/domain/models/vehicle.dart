import 'package:hive/hive.dart';
import 'vehicle_document.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String brand;
  @HiveField(3)
  final String model;
  @HiveField(4)
  final int year;
  @HiveField(5)
  final double currentMileage;
  @HiveField(6)
  final String plate;
  @HiveField(7)
  final String? imagePath;
  @HiveField(8)
  final List<VehicleDocument> documents;

  Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.currentMileage,
    required this.plate,
    this.imagePath,
    List<VehicleDocument>? documents,
  }) : documents = documents ?? [];

  Vehicle copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    int? year,
    double? currentMileage,
    String? plate,
    String? imagePath,
    List<VehicleDocument>? documents,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      plate: plate ?? this.plate,
      imagePath: imagePath ?? this.imagePath,
      documents: documents ?? this.documents,
    );
  }
}
