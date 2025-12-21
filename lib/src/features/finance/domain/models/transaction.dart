import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final bool isExpense;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final CategoryModel category;
  @HiveField(6) // [NUEVO CAMPO]
  final String? paymentMethod;

  @HiveField(7, defaultValue: 1) // [NUEVO] Cantidad de cuotas
  final int installments;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
    this.paymentMethod, // Opcional
    this.installments = 1, // Default 1 (contado)
  });
}
