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
            // Removed hardcoded colors to allow Theme to handle it
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
    final exemptionGradeController = TextEditingController(text: '5.0');

    // We need state for the dropdown and slider, so we use a StatefulBuilder
    int selectedScale = 0; // Default to Chile
    double examWeight = 0.3; // Default 30%

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Nuevo Ramo',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          // Update default passing/exemption grade based on scale
                          switch (selectedScale) {
                            case 1:
                              passingGradeController.text = '6.0';
                              exemptionGradeController.text = '8.0';
                              break;
                            case 2:
                              passingGradeController.text = '60.0';
                              exemptionGradeController.text = '80.0';
                              break;
                            default:
                              passingGradeController.text = '4.0';
                              exemptionGradeController.text = '5.0';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passingGradeController,
                          decoration: const InputDecoration(
                            labelText: 'Nota Mínima',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: exemptionGradeController,
                          decoration: const InputDecoration(
                            labelText: 'Nota Eximición',
                            helperText: 'Opcional',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ponderación Examen',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: examWeight,
                          min: 0.0,
                          max: 0.6,
                          divisions: 12, // 5% steps
                          label: '${(examWeight * 100).toInt()}%',
                          onChanged: (value) {
                            setState(() {
                              examWeight = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        '${(examWeight * 100).toInt()}%',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Semestre: ${(100 - (examWeight * 100)).toInt()}%  |  Examen: ${(examWeight * 100).toInt()}%',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
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
                  final exemptionGrade = double.tryParse(
                    exemptionGradeController.text,
                  );

                  if (name.isNotEmpty) {
                    context.read<AcademicProvider>().addSubject(
                      name,
                      passingGrade: passingGrade,
                      gradingScale: selectedScale,
                      examWeight: examWeight,
                      exemptionGrade: exemptionGrade,
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
        Container(
          height: 140,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/module_academy.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Colors.transparent,
                ],
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(20),
            child: Text(
              "NEXO DE CONOCIMIENTO",
              style: GoogleFonts.spaceMono(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
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
    final criticalSubject = provider.criticalSubject;

    if (criticalSubject == null) {
      // Stable State (No critical subjects found)
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.teal.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'SISTEMA ESTABLE',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Todos los indicadores académicos en orden.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Critical State
    final currentAvg = provider.calculateCurrentAverage(criticalSubject);
    final maxGrade = provider.getMaxGrade(criticalSubject);
    final normalizedScore = maxGrade > 0 ? currentAvg / maxGrade : 0.0;
    final isCritical =
        normalizedScore < 0.6 || currentAvg < criticalSubject.passingGrade;

    if (!isCritical) {
      // Fallback if logic returns a subject but it's not actually critical
      // (Should match the "Stable" block above, or maybe a "Warning" block)
      // For now, let's reuse the stable block logic or just show nothing if not truly critical.
      // But criticalSubject logic returns the *worst*, even if it's 100%.
      // So we need to check if the worst is actually bad.
      // If worst is > 0.6 and passing, then we are stable.
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.teal.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'SISTEMA ESTABLE',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Todos los indicadores académicos en orden.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Truly Critical
    final percent = (normalizedScore * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'PRIORIDAD MÁXIMA',
                style: GoogleFonts.spaceMono(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            criticalSubject.name.toUpperCase(),
            style: GoogleFonts.blackOpsOne(
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Estás al $percent% de la meta. Peligro de reprobación.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubjectDetailScreen(subject: criticalSubject),
                ),
              );
            },
            icon: const Icon(Icons.visibility, color: Colors.red),
            label: const Text('VER ESTRATEGIA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
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
