import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../domain/models/subject_model.dart';
import '../../domain/models/evaluation_model.dart';

class SubjectDetailScreen extends StatelessWidget {
  final SubjectModel subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    // Re-fetch subject from provider to ensure updates (e.g. after adding evaluation)
    final currentSubject = provider.subjects.firstWhere(
      (s) => s.id == subject.id,
      orElse: () => subject,
    );

    final currentAverage = provider.calculateCurrentAverage(currentSubject);
    final requiredGrade = provider.calculateRequiredGrade(currentSubject);
    final isPassing = currentAverage >= currentSubject.passingGrade;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSubject.name, style: GoogleFonts.spaceMono()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                _confirmDeleteSubject(context, provider, currentSubject),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDashboard(
            context,
            currentAverage,
            requiredGrade,
            isPassing,
            currentSubject,
            provider.getMaxGrade(currentSubject),
            provider.getMinGrade(currentSubject),
          ),
          _buildAttendanceCard(context, currentSubject), // Added here
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentSubject.evaluations.length,
              itemBuilder: (context, index) {
                final evaluation = currentSubject.evaluations[index];
                return Dismissible(
                  key: Key(evaluation.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    provider.deleteEvaluation(currentSubject.id, evaluation.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => _showEvaluationDialog(
                        context,
                        currentSubject,
                        evaluationToEdit: evaluation,
                      ),
                      title: Text(
                        evaluation.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Ponderación: ${(evaluation.weight * 100).toStringAsFixed(0)}%',
                      ),
                      trailing: Text(
                        evaluation.grade.toStringAsFixed(1),
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: evaluation.grade >= currentSubject.passingGrade
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEvaluationDialog(context, currentSubject),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, SubjectModel subject) {
    final double attendancePercentage = subject.totalClasses == 0
        ? 1.0
        : subject.attendedClasses / subject.totalClasses;

    final bool isPassingAttendance =
        attendancePercentage >= subject.minAttendance;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONTROL DE ASISTENCIA',
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircularProgressIndicator(
                  value: attendancePercentage,
                  backgroundColor: Colors.grey.shade800,
                  color: isPassingAttendance ? Colors.green : Colors.red,
                  strokeWidth: 8,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(attendancePercentage * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.spaceMono(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPassingAttendance ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      '${subject.attendedClasses} de ${subject.totalClasses} clases',
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AcademicProvider>().incrementAttendance(
                        subject.id,
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('ASISTÍ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AcademicProvider>().registerAbsence(
                        subject.id,
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('FALTÉ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    double currentAverage,
    double? requiredGrade,
    bool isPassing,
    SubjectModel subject,
    double maxGrade,
    double minGrade,
  ) {
    final theme = Theme.of(context);

    String predictionText;
    Color predictionColor;

    if (isPassing) {
      predictionText = "¡RAMO APROBADO! 🎉";
      predictionColor = Colors.green;
    } else if (requiredGrade == null) {
      // Should not happen if not passing, logic-wise
      predictionText = "Matemáticamente reprobado 💀";
      predictionColor = Colors.red;
    } else if (requiredGrade == 999.0) {
      // Sentinel value for impossible
      predictionText = "MATEMÁTICAMENTE REPROBADO 💀";
      predictionColor = Colors.red;
    } else if (requiredGrade > maxGrade) {
      // Fallback check
      predictionText = "MATEMÁTICAMENTE REPROBADO 💀";
      predictionColor = Colors.red;
    } else if (requiredGrade < minGrade) {
      predictionText =
          "¡Ya casi! Necesitas un ${minGrade.toStringAsFixed(1)} para cerrar.";
      predictionColor = Colors.green;
    } else {
      final remainingWeight =
          (1.0 -
              context.read<AcademicProvider>().calculateTotalWeight(subject)) *
          100;
      predictionText =
          "Necesitas nota ${requiredGrade.toStringAsFixed(1)} en el ${remainingWeight.toStringAsFixed(0)}% restante";
      predictionColor = Colors.amber;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          Text(
            'PROMEDIO ACTUAL',
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              letterSpacing: 2.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentAverage.toStringAsFixed(1),
            style: GoogleFonts.spaceMono(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isPassing ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'META: ${subject.passingGrade.toStringAsFixed(1)}',
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: predictionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: predictionColor.withOpacity(0.5)),
            ),
            child: Text(
              predictionText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: predictionColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEvaluationDialog(
    BuildContext context,
    SubjectModel subject, {
    EvaluationModel? evaluationToEdit,
  }) {
    final provider = context.read<AcademicProvider>();
    final maxGrade = provider.getMaxGrade(subject);
    final minGrade = provider.getMinGrade(subject);

    final isEditing = evaluationToEdit != null;
    final nameController = TextEditingController(
      text: isEditing ? evaluationToEdit.name : '',
    );
    final gradeController = TextEditingController(
      text: isEditing ? evaluationToEdit.grade.toString() : '',
    );
    final weightController = TextEditingController(
      text: isEditing ? (evaluationToEdit.weight * 100).toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEditing ? 'Editar Evaluación' : 'Nueva Evaluación',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej: Parcial 1)',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: gradeController,
                    decoration: InputDecoration(
                      labelText: 'Nota',
                      suffixText: '/ $maxGrade',
                      counterText: "",
                    ),
                    maxLength: 5, // Increased to allow 100.0
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Peso %',
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final gradeText = gradeController.text.replaceAll(',', '.');
              final weightText = weightController.text.replaceAll(',', '.');

              final grade = double.tryParse(gradeText);
              final weightPercent = double.tryParse(weightText);

              if (name.isEmpty || grade == null || weightPercent == null) {
                return;
              }

              // --- Validations ---
              if (grade > maxGrade) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ La nota no puede ser mayor a $maxGrade.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (grade < minGrade) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ La nota mínima es $minGrade'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (weightPercent > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ El porcentaje no puede superar 100%'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (weightPercent <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ El porcentaje debe ser mayor a 0%'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // --- Save ---
              if (isEditing) {
                provider.updateEvaluation(
                  subject.id,
                  EvaluationModel(
                    id: evaluationToEdit.id,
                    name: name,
                    grade: grade,
                    weight: weightPercent / 100.0,
                  ),
                );
              } else {
                provider.addEvaluation(
                  subject.id,
                  name,
                  grade,
                  weightPercent / 100.0,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(
    BuildContext context,
    AcademicProvider provider,
    SubjectModel subject,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Ramo?'),
        content: Text('Se borrará "${subject.name}" y todas sus notas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSubject(subject.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
