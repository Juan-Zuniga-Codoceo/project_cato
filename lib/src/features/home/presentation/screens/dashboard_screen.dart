import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

// Providers
import '../../../../core/providers/habit_provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../core/providers/garage_provider.dart';
import '../../../academic/providers/academic_provider.dart';
import '../../../social/providers/social_provider.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../../responsibility/providers/responsibility_provider.dart';
import '../../../tasks/domain/models/task_model.dart';

// Widgets
import '../widgets/dashboard_widgets.dart';

// Screens
import '../../../finance/presentation/screens/transactions_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<String> _stoicQuotes = [
    "El obstáculo es el camino.",
    "No es lo que te pasa, sino cómo reaccionas.",
    "Memento Mori.",
    "Amor Fati.",
    "La mejor venganza es no ser como tu enemigo.",
    "Domina tu mente o ella te dominará a ti.",
    "Haz cada cosa como si fuera la última de tu vida.",
  ];

  static const List<String> _sideMissions = [
    "Beber un vaso de agua",
    "Leer 10 páginas",
    "Llamar a un familiar",
    "Hacer 10 flexiones",
    "Meditar 5 minutos",
    "Organizar el escritorio",
    "Revisar presupuesto semanal",
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'BUENOS DÍAS, OPERADOR';
    } else if (hour >= 12 && hour < 20) {
      return 'BUENAS TARDES, OPERADOR';
    } else {
      return 'BUENAS NOCHES, OPERADOR';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  void _checkOnboarding() {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final userStats = habitProvider.userStats;

    if (userStats.userName == 'Guerrero') {
      _showWelcomeDialog(habitProvider);
    }
  }

  void _showWelcomeDialog(HabitProvider provider) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedGender = 'male';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'IDENTIFICACIÓN REQUERIDA',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para calibrar el sistema, necesitamos tus datos, Operador.',
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '¿Cómo quieres que te llame?',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Identidad',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Operador (Masculino)'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Operadora (Femenino)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedGender = value;
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: '¿Cuál es tu edad?',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (int.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                provider.updateUserProfile(
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  gender: selectedGender,
                );
                Navigator.pop(context);
              }
            },
            child: Text(
              'INICIAR SISTEMA',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String description, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(description, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ENTENDIDO',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final userStats = habitProvider.userStats;
    final quote = _stoicQuotes[DateTime.now().day % _stoicQuotes.length];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        userStats.userName.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(userStats.avatarPath),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"$quote"',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Level Bar
              Row(
                children: [
                  Text(
                    'NIVEL ${userStats.currentLevel}',
                    style: GoogleFonts.spaceMono(
                      color: const Color(0xFFFFC107),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: userStats.totalXp / habitProvider.xpForNextLevel,
                        backgroundColor: theme.disabledColor.withOpacity(0.2),
                        color: const Color(0xFFFFC107),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- PRIORITY OBJECTIVE ---
              _buildPrioritySection(context),
              const SizedBox(height: 24),

              // --- SYSTEM MONITORS ---
              _buildSystemMonitors(context),
              const SizedBox(height: 24),

              // --- TIMELINE ---
              Text(
                'AGENDA TÁCTICA',
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildTimeline(context),
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySection(BuildContext context) {
    final academicProvider = context.watch<AcademicProvider>();
    final socialProvider = context.watch<SocialProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final garageProvider = context.watch<GarageProvider>();
    final theme = Theme.of(context);

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // 1. Academic: Exam Today/Tomorrow
    final upcomingExams = academicProvider.events.where((e) {
      final isExam =
          e.type.toLowerCase().contains('examen') ||
          e.type.toLowerCase().contains('certamen') ||
          e.type.toLowerCase().contains('prueba');
      final isSoon =
          academicProvider.isSameDay(e.date, now) ||
          academicProvider.isSameDay(e.date, tomorrow);
      return isExam && isSoon;
    }).toList();

    if (upcomingExams.isNotEmpty) {
      final exam = upcomingExams.first;
      final isToday = academicProvider.isSameDay(exam.date, now);
      return PriorityCard(
        title: exam.title,
        subtitle: isToday
            ? 'EXAMEN PROGRAMADO PARA HOY'
            : 'PREPARACIÓN INMINENTE PARA MAÑANA',
        icon: Icons.school,
        color: Colors.redAccent,
        actionLabel: 'REVISAR MATERIA',
        onAction: () {
          // Navigate to Academic
        },
      );
    }

    // 2. Social: Birthday Today
    final birthdayPerson = socialProvider.people.where((p) {
      if (p.birthday == null) return false;
      return p.birthday!.month == now.month && p.birthday!.day == now.day;
    }).firstOrNull;

    if (birthdayPerson != null) {
      return PriorityCard(
        title: 'CUMPLEAÑOS DE ${birthdayPerson.name.toUpperCase()}',
        subtitle:
            'CONTACTO REQUERIDO: ${birthdayPerson.relationship.toUpperCase()}',
        icon: Icons.cake,
        color: Colors.purpleAccent,
        actionLabel: 'CONTACTAR',
        onAction: () {
          // Navigate to Social
        },
      );
    }

    // 3. Task: Due Today (High Priority implicit by being due)
    final urgentTask = taskProvider.tasksForToday.firstOrNull;

    if (urgentTask != null) {
      return PriorityCard(
        title: urgentTask.title.toUpperCase(),
        subtitle: 'TAREA PENDIENTE PARA HOY',
        icon: Icons.check_circle_outline,
        color: Colors.amber,
        actionLabel: 'COMPLETAR',
        onAction: () {
          taskProvider.toggleTaskCompletion(urgentTask.id, context);
        },
      );
    }

    // 4. Garage: Maintenance Today
    final maintenance = garageProvider.maintenances.where((m) {
      return m.date.year == now.year &&
          m.date.month == now.month &&
          m.date.day == now.day;
    }).firstOrNull;

    if (maintenance != null) {
      return PriorityCard(
        title: maintenance.type.toUpperCase(),
        subtitle: 'MANTENIMIENTO VEHICULAR PROGRAMADO',
        icon: Icons.build,
        color: Colors.orange,
        actionLabel: 'VER GARAJE',
        onAction: () {
          // Navigate to Garage
        },
      );
    }

    // Default: Side Mission
    final randomMission = _sideMissions[now.day % _sideMissions.length];
    return PriorityCard(
      title: 'SISTEMAS ESTABLES',
      subtitle: 'MISIÓN SECUNDARIA: $randomMission',
      icon: Icons.shield,
      color: Colors.green,
      actionLabel: 'ACEPTAR MISIÓN',
      onAction: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'INTELIGENCIA TÁCTICA',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Deseas agregar la misión "$randomMission" a tu lista de objetivos de hoy?',
              style: GoogleFonts.inter(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              TextButton(
                onPressed: () {
                  // Create Task
                  final newTask = TaskModel(
                    id: DateTime.now().toString(),
                    title: randomMission,
                    description: 'Misión generada desde el Dashboard',
                    dueDate: DateTime.now(),
                    isCompleted: false,
                  );
                  taskProvider.addTask(newTask, context);
                  Navigator.pop(context); // Close dialog

                  // Navigate to Tasks
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TasksScreen(),
                    ),
                  );
                },
                child: Text(
                  'ACEPTAR',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemMonitors(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();
    final responsibilityProvider = context.watch<ResponsibilityProvider>();
    final habitProvider = context.watch<HabitProvider>();

    // Streak Logic
    int maxStreak = 0;
    if (habitProvider.habits.isNotEmpty) {
      maxStreak = habitProvider.habits.map((h) => h.currentStreak).reduce(max);
    }

    // Integrity Color Logic
    final integrity = responsibilityProvider.progress;
    Color integrityColor = Colors.blueAccent;
    if (integrity < 0.3) {
      integrityColor = Colors.redAccent;
    } else if (integrity < 0.7) {
      integrityColor = Colors.amber;
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showInfoDialog(
              'BALANCE FINANCIERO',
              'Capital disponible actual calculado desde el módulo de Finanzas.',
              Icons.attach_money,
            ),
            child: MetricTile(
              icon: Icons.attach_money,
              label: 'BALANCE',
              value: '\$${financeProvider.totalBalance.toInt()}',
              color: Colors.cyan,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showInfoDialog(
              'INTEGRIDAD DEL SISTEMA',
              'Porcentaje de cumplimiento de tus protocolos mensuales de responsabilidad (Adult Mode).',
              Icons.verified_user,
            ),
            child: MetricTile(
              icon: Icons.verified_user,
              label: 'INTEGRIDAD',
              value: '${(integrity * 100).toInt()}%',
              color: integrityColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showInfoDialog(
              'RACHA DE DISCIPLINA',
              'Tu mejor racha actual entre todos tus hábitos activos.',
              Icons.local_fire_department,
            ),
            child: MetricTile(
              icon: Icons.local_fire_department,
              label: 'RACHA',
              value: '$maxStreak DÍAS',
              color: Colors.orangeAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final academicProvider = context.watch<AcademicProvider>();
    final theme = Theme.of(context);

    final now = DateTime.now();
    final List<TimelineEntry> entries = [];

    // 1. Habits (Pending & Completed Today)
    for (var habit in habitProvider.habits) {
      final isCompleted = habit.completedDates.any(
        (d) => d.year == now.year && d.month == now.month && d.day == now.day,
      );

      DateTime itemTime;
      String timeStr = '--:--';

      if (habit.hasReminder && habit.reminderHour != null) {
        itemTime = DateTime(
          now.year,
          now.month,
          now.day,
          habit.reminderHour!,
          habit.reminderMinute ?? 0,
        );
        final hour = habit.reminderHour.toString().padLeft(2, '0');
        final minute = (habit.reminderMinute ?? 0).toString().padLeft(2, '0');
        timeStr = '$hour:$minute';
      } else {
        itemTime = DateTime(now.year, now.month, now.day, 8, 0);
      }

      entries.add(
        TimelineEntry(
          itemTime,
          TimelineItem(
            time: timeStr,
            title: habit.title,
            subtitle: habit.attribute,
            icon: IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
            color: Color(habit.colorCode),
            isCompleted: isCompleted,
            onToggle: () {
              habitProvider.toggleCompletion(habit.id, now);
            },
          ),
        ),
      );
    }

    // 2. Tasks (For Today)
    for (var task in taskProvider.tasksForToday) {
      final hour = task.dueDate.hour.toString().padLeft(2, '0');
      final minute = task.dueDate.minute.toString().padLeft(2, '0');

      entries.add(
        TimelineEntry(
          task.dueDate,
          TimelineItem(
            time: '$hour:$minute',
            title: task.title,
            subtitle: 'Tarea',
            icon: Icons.check_circle_outline,
            color: Colors.amber,
            isCompleted: task.isCompleted,
            onToggle: () {
              taskProvider.toggleTaskCompletion(task.id, context);
            },
          ),
        ),
      );
    }

    // 3. Academic Events (For Today)
    final events = academicProvider.getEventsForDay(now);
    for (var event in events) {
      final hour = event.date.hour.toString().padLeft(2, '0');
      final minute = event.date.minute.toString().padLeft(2, '0');

      entries.add(
        TimelineEntry(
          event.date,
          TimelineItem(
            time: '$hour:$minute',
            title: event.title,
            subtitle: event.type,
            icon: Icons.school,
            color: Colors.redAccent,
            isCompleted: false,
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIN ACTIVIDAD PROGRAMADA',
              style: GoogleFonts.spaceMono(color: theme.disabledColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_money, size: 16),
                  label: const Text('GASTO RÁPIDO'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TasksScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('NUEVA TAREA'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Sort by time
    entries.sort((a, b) => a.time.compareTo(b.time));

    return Column(children: entries.map((e) => e.widget).toList());
  }
}

class TimelineEntry {
  final DateTime time;
  final Widget widget;
  TimelineEntry(this.time, this.widget);
}
