package com.volkoweb.qdone

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Paint
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.time.LocalDateTime
import org.json.JSONArray
import org.json.JSONObject

class QDoneWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            appWidgetManager.updateAppWidget(widgetId, buildViews(context, widgetData))
        }
    }

    private fun buildViews(
        context: Context,
        widgetData: SharedPreferences?
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.qdone_widget)
        views.setTextViewText(
            R.id.widget_title,
            widgetData?.getString(WIDGET_TITLE_KEY, "QDone") ?: "QDone"
        )

        val openIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("qdone://home")
        )
        views.setOnClickPendingIntent(R.id.widget_header, openIntent)
        views.setOnClickPendingIntent(R.id.widget_open_app, openIntent)

        views.removeAllViews(R.id.widget_rows)
        renderRows(context, views, widgetData)
        return views
    }

    private fun renderRows(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences?
    ) {
        val prefs = flutterPreferences(context)
        val settings = readSettings(prefs)
        val rows = readWidgetTasks(prefs, settings)
            ?: readWidgetTasks(
                widgetData?.getString(WIDGET_TASKS_JSON_KEY, "[]"),
                settings.compact
            )
            ?: emptyList()

        if (rows.isEmpty()) {
            val emptyRow = RemoteViews(context.packageName, R.layout.qdone_widget_row)
            emptyRow.setTextViewText(R.id.widget_task_time, "")
            emptyRow.setTextViewText(R.id.widget_task_category, "")
            emptyRow.setTextViewText(R.id.widget_task_title, "Нет ближайших задач")
            emptyRow.setTextViewText(R.id.widget_task_done, "")
            emptyRow.setViewVisibility(R.id.widget_task_done, View.INVISIBLE)
            views.addView(R.id.widget_rows, emptyRow)
            return
        }

        rows.forEach { item ->
            val layout = if (settings.compact) {
                R.layout.qdone_widget_row_compact
            } else {
                R.layout.qdone_widget_row
            }
            val row = RemoteViews(context.packageName, layout)
            val done = item.isCompleted
            val taskId = item.id

            row.setTextViewText(R.id.widget_task_time, item.time)
            row.setTextViewText(R.id.widget_task_category, item.category)
            row.setTextViewText(R.id.widget_task_title, item.title)
            row.setTextViewText(R.id.widget_task_done, if (done) "↺" else "✓")

            row.setTextColor(
                R.id.widget_task_time,
                when {
                    done -> Color.rgb(94, 234, 212)
                    item.status == STATUS_OVERDUE -> Color.rgb(251, 146, 60)
                    else -> Color.rgb(103, 232, 249)
                }
            )
            row.setTextColor(
                R.id.widget_task_category,
                if (done) Color.rgb(190, 242, 100) else Color.rgb(233, 213, 255)
            )
            row.setTextColor(
                R.id.widget_task_title,
                if (done) Color.rgb(191, 233, 219) else Color.WHITE
            )
            row.setInt(
                R.id.widget_task_done,
                "setBackgroundResource",
                if (done) {
                    R.drawable.qdone_widget_restore_button
                } else {
                    R.drawable.qdone_widget_done_button
                }
            )
            setStrike(row, R.id.widget_task_time, done)
            setStrike(row, R.id.widget_task_category, done)
            setStrike(row, R.id.widget_task_title, done)

            val openIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("qdone://task/$taskId")
            )
            row.setOnClickPendingIntent(R.id.widget_task_row, openIntent)
            row.setOnClickPendingIntent(
                R.id.widget_task_done,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("qdone://task/$taskId")
                )
            )
            views.addView(R.id.widget_rows, row)
        }
    }

    private fun readWidgetTasks(
        prefs: SharedPreferences,
        settings: WidgetSettings
    ): List<WidgetTask>? {
        val raw = prefs.getString(TASKS_KEY, null) ?: return null
        return readWidgetTasks(
            raw = raw,
            compact = settings.compact,
            showCompleted = settings.showCompleted,
            taskLimit = settings.taskLimit,
            fromTaskStore = true
        )
    }

    private fun readWidgetTasks(
        raw: String?,
        compact: Boolean,
        showCompleted: Boolean = true,
        taskLimit: Int = if (compact) 6 else 4,
        fromTaskStore: Boolean = false
    ): List<WidgetTask>? {
        if (raw.isNullOrBlank()) return null

        val source = runCatching { JSONArray(raw) }.getOrNull() ?: return null
        val tasks = mutableListOf<WidgetTask>()
        for (index in 0 until source.length()) {
            val item = source.optJSONObject(index) ?: continue
            val task = if (fromTaskStore) {
                WidgetTask.fromTaskJson(item)
            } else {
                WidgetTask.fromWidgetJson(item)
            }
            if (showCompleted || !task.isCompleted) {
                tasks.add(task)
            }
        }

        return tasks
            .sortedWith(
                compareBy<WidgetTask> { if (it.isCompleted) 1 else 0 }
                    .thenBy { it.dueDateTime ?: LocalDateTime.MAX }
            )
            .take(taskLimit.coerceIn(1, 10))
    }

    private fun readSettings(prefs: SharedPreferences): WidgetSettings {
        val raw = prefs.getString(SETTINGS_KEY, null) ?: return WidgetSettings()
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return WidgetSettings()
        return WidgetSettings(
            showCompleted = json.optBoolean("widgetShowsCompleted", false),
            taskLimit = json.optInt("widgetTaskLimit", 5).coerceIn(1, 10),
            compact = json.optBoolean("compactWidget", false)
        )
    }

    private fun flutterPreferences(context: Context): SharedPreferences =
        context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)

    private fun setStrike(row: RemoteViews, viewId: Int, enabled: Boolean) {
        val flags = Paint.ANTI_ALIAS_FLAG or if (enabled) {
            Paint.STRIKE_THRU_TEXT_FLAG
        } else {
            0
        }
        row.setInt(viewId, "setPaintFlags", flags)
    }

    private data class WidgetSettings(
        val showCompleted: Boolean = false,
        val taskLimit: Int = 5,
        val compact: Boolean = false
    )

    private data class WidgetTask(
        val id: String,
        val title: String,
        val time: String,
        val category: String,
        val status: String,
        val isCompleted: Boolean,
        val dueDateTime: LocalDateTime?
    ) {
        companion object {
            fun fromWidgetJson(json: JSONObject): WidgetTask {
                val status = json.optString("status", STATUS_ACTIVE)
                return WidgetTask(
                    id = json.optString("id"),
                    title = json.optString("title"),
                    time = json.optString("time"),
                    category = json.optString("category"),
                    status = status,
                    isCompleted = json.optBoolean(
                        "isCompleted",
                        status == STATUS_COMPLETED || status == STATUS_ARCHIVED
                    ),
                    dueDateTime = null
                )
            }

            fun fromTaskJson(json: JSONObject): WidgetTask {
                val dueDateTime = dueDateTimeOf(json)
                val storedStatus = json.optString("status", STATUS_ACTIVE)
                val completed = json.optBoolean("isArchived", false) ||
                    storedStatus == STATUS_COMPLETED ||
                    storedStatus == STATUS_ARCHIVED
                val status = when {
                    json.optBoolean("isArchived", false) -> STATUS_ARCHIVED
                    storedStatus == STATUS_COMPLETED -> STATUS_COMPLETED
                    dueDateTime?.isBefore(LocalDateTime.now()) == true -> STATUS_OVERDUE
                    else -> STATUS_ACTIVE
                }
                return WidgetTask(
                    id = json.optString("id"),
                    title = json.optString("title"),
                    time = if (status == STATUS_OVERDUE) {
                        "Проср."
                    } else {
                        formatTime(json.optString("dueTime", "9:0"))
                    },
                    category = json.optJSONObject("category")?.optString("name").orEmpty(),
                    status = status,
                    isCompleted = completed,
                    dueDateTime = dueDateTime
                )
            }

            fun dueDateTimeOf(json: JSONObject): LocalDateTime? {
                val dueDate = runCatching {
                    LocalDateTime.parse(json.optString("dueDate"))
                }.getOrNull() ?: return null
                val parts = json.optString("dueTime", "9:0").split(":")
                val hour = parts.getOrNull(0)?.toIntOrNull() ?: 9
                val minute = parts.getOrNull(1)?.toIntOrNull() ?: 0
                return dueDate.withHour(hour).withMinute(minute).withSecond(0).withNano(0)
            }

            private fun formatTime(value: String): String {
                val parts = value.split(":")
                val hour = parts.getOrNull(0)?.toIntOrNull() ?: 9
                val minute = parts.getOrNull(1)?.toIntOrNull() ?: 0
                return "%02d:%02d".format(hour, minute)
            }
        }
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val TASKS_KEY = "flutter.qdone.tasks.v1"
        private const val SETTINGS_KEY = "flutter.qdone.settings.v1"
        private const val WIDGET_TITLE_KEY = "widget_title"
        private const val WIDGET_TASKS_JSON_KEY = "widget_tasks_json"
        private const val STATUS_ACTIVE = "active"
        private const val STATUS_OVERDUE = "overdue"
        private const val STATUS_COMPLETED = "completed"
        private const val STATUS_ARCHIVED = "archived"
    }
}
