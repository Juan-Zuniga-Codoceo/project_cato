import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class CategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int iconCode;
  @HiveField(3)
  final int colorValue;
  @HiveField(4)
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Factory method to create default categories
  static List<CategoryModel> getDefaultCategories() {
    return [
      CategoryModel(
        id: 'cat_food',
        name: 'Comida',
        iconCode: Icons.fastfood.codePoint,
        colorValue: Colors.orange.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_transport',
        name: 'Transporte',
        iconCode: Icons.directions_car.codePoint,
        colorValue: Colors.blue.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_health',
        name: 'Salud',
        iconCode: Icons.local_hospital.codePoint,
        colorValue: Colors.red.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_shopping',
        name: 'Compras',
        iconCode: Icons.shopping_bag.codePoint,
        colorValue: Colors.purple.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_entertainment',
        name: 'Entretenimiento',
        iconCode: Icons.movie.codePoint,
        colorValue: Colors.pink.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_bills',
        name: 'Cuentas',
        iconCode: Icons.receipt_long.codePoint,
        colorValue: Colors.brown.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_salary',
        name: 'Sueldo',
        iconCode: Icons.attach_money.codePoint,
        colorValue: Colors.green.value,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_other',
        name: 'Otros',
        iconCode: Icons.category.codePoint,
        colorValue: Colors.grey.value,
        isDefault: true,
      ),
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
