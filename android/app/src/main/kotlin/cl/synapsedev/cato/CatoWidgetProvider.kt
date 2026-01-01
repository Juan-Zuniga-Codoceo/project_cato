package cl.synapsedev.cato

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.app.PendingIntent
import android.content.Intent

class CatoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.cato_widget_layout)

            val level = widgetData.getInt("level", 1)
            val xpPercent = widgetData.getInt("xp_percent", 0)
            val topTask = widgetData.getString("top_task", "Tu Mejor Versión")

            views.setTextViewText(R.id.widget_level, "NIVEL $level")
            views.setProgressBar(R.id.widget_xp_bar, 100, xpPercent, false)
            views.setTextViewText(R.id.widget_top_task, topTask)

            // Open App Intent
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_open_button, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_level, pendingIntent) // Click anywhere mostly

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
