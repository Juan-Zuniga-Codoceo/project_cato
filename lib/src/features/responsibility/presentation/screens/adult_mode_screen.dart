import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../providers/responsibility_provider.dart';
import '../../../../core/theme/app_theme.dart';

class AdultModeScreen extends StatefulWidget {
  const AdultModeScreen({super.key});

  @override
  State<AdultModeScreen> createState() => _AdultModeScreenState();
}

class _AdultModeScreenState extends State<AdultModeScreen> {
  late ConfettiController _confettiController;

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
        builder: (context) => _buildCompletionDialog(),
      );
    }
  }

  Widget _buildCompletionDialog() {
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
                  '+200 XP',
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROTOCOLO MENSUAL',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTADO DEL SISTEMA: ${(progress * 100).toInt()}%',
                  style: GoogleFonts.spaceMono(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  color: progressColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border.all(
                      color: task.isCompleted
                          ? Colors.green.withOpacity(0.5)
                          : Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    value: task.isCompleted,
                    onChanged: (value) {
                      provider.toggleTask(task.id).then((_) {
                        if (provider.isMonthCompleted) {
                          _checkCompletion(provider);
                        }
                      });
                    },
                    title: Text(
                      task.title,
                      style: GoogleFonts.inter(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.5)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    secondary: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: task.isCompleted ? Colors.green : Colors.grey,
                    ),
                    activeColor: Colors.green,
                    checkColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
