package com.volkoweb.qdone

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

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
            views.removeAllViews(R.id.widget_rows)
            renderRows(context, views, widgetData)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun renderRows(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences
    ) {
        val rowsJson = widgetData.getString("widget_tasks_json", "[]") ?: "[]"
        val compact = widgetData.getBoolean("widget_compact", false)
        val rows = JSONArray(rowsJson)
        if (rows.length() == 0) {
            val emptyRow = RemoteViews(context.packageName, R.layout.qdone_widget_row)
            emptyRow.setTextViewText(R.id.widget_task_time, "")
            emptyRow.setTextViewText(R.id.widget_task_category, "")
            emptyRow.setTextViewText(R.id.widget_task_title, "Нет ближайших задач")
            emptyRow.setTextViewText(R.id.widget_task_done, "")
            emptyRow.setViewVisibility(R.id.widget_task_done, View.INVISIBLE)
            views.addView(R.id.widget_rows, emptyRow)
            return
        }

        val maxRows = if (compact) minOf(rows.length(), 6) else minOf(rows.length(), 4)
        for (index in 0 until maxRows) {
            val item = rows.getJSONObject(index)
            val taskId = item.optString("id")
            val status = item.optString("status")
            val row = RemoteViews(context.packageName, R.layout.qdone_widget_row)
            row.setTextViewText(R.id.widget_task_time, item.optString("time"))
            row.setTextViewText(R.id.widget_task_category, item.optString("category"))
            row.setTextViewText(R.id.widget_task_title, item.optString("title"))
            row.setTextColor(
                R.id.widget_task_time,
                if (status == "overdue") Color.rgb(251, 146, 60) else Color.rgb(103, 232, 249)
            )

            val openIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("qdone://task/$taskId")
            )
            val doneIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("qdone://done?taskId=$taskId")
            )
            row.setOnClickPendingIntent(R.id.widget_task_row, openIntent)
            row.setOnClickPendingIntent(R.id.widget_task_done, doneIntent)
            views.addView(R.id.widget_rows, row)
        }
    }
}
