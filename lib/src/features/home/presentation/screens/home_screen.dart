import 'package:flutter/material.dart';
import '../../../finance/presentation/screens/finance_screen.dart';
import '../../../tools/presentation/screens/tools_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../habits/presentation/screens/habits_screen.dart';
import '../../../garage/presentation/screens/garage_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Renamed _selectedIndex to _currentIndex

  final List<Widget> _screens = [
    // Renamed _pages to _screens
    const FinanceScreen(),
    const TasksScreen(),
    const HabitsScreen(), // Added HabitsScreen
    const GarageScreen(),
    const ToolsScreen(),
  ];

  final List<String> _screenTitles = [
    'Finanzas',
    'Tareas',
    'Hábitos',
    'Garaje',
    'Herramientas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex]),
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
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tareas',
          ),
          NavigationDestination(icon: Icon(Icons.whatshot), label: 'Hábitos'),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: 'Garaje',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Herramientas',
          ),
        ],
      ),
    );
  }
}
