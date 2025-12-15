import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String appWidgetProvider = 'CatoWidgetProvider';

  static Future<void> updateData({
    int? level,
    int? xp,
    int? maxXp,
    String? topTask,
  }) async {
    if (level != null && level != -1) {
      await HomeWidget.saveWidgetData<int>('level', level);
    }
    if (xp != null && xp != -1 && maxXp != null && maxXp != -1) {
      await HomeWidget.saveWidgetData<int>(
        'xp_percent',
        (xp / maxXp * 100).toInt(),
      );
    }
    if (topTask != null) {
      await HomeWidget.saveWidgetData<String>('top_task', topTask);
    }
    await HomeWidget.updateWidget(
      name: appWidgetProvider,
      androidName: appWidgetProvider,
    );
  }
}
