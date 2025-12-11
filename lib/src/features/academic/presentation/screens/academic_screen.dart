import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../domain/models/subject_model.dart';
import 'subject_detail_screen.dart';
import 'pomodoro_screen.dart';
import 'study_tips_screen.dart';
import 'academic_calendar_screen.dart';

class AcademicScreen extends StatelessWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ACADEMIA',
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ASIGNATURAS'),
              Tab(text: 'ESTUDIO'),
            ],
            indicatorColor: Colors.indigo,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(children: [_SubjectsTab(), _StudyTab()]),
        floatingActionButton: Builder(
          builder: (context) {
            // Only show FAB on the first tab (index 0)
            // Since TabController is inherited, we can check it?
            // Actually, DefaultTabController doesn't rebuild FAB automatically.
            // For simplicity, we'll keep the FAB always visible but only relevant for Subjects.
            // Or better, let's just leave it. It adds subjects.
            return FloatingActionButton(
              onPressed: () => _showAddSubjectDialog(context),
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final passingGradeController = TextEditingController(text: '4.0');

    // We need state for the dropdown, so we use a StatefulBuilder
    int selectedScale = 0; // Default to Chile

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Nuevo Ramo',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Ramo',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedScale,
                  decoration: const InputDecoration(
                    labelText: 'Escala de Notas',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Chile (1.0 - 7.0)'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Latam (0.0 - 10.0)'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Porcentaje (0 - 100)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedScale = value;
                        // Update default passing grade based on scale
                        switch (selectedScale) {
                          case 1:
                            passingGradeController.text = '6.0';
                            break;
                          case 2:
                            passingGradeController.text = '60.0';
                            break;
                          default:
                            passingGradeController.text = '4.0';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passingGradeController,
                  decoration: const InputDecoration(labelText: 'Nota Mínima'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  final passingGrade =
                      double.tryParse(passingGradeController.text) ?? 4.0;

                  if (name.isNotEmpty) {
                    context.read<AcademicProvider>().addSubject(
                      name,
                      passingGrade: passingGrade,
                      gradingScale: selectedScale,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('GUARDAR'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AcademicProvider>();
    final subjects = provider.subjects;

    return Column(
      children: [
        _buildSemesterSummary(context, provider),
        Expanded(
          child: subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ramos registrados',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return _SubjectCard(subject: subject);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSemesterSummary(
    BuildContext context,
    AcademicProvider provider,
  ) {
    final globalAverage = provider.globalAverage;
    final theme = Theme.of(context);

    String message;
    Color color;

    if (globalAverage >= 6.0) {
      message = "¡Excelente Semestre! 🚀";
      color = Colors.green;
    } else if (globalAverage >= 4.0) {
      message = "Vas bien, mantén el ritmo 👍";
      color = Colors.blue;
    } else if (globalAverage > 0) {
      message = "¡Cuidado! A subir esas notas ⚠️";
      color = Colors.orange;
    } else {
      message = "Sin notas registradas";
      color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          Text(
            'PROMEDIO GLOBAL',
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              letterSpacing: 2.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            globalAverage.toStringAsFixed(1),
            style: GoogleFonts.spaceMono(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyTab extends StatelessWidget {
  const _StudyTab();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          context,
          'Modo Enfoque',
          Icons.timer,
          Colors.cyan,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PomodoroScreen()),
          ),
        ),
        _buildMenuCard(
          context,
          'Técnicas',
          Icons.lightbulb,
          Colors.amber,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudyTipsScreen()),
          ),
        ),
        _buildMenuCard(
          context,
          'Calendario',
          Icons.calendar_month,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AcademicCalendarScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<AcademicProvider>();
    final currentAverage = provider.calculateCurrentAverage(subject);
    final isPassing = currentAverage >= subject.passingGrade;
    final maxGrade = provider.getMaxGrade(subject);
    final progress = (currentAverage / maxGrade).clamp(0.0, 1.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailScreen(subject: subject),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Promedio',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currentAverage.toStringAsFixed(1),
                    style: GoogleFonts.spaceMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isPassing ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ ${subject.passingGrade.toStringAsFixed(1)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPassing ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
