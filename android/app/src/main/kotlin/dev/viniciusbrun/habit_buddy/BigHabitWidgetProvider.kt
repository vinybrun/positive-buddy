package dev.viniciusbrun.habit_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.res.ColorStateList
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * Big (3x2..4x6): the small-widget header (buddy + progress bar) followed by
 * a list of not-done habits, each with a Done button. Done taps fire a
 * `home_widget` background intent that the Dart side logs and re-renders.
 */
class BigHabitWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val SCHEME = "positivebuddy"
        private const val HOST = "done"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        for (id in appWidgetIds) render(context, appWidgetManager, id)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        render(context, appWidgetManager, appWidgetId)
    }

    private fun render(context: Context, mgr: AppWidgetManager, id: Int) {
        val density = context.resources.displayMetrics.density
        val (w, h) = WidgetRender.sizePx(context, mgr, id, 320, 320)
        val data = WidgetRender.read(context)

        val views = RemoteViews(context.packageName, R.layout.widget_big)

        // Card background follows the app's composed background. It's a
        // pre-colored rounded bitmap (NOT a runtime-tinted white shape): on a
        // launcher re-inflation the only intermediate is the empty (transparent)
        // ImageView, so the card never flashes white before a tint lands.
        views.setImageViewBitmap(
            R.id.big_bg,
            WidgetRender.roundedCard(w, h, data.bgColor, 20f, density),
        )

        // Header bitmap sized to the padded content width and the 76dp band.
        val padPx = (10 * density * 2).toInt()
        val headerW = (w - padPx).coerceAtLeast(48)
        val headerH = (76 * density).toInt()
        views.setImageViewBitmap(
            R.id.big_header,
            WidgetRender.composite(context, data, headerW, headerH, data.onBgColor),
        )
        // Only the header (buddy + progress bar) opens the app; the rows
        // below own their own Done-button taps. Use the current launcher
        // alias, not MainActivity (which the icon swap disables).
        views.setOnClickPendingIntent(R.id.big_header, WidgetRender.launchIntent(context))

        views.removeAllViews(R.id.big_list)
        val habits = parseHabits(context)
        if (habits.isEmpty()) {
            val empty = RemoteViews(context.packageName, R.layout.widget_empty_row)
            empty.setTextColor(R.id.empty_text, data.onBgColor)
            views.addView(R.id.big_list, empty)
        } else {
            for (habit in habits) {
                val row = RemoteViews(context.packageName, R.layout.widget_habit_row)
                row.setTextViewText(R.id.row_name, habit.second)
                row.setTextColor(R.id.row_name, data.onBgColor)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    row.setColorStateList(
                        R.id.row_done,
                        "setBackgroundTintList",
                        ColorStateList.valueOf(data.accentColor),
                    )
                }
                // Distinct data Uri per habit → distinct PendingIntent.
                val uri = Uri.parse("$SCHEME://$HOST?id=${Uri.encode(habit.first)}")
                row.setOnClickPendingIntent(
                    R.id.row_done,
                    HomeWidgetBackgroundIntent.getBroadcast(context, uri),
                )
                views.addView(R.id.big_list, row)
            }
        }
        mgr.updateAppWidget(id, views)
    }

    /** Reads the not-done habits JSON the Dart side stashed. */
    private fun parseHabits(context: Context): List<Pair<String, String>> {
        val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        val raw = prefs.getString("wb_habits", "[]") ?: "[]"
        return try {
            val arr = JSONArray(raw)
            val out = ArrayList<Pair<String, String>>(arr.length())
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                val hid = o.optString("id")
                val name = o.optString("name")
                if (hid.isNotEmpty()) out.add(Pair(hid, name))
            }
            out
        } catch (e: Exception) {
            emptyList()
        }
    }
}
