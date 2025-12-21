import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'wallet_card.g.dart';

@HiveType(typeId: 30)
class WalletCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Ej: "Falabella Black"

  @HiveField(2)
  final String bankName; // Ej: "Banco Falabella"

  @HiveField(3)
  final String type; // 'credit', 'debit', 'vista'

  @HiveField(4)
  final int paymentDay; // Día de pago (solo para crédito)

  @HiveField(5)
  final double limit; // Cupo (opcional)

  @HiveField(6)
  final int colorValue;

  @HiveField(7)
  final double initialBalance; // Saldo inicial al crear la cuenta

  @HiveField(8) // [NUEVO CAMPO]
  final bool isFavorite;

  WalletCard({
    required this.id,
    required this.name,
    required this.bankName,
    required this.type,
    this.paymentDay = 1,
    this.limit = 0,
    required this.colorValue,
    this.initialBalance = 0.0,
    this.isFavorite = false, // Default false
  });

  bool get isCredit => type == 'credit';
  Color get color => Color(colorValue);
}
