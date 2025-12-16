import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 15)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final int paymentDay; // Día del mes (ej: 15)

  @HiveField(4)
  final int? iconCode; // Almacenamos el código del icono

  @HiveField(5)
  final int? colorValue; // Almacenamos el valor del color

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.paymentDay,
    this.iconCode,
    this.colorValue,
  });

  // Helpers para UI
  IconData get icon => iconCode != null
      ? IconData(iconCode!, fontFamily: 'MaterialIcons')
      : Icons.credit_card;

  Color get color => colorValue != null ? Color(colorValue!) : Colors.blue;

  // Alias para compatibilidad en cálculos
  double get amount => price;
}
