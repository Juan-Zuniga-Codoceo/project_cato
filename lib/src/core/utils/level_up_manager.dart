import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelUpManager {
  static void showLevelUpDialog(BuildContext context, int newLevel) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Confetti Layer
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
            // Dialog Layer
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC107), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar / Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFC107),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.keyboard_double_arrow_up,
                        size: 64,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡SUBISTE DE NIVEL!',
                      style: GoogleFonts.spaceMono(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NIVEL $newLevel',
                      style: GoogleFonts.spaceMono(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFC107),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        confettiController.stop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'CONTINUAR',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) => confettiController.dispose());
  }
}
