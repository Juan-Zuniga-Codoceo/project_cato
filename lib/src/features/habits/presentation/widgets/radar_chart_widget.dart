import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/user_stats_model.dart';

class RadarChartWidget extends StatelessWidget {
  final UserStatsModel stats;

  const RadarChartWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 5,
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 10,
          ),
          radarBorderData: const BorderSide(color: Colors.white24, width: 1),
          gridBorderData: const BorderSide(color: Colors.white12, width: 1),
          tickBorderData: const BorderSide(color: Colors.transparent),
          getTitle: (index, angle) {
            const titles = ['Fuerza', 'Intelecto', 'Vitalidad', 'Disciplina'];

            return RadarChartTitle(text: titles[index], angle: angle);
          },
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          titlePositionPercentageOffset: 0.2,
          dataSets: [
            RadarDataSet(
              fillColor: Colors.cyan.withOpacity(0.2),
              borderColor: Colors.cyan,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: _getScaledLevel(stats.strengthXp)),
                RadarEntry(value: _getScaledLevel(stats.intellectXp)),
                RadarEntry(value: _getScaledLevel(stats.vitalityXp)),
                RadarEntry(value: _getScaledLevel(stats.disciplineXp)),
              ],
            ),
          ],
          radarBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  // Scale levels to 0-100 range for better visualization
  double _getScaledLevel(int xp) {
    final level = xp ~/ 100;
    // Cap at 20 for display purposes, scale to 100
    return (level.clamp(0, 20) * 5).toDouble();
  }
}
