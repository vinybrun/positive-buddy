package dev.viniciusbrun.habit_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.min

/** Tiny (1x1): buddy disc with a progress ring around it. */
class TinyHabitWidgetProvider : HomeWidgetProvider() {
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
        val (w, h) = WidgetRender.sizePx(context, mgr, id, 80, 80)
        val size = min(w, h)
        val data = WidgetRender.read(context)
        val views = RemoteViews(context.packageName, R.layout.widget_tiny)
        views.setImageViewBitmap(R.id.widget_image, WidgetRender.tiny(context, data, size))
        // Whole tile opens the app (current launcher alias, not MainActivity).
        views.setOnClickPendingIntent(R.id.widget_root, WidgetRender.launchIntent(context))
        mgr.updateAppWidget(id, views)
    }
}
