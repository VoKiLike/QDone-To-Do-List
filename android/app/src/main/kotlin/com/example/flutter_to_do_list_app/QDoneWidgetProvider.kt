package com.volkoweb.qdone

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class QDoneWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.qdone_widget)
            views.setTextViewText(R.id.widget_title, widgetData.getString("widget_title", "QDone"))
            views.setTextViewText(
                R.id.widget_tasks,
                widgetData.getString("widget_tasks", "Ближайшие задачи появятся здесь")
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
