import 'package:flutter/material.dart';
import '../../../finance/presentation/screens/finance_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/habit_provider.dart';
import '../../../../core/utils/level_up_manager.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'apps_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FinanceScreen(),
    const HabitsScreen(),
    const TasksScreen(),
    const AppsMenuScreen(),
  ];

  final List<String> _screenTitles = [
    'FINANZAS',
    'DISCIPLINA RPG',
    'MISIONES',
    'SISTEMA CATO',
  ];

  @override
  void initState() {
    super.initState();
    // Listen for Level Up events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
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
            icon: Icon(Icons.attach_money),
            label: 'Finanzas',
          ),
          NavigationDestination(icon: Icon(Icons.whatshot), label: 'Hábitos'),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tareas',
          ),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Apps'),
        ],
      ),
    );
  }
}
