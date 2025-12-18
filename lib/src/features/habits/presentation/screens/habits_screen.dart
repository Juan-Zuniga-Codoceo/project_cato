import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/habit_provider.dart';
import '../../domain/models/habit_model.dart';
import 'character_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disciplina Diaria'), centerTitle: true),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          final habits = provider.habits;

          return Column(
            children: [
              // Mini RPG Stats Widget
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MiniRpgStatsWidget(),
              ),

              // Habits List
              Expanded(
                child: habits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder Image (Gato Guerrero)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.5),
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/avatars/hero_1.jpg',
                                  ), // Using existing asset as placeholder
                                  fit: BoxFit.cover,
                                  opacity: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay hábitos forjados aún',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                '"La disciplina es el puente entre metas y logros."',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 100, // Prevent FAB from covering last item
                        ),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return HabitCard(habit: habit);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitModal(context),
        label: const Text('Forjar Hábito'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddHabitForm(),
    );
  }
}

class HabitCard extends StatelessWidget {
  final HabitModel habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isCompletedToday = habit.completedDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );

    return Card(
      // Inherits theme style
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Navigate to detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habit: habit),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Habit Icon/Color Indicator
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(habit.colorCode).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(habit.colorCode).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
                        color: Color(habit.colorCode),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.attribute.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Title and Streak
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isCompletedToday
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompletedToday
                            ? theme.textTheme.titleMedium?.color?.withOpacity(
                                0.5,
                              )
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${habit.currentStreak} DÍAS',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Completion Checkbox/Button
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isCompletedToday,
                  activeColor: theme.colorScheme.primary,
                  checkColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    if (value == true) {
                      final attributeEmoji = {
                        'Fuerza': '\u2694\ufe0f',
                        'Intelecto': '\ud83e\udde0',
                        'Vitalidad': '\u2764\ufe0f',
                        'Disciplina': '\ud83d\udee1\ufe0f',
                      };
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '+10 XP (${habit.attribute} +1) ${attributeEmoji[habit.attribute] ?? '\u2b50'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.inverseSurface,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(50),
                        ),
                      );
                    }
                    Provider.of<HabitProvider>(
                      context,
                      listen: false,
                    ).toggleCompletion(habit.id, DateTime.now());
                  },
                ),
              ),

              // Options Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.iconTheme.color?.withOpacity(0.5),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditHabitModal(context, habit);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, habit);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
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

class _AddHabitForm extends StatefulWidget {
  const _AddHabitForm();

  @override
  State<_AddHabitForm> createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<_AddHabitForm> {
  final _titleController = TextEditingController();
  int _selectedColor = 0xFF2196F3; // Blue default
  int _selectedIcon = 0xe0b1; // Fire default
  String _selectedAttribute = 'Disciplina';
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;

  final List<int> _colors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFF44336, // Red
    0xFFFFC107, // Amber
    0xFF9C27B0, // Purple
    0xFFFF5722, // Deep Orange
  ];

