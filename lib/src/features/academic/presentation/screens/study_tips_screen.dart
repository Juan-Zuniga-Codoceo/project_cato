import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyTipsScreen extends StatelessWidget {
  const StudyTipsScreen({super.key});

  final List<Map<String, dynamic>> tips = const [
    {
      'title': 'Active Recall',
      'icon': Icons.psychology,
      'color': Colors.orange,
      'description':
          'No releas pasivamente. Cierra el libro y trata de recordar lo que leíste. El esfuerzo de recuperar la información fortalece la memoria.',
    },
    {
      'title': 'Spaced Repetition',
      'icon': Icons.update,
      'color': Colors.blue,
      'description':
          'Repasa el material en intervalos crecientes (1 día, 3 días, 1 semana). Esto combate la "curva del olvido".',
    },
    {
      'title': 'Técnica Feynman',
      'icon': Icons.record_voice_over,
      'color': Colors.green,
      'description':
          'Explica el concepto en términos simples, como si se lo enseñaras a un niño de 5 años. Si no puedes, no lo entiendes bien.',
    },
    {
      'title': 'Sistema Leitner',
      'icon': Icons.style,
      'color': Colors.purple,
      'description':
          'Usa tarjetas (flashcards). Mueve las que aciertas a una caja de repaso menos frecuente y las que fallas a una de repaso diario.',
    },
    {
      'title': 'Pomodoro',
      'icon': Icons.timer,
      'color': Colors.red,
      'description':
          'Estudia 25 minutos intensos, descansa 5. El cerebro mantiene el foco mejor en ráfagas cortas.',
    },
    {
      'title': 'Interleaving',
      'icon': Icons.shuffle,
      'color': Colors.teal,
      'description':
          'Mezcla diferentes temas o tipos de problemas en una sesión. No estudies "bloques" masivos de una sola cosa.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TÉCNICAS DE ESTUDIO',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tip['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(tip['icon'], color: tip['color'], size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tip['title'],
                          style: GoogleFonts.spaceMono(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Colors.grey[400], // Assuming dark mode mostly
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
