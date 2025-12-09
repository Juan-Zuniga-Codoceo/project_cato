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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResponsibilityProvider>(context);
    final progress = provider.progress;

    Color progressColor;
    if (progress < 0.5) {
      progressColor = AppTheme.danger;
    } else if (progress < 1.0) {
      progressColor = AppTheme.primary;
    } else {
      progressColor = Colors.green;
    }

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

    String statusText;
    Color statusColor;
    if (progress < 0.3) {
      statusText = 'CRÍTICO';
      statusColor = AppTheme.danger;
    } else if (progress < 1.0) {
      statusText = 'ESTABLE';
      statusColor = AppTheme.primary;
    } else {
      statusText = 'ÓPTIMO';
      statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADULT MODE',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_task, color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Dashboard
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Nivel 1: Monitor Circular Grande
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 16,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        color: statusColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'INTEGRIDAD',
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.spaceMono(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Nivel 3: Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ESTADO',
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.spaceMono(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: () {
                                    final now = DateTime.now();
                                    final lastDay = DateTime(
                                      now.year,
                                      now.month + 1,
                                      0,
                                    );
                                    final daysLeft = lastDay
                                        .difference(now)
                                        .inDays;
                                    return daysLeft < 5
                                        ? Colors.red
                                        : Colors.grey;
                                  }(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  () {
                                    final now = DateTime.now();
                                    final lastDay = DateTime(
                                      now.year,
                                      now.month + 1,
                                      0,
                                    );
                                    final daysLeft = lastDay
                                        .difference(now)
                                        .inDays;
                                    return 'REINICIO EN $daysLeft DÍAS';
                                  }(),
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: () {
                                      final now = DateTime.now();
                                      final lastDay = DateTime(
                                        now.year,
                                        now.month + 1,
                                        0,
                                      );
                                      final daysLeft = lastDay
                                          .difference(now)
                                          .inDays;
                                      return daysLeft < 5
                                          ? Colors.red
                                          : Colors.grey;
                                    }(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // XP Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'XP POTENCIAL',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${provider.calculatePotentialXP()}',
                            style: GoogleFonts.spaceMono(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Briefing
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Los protocolos se reinician cada mes.\n',
                        ),
                        TextSpan(
                          text:
                              '💡 Tip: Mantén presionado para editar, desliza para borrar.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: provider.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_add,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sistema limpio.\nAgrega tus rutinas mensuales.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceMono(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
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
                          difficultyLabel = 'PESADO';
                          break;
                        case 2:
                          difficultyColor = Colors.amber;
                          difficultyLabel = 'GESTIÓN';
                          break;
                        default:
                          difficultyColor = Colors.green;
                          difficultyLabel = 'RUTINA';
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
                                  '¿Eliminar módulo?',
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
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: task.isCompleted
                                  ? Colors.green.withOpacity(0.3)
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.5),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Difficulty Indicator Strip
                                Container(
                                  width: 6,
                                  color: task.isCompleted
                                      ? Colors.green.withOpacity(0.5)
                                      : difficultyColor,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onLongPress: () => showEditTaskDialog(task),
                                    onTap: () {
                                      if (!_hasShownHint) {
                                        setState(() => _hasShownHint = true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '¡Bien hecho! Recuerda que puedes editar manteniendo presionado.',
                                              style: GoogleFonts.spaceMono(
                                                fontSize: 12,
                                              ),
                                            ),
                                            backgroundColor: AppTheme.primary,
                                            duration: const Duration(
                                              seconds: 4,
                                            ),
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
                                    child: IgnorePointer(
                                      child: CheckboxListTile(
                                        value: task.isCompleted,
                                        onChanged: (value) {},
                                        title: Text(
                                          task.title,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: task.isCompleted
                                                ? Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.5)
                                                : Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: task.isCompleted
                                                      ? Colors.grey.withOpacity(
                                                          0.1,
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
                                            ],
                                          ),
                                        ),
                                        secondary: Icon(
                                          task.isCompleted
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: task.isCompleted
                                              ? Colors.green
                                              : Colors.grey.withOpacity(0.5),
                                        ),
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
