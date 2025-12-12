import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../providers/responsibility_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/monthly_task_model.dart';

class AdultModeScreen extends StatefulWidget {
  const AdultModeScreen({super.key});

  @override
  State<AdultModeScreen> createState() => _AdultModeScreenState();
}

class _AdultModeScreenState extends State<AdultModeScreen> {
  late ConfettiController _confettiController;
  bool _hasShownHint = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkCompletion(ResponsibilityProvider provider) {
    if (provider.isMonthCompleted) {
      _confettiController.play();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildCompletionDialog(provider),
      );
    }
  }

  Widget _buildCompletionDialog(ResponsibilityProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.green, Colors.blue, Colors.amber],
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SISTEMA ESTABILIZADO',
                  style: GoogleFonts.spaceMono(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '+${provider.calculatePotentialXP()} XP',
                  style: GoogleFonts.spaceMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('CONTINUAR'),
                ),
              ],
            ),
          ),
        ),
      ],
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
    final provider = Provider.of<ResponsibilityProvider>(context);
    final progress = provider.progress;

    String statusText;
    Color statusColor;
    if (progress < 0.3) {
      statusText = 'CRÍTICO';
      statusColor = AppTheme.danger;
    } else if (progress < 0.7) {
      statusText = 'ESTABLE';
      statusColor = Colors.amber;
    } else {
      statusText = 'ÓPTIMO';
      statusColor = Colors.green;
    }

    // ... (Dialog functions remain the same, omitting for brevity in this replacement block if possible, but since I'm replacing the whole build method structure, I should probably keep them or assume they are outside. Wait, the dialog functions are inside build in the original code. I should keep them or move them out. Moving them out is cleaner but might break context access if not careful. I'll keep them inside for now to minimize diff risk, but I need to be careful with the line range.
    // Actually, the previous view showed them inside build. I will keep them there but I need to include them in the replacement or ensure I don't delete them.
    // The replacement range starts at 134 (start of build) and ends at 800 (end of file view).
    // I will rewrite the build method to include the new UI structure.

    void showEditTaskDialog(MonthlyTaskModel task) {
      final controller = TextEditingController(text: task.title);
      int selectedDifficulty = task.difficulty;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Editar Responsabilidad',
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Revisar aceite',
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DIFICULTAD',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Rutinario'),
                        selected: selectedDifficulty == 1,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 1);
                        },
                        selectedColor: Colors.green.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 1 ? Colors.green : null,
                          fontWeight: selectedDifficulty == 1
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Gestión'),
                        selected: selectedDifficulty == 2,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 2);
                        },
                        selectedColor: Colors.amber.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 2 ? Colors.amber : null,
                          fontWeight: selectedDifficulty == 2
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Pesado'),
                        selected: selectedDifficulty == 3,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 3);
                        },
                        selectedColor: Colors.red.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 3 ? Colors.red : null,
                          fontWeight: selectedDifficulty == 3
                              ? FontWeight.bold
                              : null,
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
                    if (controller.text.isNotEmpty) {
                      provider.updateTask(
                        task.id,
                        controller.text,
                        selectedDifficulty,
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

    void showAddTaskDialog() {
      final controller = TextEditingController();
      int selectedDifficulty = 1;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Nueva Responsabilidad',
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Revisar aceite',
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DIFICULTAD',
                      style: GoogleFonts.spaceMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Rutinario'),
                        selected: selectedDifficulty == 1,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 1);
                        },
                        selectedColor: Colors.green.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 1 ? Colors.green : null,
                          fontWeight: selectedDifficulty == 1
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Gestión'),
                        selected: selectedDifficulty == 2,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 2);
                        },
                        selectedColor: Colors.amber.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 2 ? Colors.amber : null,
                          fontWeight: selectedDifficulty == 2
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Pesado'),
                        selected: selectedDifficulty == 3,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDifficulty = 3);
                        },
                        selectedColor: Colors.red.withOpacity(0.2),
                        labelStyle: GoogleFonts.spaceMono(
                          color: selectedDifficulty == 3 ? Colors.red : null,
                          fontWeight: selectedDifficulty == 3
                              ? FontWeight.bold
                              : null,
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
                    if (controller.text.isNotEmpty) {
                      provider.addTask(controller.text, selectedDifficulty);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('AGREGAR'),
                ),
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADULT MODE',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(
              'PROTOCOLOS DE MANTENIMIENTO',
              'Tareas recurrentes necesarias para evitar el colapso de tu infraestructura vital. El reinicio es mensual.',
              Icons.security,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_task, color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Dashboard (Reactor Core)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Reactor Core (Circular Monitor)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 15,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    // Progress Circle
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 15,
                        color: statusColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Center Data
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.spaceMono(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        ),
                        Text(
                          'INTEGRIDAD',
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    'ESTADO: $statusText',
                    style: GoogleFonts.spaceMono(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Row (Restored)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Days Left
                    Column(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Theme.of(context).hintColor,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          () {
                            final now = DateTime.now();
                            final lastDay = DateTime(
                              now.year,
                              now.month + 1,
                              0,
                            );
                            final daysLeft = lastDay.difference(now).inDays;
                            return '$daysLeft DÍAS';
                          }(),
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'REINICIO',
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    // Divider
                    Container(
                      height: 30,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    // XP Potential
                    Column(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '+${provider.calculatePotentialXP()}',
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          'XP POTENCIAL',
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: provider.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          size: 80,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'SISTEMAS EN ESPERA',
                          style: GoogleFonts.spaceMono(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AGREGA UN PROTOCOLO',
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 16),
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final sortedTasks = List<MonthlyTaskModel>.from(
                        provider.tasks,
                      );
                      sortedTasks.sort((a, b) {
                        if (a.isCompleted == b.isCompleted) return 0;
                        return a.isCompleted ? 1 : -1;
                      });
                      final task = sortedTasks[index];

                      Color difficultyColor;
                      String difficultyLabel;
                      switch (task.difficulty) {
                        case 3:
                          difficultyColor = Colors.red;
                          difficultyLabel = 'NIVEL 3';
                          break;
                        case 2:
                          difficultyColor = Colors.amber;
                          difficultyLabel = 'NIVEL 2';
                          break;
                        default:
                          difficultyColor = Colors.green;
                          difficultyLabel = 'NIVEL 1';
                      }

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  '¿Eliminar protocolo?',
                                  style: GoogleFonts.spaceMono(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                  'Esta acción eliminará la tarea del sistema permanentemente.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('CANCELAR'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'ELIMINAR',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          provider.deleteTask(task.id);
                        },
                        child: GestureDetector(
                          onTap: () {
                            if (!_hasShownHint) {
                              setState(() => _hasShownHint = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '¡Bien hecho! Recuerda que puedes editar manteniendo presionado.',
                                    style: GoogleFonts.spaceMono(fontSize: 12),
                                  ),
                                  backgroundColor: AppTheme.primary,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                            HapticFeedback.mediumImpact();
                            provider.toggleTask(task.id).then((_) {
                              if (provider.isMonthCompleted) {
                                _checkCompletion(provider);
                              }
                            });
                          },
                          onLongPress: () => showEditTaskDialog(task),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            color: task.isCompleted
                                ? Theme.of(context).cardColor.withOpacity(0.5)
                                : Theme.of(context).cardColor,
                            elevation: task.isCompleted ? 0 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: task.isCompleted
                                    ? Colors.transparent
                                    : difficultyColor.withOpacity(0.3),
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  // Difficulty Strip
                                  Container(
                                    width: 6,
                                    decoration: BoxDecoration(
                                      color: task.isCompleted
                                          ? Colors.grey
                                          : difficultyColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: task.isCompleted
                                                      ? Colors.grey.withOpacity(
                                                          0.2,
                                                        )
                                                      : difficultyColor
                                                            .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  difficultyLabel,
                                                  style: GoogleFonts.spaceMono(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: task.isCompleted
                                                        ? Colors.grey
                                                        : difficultyColor,
                                                  ),
                                                ),
                                              ),
                                              if (task.isCompleted)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green
                                                      .withOpacity(0.7),
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            task.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              decoration: task.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: task.isCompleted
                                                  ? Theme.of(
                                                      context,
                                                    ).disabledColor
                                                  : Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
