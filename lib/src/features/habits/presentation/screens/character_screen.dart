import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/habit_provider.dart';
import '../widgets/radar_chart_widget.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Personaje'),
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
                  color: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.amber.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
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
                                      Colors.amber[700]!,
                                      Colors.amber[300]!,
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.5),
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
                                      // Fallback to icon if image not found
                                      return const Icon(
                                        Icons.shield,
                                        color: Colors.white,
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
                                    color: Colors.amber[700],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'LVL ${stats.currentLevel}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.amber[400],
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
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Global XP Progress
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'XP Global',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${stats.totalXp} / $xpForNext',
                                  style: TextStyle(
                                    color: Colors.amber[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: globalProgress.clamp(0.0, 1.0),
                                minHeight: 12,
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.amber[600]!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Radar Chart
                Card(
                  color: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.cyan.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Balance de Atributos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RadarChartWidget(stats: stats),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Attributes Title
                const Text(
                  'Atributos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      title: 'Fuerza',
                      icon: Icons.fitness_center,
                      color: Colors.red,
                      level: stats.getAttributeLevel('Fuerza'),
                      xp: stats.getAttributeXp('Fuerza'),
                    ),
                    _AttributeCard(
                      title: 'Intelecto',
                      icon: Icons.psychology,
                      color: Colors.blue,
                      level: stats.getAttributeLevel('Intelecto'),
                      xp: stats.getAttributeXp('Intelecto'),
                    ),
                    _AttributeCard(
                      title: 'Vitalidad',
                      icon: Icons.favorite,
                      color: Colors.green,
                      level: stats.getAttributeLevel('Vitalidad'),
                      xp: stats.getAttributeXp('Vitalidad'),
                    ),
                    _AttributeCard(
                      title: 'Disciplina',
                      icon: Icons.shield,
                      color: Colors.grey,
                      level: stats.getAttributeLevel('Disciplina'),
                      xp: stats.getAttributeXp('Disciplina'),
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
  final IconData icon;
  final Color color;
  final int level;
  final int xp;

  const _AttributeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.level,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (xp % 100) / 100;
    final nextLevelXp = 100;

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Level
            Text(
              'Nivel $level',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // XP Progress
            Column(
              children: [
                Text(
                  '${xp % 100} / $nextLevelXp XP',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Available avatar options
const List<String> _availableAvatars = [
  'assets/avatars/hero_1.jpg', // Guerrero
  'assets/avatars/hero_2.jpg', // Magnate
  'assets/avatars/hero_3.jpg', // Hacker
  'assets/avatars/hero_4.jpg', // Ninja
  'assets/avatars/hero_5.jpg', // Sensei
];

// Show Avatar Selector Modal
void _showAvatarSelector(BuildContext context, HabitProvider provider) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecciona tu Avatar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _availableAvatars.length,
              itemBuilder: (context, index) {
                final avatarPath = _availableAvatars[index];
                return GestureDetector(
                  onTap: () {
                    provider.updateAvatar(avatarPath);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 40,
                            ),
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
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Editar Nombre',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ingresa tu nombre',
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber[400]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber[600]!),
              ),
            ),
            maxLength: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                provider.updateUserName(newName);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
