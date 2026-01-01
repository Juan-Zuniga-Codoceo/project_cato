import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/achievement_provider.dart';
import '../../domain/models/badge_model.dart';

import '../../../../core/providers/habit_provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../core/providers/garage_provider.dart';
import '../../../academic/providers/academic_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    _verifyAchievements();
  }

  void _verifyAchievements() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      final academicProvider = Provider.of<AcademicProvider>(
        context,
        listen: false,
      );
      final garageProvider = Provider.of<GarageProvider>(
        context,
        listen: false,
      );
      final achievementProvider = Provider.of<AchievementProvider>(
        context,
        listen: false,
      );

      // Calculate max streak
      int maxStreak = 0;
      if (habitProvider.habits.isNotEmpty) {
        maxStreak = habitProvider.habits
            .map((h) => h.bestStreak)
            .reduce((a, b) => a > b ? a : b);
      }

      // Calculate academic average
      double average = 0;
      if (academicProvider.subjects.isNotEmpty) {
        double total = 0;
        for (var subject in academicProvider.subjects) {
          total += academicProvider.calculateCurrentAverage(subject);
        }
        average = total / academicProvider.subjects.length;
      }

      // Execute verification with current data
      achievementProvider.checkAchievements(
        userStats: habitProvider.userStats,
        balance: financeProvider.totalBalance,
        maxStreak: maxStreak,
        academicAverage: average,
        maintenanceCount: garageProvider.maintenances.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          final badges = provider.badges;
          final unlockedCount = badges.where((b) => b.isUnlocked).length;
          final totalCount = badges.length;
          final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                iconTheme: theme.iconTheme,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'HALL OF VALOR',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 2.0,
                    ),
                  ),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.amber.withOpacity(isDark ? 0.2 : 0.1),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 80,
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROGRESO DE COLECCIÓN',
                        style: GoogleFonts.spaceMono(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: theme.dividerColor.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.amber,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$unlockedCount / $totalCount DESBLOQUEADOS',
                        style: GoogleFonts.spaceMono(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final badge = badges[index];
                    return _BadgeCapsule(badge: badge, isDark: isDark);
                  }, childCount: badges.length),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeCapsule extends StatelessWidget {
  final BadgeModel badge;
  final bool isDark;

  const _BadgeCapsule({required this.badge, required this.isDark});

  void _showBadgeDetails(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Image.asset(
              badge.iconPath,
              width: 120,
              height: 120,
              color: badge.isUnlocked
                  ? null
                  : (isDark ? Colors.black : Colors.grey),
              colorBlendMode: badge.isUnlocked ? null : BlendMode.saturation,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.emoji_events,
                size: 120,
                color: badge.isUnlocked ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              badge.title.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked
                    ? Colors.amber
                    : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (badge.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  'DESBLOQUEADO',
                  style: GoogleFonts.spaceMono(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  'BLOQUEADO',
                  style: GoogleFonts.spaceMono(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.isUnlocked
                ? Colors.amber.withOpacity(0.5)
                : (isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
            width: 1,
          ),
          boxShadow: badge.isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Opacity(
                  opacity: badge.isUnlocked ? 1.0 : (isDark ? 0.3 : 0.5),
                  child: Image.asset(
                    badge.iconPath,
                    width: 64,
                    height: 64,
                    color: badge.isUnlocked
                        ? null
                        : (isDark ? Colors.black : Colors.grey),
                    colorBlendMode: badge.isUnlocked
                        ? null
                        : BlendMode.saturation,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: badge.isUnlocked ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    badge.title.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
