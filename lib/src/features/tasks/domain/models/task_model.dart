import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 4)
class TaskModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime dueDate;
  @HiveField(4)
  final bool isCompleted;
  @HiveField(5)
  final double? associatedCost;
  @HiveField(6)
  final bool isExpense;
  @HiveField(7)
  final bool isIncome;
  @HiveField(8)
  final String? categoryId;
  @HiveField(9)
  final String? relatedTransactionId;
  @HiveField(10, defaultValue: 'Disciplina')
  final String attribute;
  @HiveField(11, defaultValue: 'Efectivo') // [NUEVO] Método de pago
  final String paymentMethod;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.associatedCost,
    this.isExpense = true,
    this.isIncome = false,
    this.categoryId,
    this.relatedTransactionId,
    this.attribute = 'Disciplina',
    this.paymentMethod = 'Efectivo', // Valor por defecto
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    double? associatedCost,
    bool? isExpense,
    bool? isIncome,
    String? categoryId,
    String? relatedTransactionId,
    String? attribute,
    String? paymentMethod,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      associatedCost: associatedCost ?? this.associatedCost,
      isExpense: isExpense ?? this.isExpense,
      isIncome: isIncome ?? this.isIncome,
      categoryId: categoryId ?? this.categoryId,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      attribute: attribute ?? this.attribute,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