  final Map<String, IconData> _icons = {
    'Gym': Icons.fitness_center,
    'Lectura': Icons.local_library,
    'Salud': Icons.favorite,
    'Disciplina': Icons.shield,
    'Mente': Icons.psychology,
    'Agua': Icons.water_drop,
    'Ahorro': Icons.attach_money,
  };

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nuevo Hábito',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del hábito',
                hintText: 'Ej: Leer 30 minutos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text(
              '¿Qué mejora este hábito?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAttribute,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stars),
              ),
              items: ['Fuerza', 'Intelecto', 'Vitalidad', 'Disciplina']
                  .map(
                    (attr) => DropdownMenuItem(value: attr, child: Text(attr)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAttribute = value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text('Icono', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _icons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.value.codePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIcon = entry.value.codePoint),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 3)
                              : null,
                        ),
                        child: Icon(
                          entry.value,
                          color: isSelected ? Colors.blue : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.grey[400],
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Color Identificador',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Color(color).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reminder Section
            Card(
              color: Colors.grey[850],
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Recordatorio Diario'),
                    subtitle: _hasReminder && _reminderTime != null
                        ? Text(
                            'Notificación a las ${_reminderTime!.format(context)}',
                            style: TextStyle(color: Colors.grey[400]),
                          )
                        : const Text('Recibe una notificación diaria'),
                    value: _hasReminder,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        _hasReminder = value;
                        if (value && _reminderTime == null) {
                          // Set default time to 9:00 AM
                          _reminderTime = const TimeOfDay(hour: 9, minute: 0);
                        }
                      });
                    },
                  ),
                  if (_hasReminder)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime:
                                _reminderTime ??
                                const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              _reminderTime = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _reminderTime != null
                              ? 'Cambiar hora: ${_reminderTime!.format(context)}'
                              : 'Seleccionar hora',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  Provider.of<HabitProvider>(
                    context,
                    listen: false,
                  ).createHabit(
                    title: _titleController.text,
                    colorCode: _selectedColor,
                    iconCode: _selectedIcon,
                    attribute: _selectedAttribute,
                    hasReminder: _hasReminder,
                    reminderHour: _reminderTime?.hour,
                    reminderMinute: _reminderTime?.minute,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'FORJAR HÁBITO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class MiniRpgStatsWidget extends StatelessWidget {
  const MiniRpgStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;
        final xpForNext = provider.xpForNextLevel;
        final globalProgress = stats.totalXp / xpForNext;

        return Card(
          // Inherits theme style
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CharacterScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Row: Avatar + Global Level
                  Row(
                    children: [
                      // Avatar with custom image
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primary,
                            // [FIX] Renderizado seguro de imagen
                            child: ClipOval(
                              child: Image.asset(
                                stats.avatarPath,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.shield,
                                    color: theme.colorScheme.onPrimary,
                                    size: 30,
                                  );
                                },
                              ),
                            ),
                          ),
                          // Level badge overlay
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'LVL ${stats.currentLevel}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.rankTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIVEL ${stats.currentLevel}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(1),
                                child: LinearProgressIndicator(
                                  value: globalProgress.clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stats.totalXp} / $xpForNext XP',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.dividerColor, height: 1),
                  const SizedBox(height: 12),

                  // Bottom Row: 4 Mini Attribute Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniAttributeStat(
                        icon: Icons.fitness_center,
                        color: Colors.red,
                        xp: stats.strengthXp,
                        label: 'FUE',
                      ),
                      _MiniAttributeStat(
                        icon: Icons.psychology,
                        color: Colors.blue,
                        xp: stats.intellectXp,
                        label: 'INT',
                      ),
                      _MiniAttributeStat(
                        icon: Icons.favorite,
                        color: Colors.green,
                        xp: stats.vitalityXp,
                        label: 'VIT',
                      ),
                      _MiniAttributeStat(
                        icon: Icons.shield,
                        color: Colors.grey,
                        xp: stats.disciplineXp,
                        label: 'DIS',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniAttributeStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int xp;
  final String label;

  const _MiniAttributeStat({
    required this.icon,
    required this.color,
    required this.xp,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (xp % 100) / 100;
    final level = xp ~/ 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Lv$level',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class GamerProfileCard extends StatelessWidget {
  const GamerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;
        final xpForNext = provider.xpForNextLevel;
        final progress = stats.totalXp / xpForNext;

        return Card(
          color: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.amber.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar / Level Indicator
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.amber[700]!, Colors.amber[300]!],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, color: Colors.white, size: 24),
                      Text(
                        'LVL ${stats.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel ${stats.currentLevel} - ${stats.rankTitle}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'XP: ${stats.totalXp} / $xpForNext',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.amber[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber[600]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _showEditHabitModal(BuildContext context, HabitModel habit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _EditHabitForm(habit: habit),
  );
}

void _showDeleteConfirmation(BuildContext context, HabitModel habit) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar hábito'),
      content: Text('¿Estás seguro de eliminar "${habit.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Provider.of<HabitProvider>(
              context,
              listen: false,
            ).deleteHabit(habit.id);
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

class _EditHabitForm extends StatefulWidget {
  final HabitModel habit;

  const _EditHabitForm({required this.habit});

  @override
  State<_EditHabitForm> createState() => _EditHabitFormState();
}

class _EditHabitFormState extends State<_EditHabitForm> {
  late TextEditingController _titleController;
  late int _selectedColor;
  late int _selectedIcon;
  late String _selectedAttribute;

  final List<int> _colors = [
    0xFF2196F3,
    0xFF4CAF50,
    0xFFF44336,
    0xFFFFC107,
    0xFF9C27B0,
    0xFFFF5722,
  ];

  final Map<String, IconData> _icons = {
    'Pesa': Icons.fitness_center,
    'Libro': Icons.local_library,
    'Corazón': Icons.favorite,
    'Escudo': Icons.shield,
    'Cerebro': Icons.psychology,
    'Gota': Icons.water_drop,
    'Billete': Icons.attach_money,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _selectedColor = widget.habit.colorCode;
    _selectedIcon = widget.habit.iconCode;
    _selectedAttribute = widget.habit.attribute;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar Hábito',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del hábito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text(
              '¿Qué mejora este hábito?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAttribute,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stars),
              ),
              items: ['Fuerza', 'Intelecto', 'Vitalidad', 'Disciplina']
                  .map(
                    (attr) => DropdownMenuItem(value: attr, child: Text(attr)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAttribute = value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text('Icono', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _icons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.value.codePoint;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedIcon = entry.value.codePoint),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? Colors.blue : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Color Identificador',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Color(color).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final updatedHabit = widget.habit.copyWith(
                    title: _titleController.text,
                    colorCode: _selectedColor,
                    iconCode: _selectedIcon,
                    attribute: _selectedAttribute,
                  );
                  Provider.of<HabitProvider>(
                    context,
                    listen: false,
                  ).updateHabit(updatedHabit);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'GUARDAR CAMBIOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
