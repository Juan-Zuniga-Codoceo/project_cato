import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/habit_provider.dart';

import '../widgets/radar_chart_widget.dart';
import '../../../gamification/presentation/screens/achievements_screen.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  void _showInfoDialog(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PERFIL DE PERSONAJE',
          style: theme.textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final stats = provider.userStats;
          final xpForNext = provider.xpForNextLevel;
          final globalProgress = stats.totalXp / xpForNext;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Global Stats Header
                Card(
                  // Inherits theme style (Dark: Surface, Light: White)
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Avatar (Clickable)
                        GestureDetector(
                          onTap: () => _showAvatarSelector(context, provider),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(
                                        0.5,
                                      ),
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    stats.avatarPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.shield,
                                        color: theme.colorScheme.onPrimary,
                                        size: 48,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(
                                      4,
                                    ), // More angular
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'LVL ${stats.currentLevel}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name with Edit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                stats.userName,
                                style: theme.textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: theme.colorScheme.primary,
                              onPressed: () => _showNameEditor(
                                context,
                                provider,
                                stats.userName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rank Title (Subtitle)
                        Text(
                          stats.rankTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Achievements Button
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AchievementsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.emoji_events, size: 18),
                          label: Text(
                            'MEDALLAS',
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Global XP Progress
                        GestureDetector(
                          onTap: () => _showInfoDialog(
                            context,
                            'CRECIMIENTO CONTINUO',
                            'El nivel no es un destino, es una consecuencia de tus hábitos diarios. Sigue ejecutando.',
                            Icons.trending_up,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'XP GLOBAL',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  Text(
                                    '${stats.totalXp} / $xpForNext',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: globalProgress.clamp(0.0, 1.0),
                                    minHeight: 16,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Radar Chart
                Card(
                  child: InkWell(
                    onTap: () => _showInfoDialog(
                      context,
                      'BALANCE DE SISTEMA',
                      'Un Operador desbalanceado es vulnerable. Busca expandir el gráfico uniformemente hacia los bordes.',
                      Icons.radar,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'BALANCE DE ATRIBUTOS',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          RadarChartWidget(stats: stats),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Attributes Title
                Text('ATRIBUTOS', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),

                // Attributes Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _AttributeCard(
                      title: 'FUERZA',
                      iconPath: 'assets/icons/attr_strength.png',
                      color: Colors.red,
                      level: stats.getAttributeLevel('Fuerza'),
                      xp: stats.getAttributeXp('Fuerza'),
                      onTap: () => _showInfoDialog(
                        context,
                        'RESILIENCIA',
                        'No es solo levantar peso, es la capacidad de soportar la adversidad sin quebrarse.',
                        Icons.fitness_center,
                      ),
                    ),
                    _AttributeCard(
                      title: 'INTELECTO',
                      iconPath: 'assets/icons/attr_intellect.png',
                      color: Colors.blue,
                      level: stats.getAttributeLevel('Intelecto'),
                      xp: stats.getAttributeXp('Intelecto'),
                      onTap: () => _showInfoDialog(
                        context,
                        'ADAPTABILIDAD',
                        'La agudeza mental para resolver problemas complejos y aprender de los errores.',
                        Icons.psychology,
                      ),
                    ),
                    _AttributeCard(
                      title: 'VITALIDAD',
                      iconPath: 'assets/icons/attr_vitality.png',
                      color: Colors.green,
                      level: stats.getAttributeLevel('Vitalidad'),
                      xp: stats.getAttributeXp('Vitalidad'),
                      onTap: () => _showInfoDialog(
                        context,
                        'ENERGÍA OPERATIVA',
                        'Sin salud física y mental, ningún sistema puede funcionar a largo plazo.',
                        Icons.favorite,
                      ),
                    ),
                    _AttributeCard(
                      title: 'DISCIPLINA',
                      iconPath: 'assets/icons/attr_discipline.png',
                      color: Colors.grey,
                      level: stats.getAttributeLevel('Disciplina'),
                      xp: stats.getAttributeXp('Disciplina'),
                      onTap: () => _showInfoDialog(
                        context,
                        'CONSISTENCIA',
                        'La única estadística que importa cuando la motivación desaparece.',
                        Icons.shield,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttributeCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color color;
  final int level;
  final int xp;
  final VoidCallback? onTap;

  const _AttributeCard({
    required this.title,
    required this.iconPath,
    required this.color,
    required this.level,
    required this.xp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (xp % 100) / 100;
    final nextLevelXp = 100;

    return Card(
      // Inherits theme style
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and Title
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Level
              Text(
                'NIVEL $level',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // XP Progress
              Column(
                children: [
                  Text(
                    '${xp % 100} / $nextLevelXp XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Available avatar options
const List<String> _maleAvatars = [
  'assets/avatars/hero_1.jpg',
  'assets/avatars/hero_2.jpg',
  'assets/avatars/hero_4.jpg',
  'assets/avatars/hero_5.jpg',
  'assets/avatars/hero_diplomat.png',
];

const List<String> _femaleAvatars = [
  'assets/avatars/hero_valkyrie.png',
  'assets/avatars/hero_3.jpg', // Hacker (Neutral/Female leaning)
  'assets/avatars/hero_ghost.png',
  'assets/avatars/hero_mechanic.png',
];

const List<String> _neutralAvatars = [
  'assets/avatars/hero_3.jpg',
  'assets/avatars/hero_ghost.png',
];

// Show Avatar Selector Modal
void _showAvatarSelector(BuildContext context, HabitProvider provider) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      List<String> avatars;
      if (provider.userStats.gender == 'female') {
        avatars = _femaleAvatars;
      } else if (provider.userStats.gender == 'male') {
        avatars = _maleAvatars;
      } else {
        avatars = _neutralAvatars;
      }

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SELECCIONA TU AVATAR',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final avatarPath = avatars[index];
                return GestureDetector(
                  onTap: () {
                    provider.updateAvatar(avatarPath);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 40,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

// Show Name Editor Dialog
void _showNameEditor(
  BuildContext context,
  HabitProvider provider,
  String currentName,
) {
  final TextEditingController controller = TextEditingController(
    text: currentName,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('EDITAR NOMBRE'),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Ingresa tu nombre'),
            maxLength: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                provider.updateUserName(newName);
                Navigator.pop(context);
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      );
    },
  );
}
