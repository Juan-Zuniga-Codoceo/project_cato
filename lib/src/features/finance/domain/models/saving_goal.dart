class SavingGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount; // No es final, para poder actualizarla
  final DateTime? deadline;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
  });

  // Cálculo del progreso (0.0 a 1.0)
  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentAmount >= targetAmount;
}
