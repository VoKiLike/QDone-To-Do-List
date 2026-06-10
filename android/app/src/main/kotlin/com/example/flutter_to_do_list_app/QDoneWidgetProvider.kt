package com.volkoweb.qdone

import android.app.PendingIntent
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
        views.setImageViewResource(
            R.id.widget_title,
            R.drawable.qdone_widget_brand
        )

        views.setOnClickPendingIntent(
            R.id.widget_open_app,
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("qdone://home")
            )
        )
        views.setOnClickPendingIntent(
            R.id.widget_open_menu,
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("qdone://menu")
            )
        )

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
        val settings = readSettings(prefs, widgetData)
        val palette = WidgetPalette.forTheme(settings.theme)
        val rows = readWidgetTasks(
            raw = widgetData?.getString(WIDGET_TASKS_JSON_KEY, null),
            compact = settings.compact,
            showCompleted = settings.showCompleted,
            taskLimit = settings.taskLimit
        )
            ?: emptyList()

        if (rows.isEmpty()) {
            val emptyRow = RemoteViews(context.packageName, R.layout.qdone_widget_row)
            emptyRow.setTextViewText(R.id.widget_task_time, "")
            emptyRow.setTextViewText(R.id.widget_task_category, "")
            emptyRow.setTextViewText(R.id.widget_task_title, "\u041D\u0435\u0442 \u0431\u043B\u0438\u0436\u0430\u0439\u0448\u0438\u0445 \u0437\u0430\u0434\u0430\u0447")
            emptyRow.setTextViewText(R.id.widget_task_done, "")
            emptyRow.setViewVisibility(R.id.widget_task_done, View.INVISIBLE)
            emptyRow.setBoolean(R.id.widget_task_done, "setEnabled", false)
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
            row.setTextViewText(
                R.id.widget_task_done,
                if (done && item.canToggle) "\u21BA" else "\u2713"
            )

            row.setTextColor(
                R.id.widget_task_time,
                when {
                    done -> palette.success
                    item.status == STATUS_OVERDUE -> palette.warning
                    else -> palette.primary
                }
            )
            row.setTextColor(
                R.id.widget_task_category,
                if (done) palette.completedCategory else palette.secondary
            )
            row.setTextColor(
                R.id.widget_task_title,
                if (done) palette.completedTitle else palette.foreground
            )
            row.setInt(
                R.id.widget_task_done,
                "setBackgroundResource",
                if (done) R.drawable.qdone_widget_restore_button else R.drawable.qdone_widget_done_button
            )
            row.setViewVisibility(
                R.id.widget_task_done,
                if (item.canToggle) View.VISIBLE else View.INVISIBLE
            )
            row.setBoolean(R.id.widget_task_done, "setEnabled", item.canToggle)
            setStrike(row, R.id.widget_task_time, done)
            setStrike(row, R.id.widget_task_category, done)
            setStrike(row, R.id.widget_task_title, done)

            row.setOnClickPendingIntent(
                R.id.widget_task_content,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("qdone://focus/$taskId")
                )
            )
            if (item.canToggle) {
                row.setOnClickPendingIntent(
                    R.id.widget_task_done,
                    toggleIntent(context, taskId)
                )
            }
            views.addView(R.id.widget_rows, row)
        }
    }

    private fun readWidgetTasks(
        raw: String?,
        compact: Boolean,
        showCompleted: Boolean = true,
        taskLimit: Int = if (compact) 6 else 4
    ): List<WidgetTask>? {
        if (raw.isNullOrBlank()) return null

        val source = runCatching { JSONArray(raw) }.getOrNull() ?: return null
        val tasks = mutableListOf<WidgetTask>()
        for (index in 0 until source.length()) {
            val item = source.optJSONObject(index) ?: continue
            val task = WidgetTask.fromWidgetJson(item)
            val visible = showCompleted || !task.isCompleted
            if (visible) {
                tasks.add(task)
            }
        }

        return tasks.take(taskLimit.coerceIn(1, 10))
    }

    private fun readSettings(
        prefs: SharedPreferences,
        widgetData: SharedPreferences?
    ): WidgetSettings {
        val raw = prefs.getString(SETTINGS_KEY, null)
        val json = raw?.let { runCatching { JSONObject(it) }.getOrNull() }
        val storedSettings = if (json == null) {
            WidgetSettings()
        } else {
            WidgetSettings(
                showCompleted = json.optBoolean("widgetShowsCompleted", false),
                taskLimit = json.optInt("widgetTaskLimit", 5).coerceIn(1, 10),
                compact = json.optBoolean("compactWidget", false),
                theme = json.optString("themeMode", THEME_DARK)
            )
        }

        if (widgetData == null) {
            return storedSettings
        }

        return WidgetSettings(
            showCompleted = if (widgetData.contains(WIDGET_SHOW_COMPLETED_KEY)) {
                widgetData.getBoolean(WIDGET_SHOW_COMPLETED_KEY, storedSettings.showCompleted)
            } else {
                storedSettings.showCompleted
            },
            taskLimit = if (widgetData.contains(WIDGET_TASK_LIMIT_KEY)) {
                widgetData.getInt(WIDGET_TASK_LIMIT_KEY, storedSettings.taskLimit).coerceIn(1, 10)
            } else {
                storedSettings.taskLimit
            },
            compact = if (widgetData.contains(WIDGET_COMPACT_KEY)) {
                widgetData.getBoolean(WIDGET_COMPACT_KEY, storedSettings.compact)
            } else {
                storedSettings.compact
            },
            theme = if (widgetData.contains(WIDGET_THEME_KEY)) {
                widgetData.getString(WIDGET_THEME_KEY, storedSettings.theme)
                    ?: storedSettings.theme
            } else {
                storedSettings.theme
            }
        )
    }

    private fun flutterPreferences(context: Context): SharedPreferences =
        context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)

    private fun toggleIntent(context: Context, taskId: String): PendingIntent {
        return HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("qdone://toggle/$taskId")
        )
    }

    private fun setStrike(row: RemoteViews, viewId: Int, enabled: Boolean) {
        val flags = if (enabled) {
            Paint.ANTI_ALIAS_FLAG or Paint.STRIKE_THRU_TEXT_FLAG
        } else {
            Paint.ANTI_ALIAS_FLAG
        }
        row.setInt(viewId, "setPaintFlags", flags)
    }

    private data class WidgetSettings(
        val showCompleted: Boolean = false,
        val taskLimit: Int = 5,
        val compact: Boolean = false,
        val theme: String = THEME_DARK
    )

    private data class WidgetPalette(
        val primary: Int,
        val secondary: Int,
        val warning: Int,
        val success: Int,
        val foreground: Int,
        val completedTitle: Int,
        val completedCategory: Int
    ) {
        companion object {
            fun forTheme(theme: String): WidgetPalette = when (theme) {
                THEME_INDIGO -> WidgetPalette(
                    primary = Color.rgb(169, 140, 245),
                    secondary = Color.rgb(192, 132, 252),
                    warning = Color.rgb(243, 166, 107),
                    success = Color.rgb(103, 215, 178),
                    foreground = Color.rgb(247, 243, 252),
                    completedTitle = Color.rgb(195, 185, 216),
                    completedCategory = Color.rgb(169, 140, 245)
                )
                THEME_TURQUOISE -> WidgetPalette(
                    primary = Color.rgb(82, 211, 206),
                    secondary = Color.rgb(88, 180, 207),
                    warning = Color.rgb(241, 162, 97),
                    success = Color.rgb(97, 213, 169),
                    foreground = Color.rgb(240, 249, 250),
                    completedTitle = Color.rgb(169, 196, 201),
                    completedCategory = Color.rgb(101, 214, 168)
                )
                else -> WidgetPalette(
                    primary = Color.rgb(85, 196, 238),
                    secondary = Color.rgb(136, 116, 241),
                    warning = Color.rgb(242, 160, 91),
                    success = Color.rgb(93, 214, 172),
                    foreground = Color.rgb(243, 246, 252),
                    completedTitle = Color.rgb(173, 184, 208),
                    completedCategory = Color.rgb(160, 120, 232)
                )
            }
        }
    }

    private data class WidgetTask(
        val id: String,
        val title: String,
        val time: String,
        val category: String,
        val status: String,
        val isCompleted: Boolean,
        val canToggle: Boolean = true
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
                    canToggle = json.optBoolean("canToggle", true)
                )
            }
        }
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val SETTINGS_KEY = "flutter.qdone.settings.v1"
        private const val WIDGET_TASKS_JSON_KEY = "widget_tasks_json"
        private const val WIDGET_SHOW_COMPLETED_KEY = "widget_show_completed"
        private const val WIDGET_TASK_LIMIT_KEY = "widget_task_limit"
        private const val WIDGET_COMPACT_KEY = "widget_compact"
        private const val WIDGET_THEME_KEY = "widget_theme"
        private const val STATUS_ACTIVE = "active"
        private const val STATUS_OVERDUE = "overdue"
        private const val STATUS_COMPLETED = "completed"
        private const val STATUS_ARCHIVED = "archived"
        private const val THEME_DARK = "dark"
        private const val THEME_INDIGO = "indigo"
        private const val THEME_TURQUOISE = "turquoise"
    }
}
