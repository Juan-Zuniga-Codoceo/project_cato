import 'package:flutter/material.dart';

class Subscription {
  final String id;
  final String name;
  final double price;
  final int paymentDay; // Día del mes (ej: 15)
  final IconData? icon; // Opcional
  final Color? color; // Opcional

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.paymentDay,
    this.icon,
    this.color,
  });

  // Alias for compatibility with Transaction model in finance calculations
  double get amount => price;
}
