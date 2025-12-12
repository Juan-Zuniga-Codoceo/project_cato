import 'package:flutter/material.dart';
import '../../../garage/presentation/screens/garage_screen.dart';
import '../../../lifestyle/presentation/screens/lifestyle_screen.dart';
import '../../../tools/presentation/screens/tools_screen.dart';
import '../../../responsibility/presentation/screens/adult_mode_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../academic/presentation/screens/academic_screen.dart';

class AppsMenuScreen extends StatelessWidget {
  const AppsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _AppCard(
            title: 'GARAJE',
            icon: Icons.directions_car,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GarageScreen()),
            ),
          ),
          _AppCard(
            title: 'ESTILO DE VIDA',
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LifestyleScreen()),
            ),
          ),
          _AppCard(
            title: 'HERRAMIENTAS',
            icon: Icons.grid_view,
            color: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolsScreen()),
            ),
          ),
          _AppCard(
            title: 'SISTEMAS',
            icon: Icons.dns,
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdultModeScreen()),
            ),
          ),
          _AppCard(
            title: 'ALIADOS',
            icon: Icons.groups,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SocialScreen()),
            ),
          ),
          _AppCard(
            title: 'ACADEMIA',
            icon: Icons.school,
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AcademicScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Inherits AppTheme CardTheme
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'SpaceMono',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
