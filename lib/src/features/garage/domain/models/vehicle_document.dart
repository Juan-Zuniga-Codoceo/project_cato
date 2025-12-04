import 'package:hive/hive.dart';

part 'vehicle_document.g.dart';

@HiveType(typeId: 5)
class VehicleDocument {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imagePath;
  @HiveField(3)
  final DateTime dateAdded;

  VehicleDocument({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.dateAdded,
  });

  VehicleDocument copyWith({
    String? id,
    String? name,
    String? imagePath,
    DateTime? dateAdded,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
