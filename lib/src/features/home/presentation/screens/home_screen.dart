import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mens_lifestyle_app/src/features/finance/presentation/screens/finance_screen.dart';
import 'package:mens_lifestyle_app/src/features/habits/presentation/screens/habits_screen.dart';
import 'package:mens_lifestyle_app/src/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:mens_lifestyle_app/src/features/home/presentation/screens/dashboard_screen.dart';
import 'package:mens_lifestyle_app/src/features/home/presentation/screens/apps_menu_screen.dart';
import 'package:mens_lifestyle_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:mens_lifestyle_app/src/core/providers/habit_provider.dart';
import 'package:mens_lifestyle_app/src/core/utils/level_up_manager.dart';
import 'package:mens_lifestyle_app/src/core/services/home_widget_service.dart';
import 'package:mens_lifestyle_app/src/features/tasks/providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FinanceScreen(),
    const HabitsScreen(),
    const TasksScreen(),
    const AppsMenuScreen(),
  ];

  final List<String> _screenTitles = [
    'MI DÍA',
    'FINANZAS',
    'RPG',
    'TAREAS',
    'MÓDULOS',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final stats = habitProvider.userStats;

      final topTask =
          taskProvider.tasksForToday.where((t) => !t.isCompleted).isNotEmpty
          ? taskProvider.tasksForToday.where((t) => !t.isCompleted).first.title
          : "Sistemas Estables";

      HomeWidgetService.updateData(
        level: stats.currentLevel,
        xp: stats.totalXp,
        maxXp: habitProvider.xpForNextLevel,
        topTask: topTask,
      );
      // Listen for Level Up events
      habitProvider.onLevelUp.listen((newLevel) {
        if (mounted) {
          LevelUpManager.showLevelUpDialog(context, newLevel);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _screenTitles[_currentIndex],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'SpaceMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize),
            label: 'Mi Día',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money),
            label: 'Finanzas',
          ),
          NavigationDestination(icon: Icon(Icons.whatshot), label: 'RPG'),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tareas',
          ),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Módulos'),
        ],
      ),
    );
  }
}
