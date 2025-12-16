import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reward_model.g.dart';

@HiveType(typeId: 21)
class RewardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double cost;

  @HiveField(3)
  final int iconCode;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  bool isRedeemed; // Si ya fue comprado

  @HiveField(6)
  DateTime? redeemedDate;

  @HiveField(7)
  final String? categoryId; // [NUEVO] Vinculación con Finanzas

  RewardModel({
    required this.id,
    required this.title,
    required this.cost,
    required this.iconCode,
    required this.colorValue,
    this.isRedeemed = false,
    this.redeemedDate,
    this.categoryId,
  });

  // Helpers UI
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
