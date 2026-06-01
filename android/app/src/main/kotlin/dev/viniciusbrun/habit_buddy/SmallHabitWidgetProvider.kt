package dev.viniciusbrun.habit_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Small (2x1..4x1): circular buddy + today's progress bar, one bitmap. */
class SmallHabitWidgetProvider : HomeWidgetProvider() {
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
        val (w, h) = WidgetRender.sizePx(context, mgr, id, 160, 72)
        val data = WidgetRender.read(context)
        val views = RemoteViews(context.packageName, R.layout.widget_small)
        // Small widget is transparent over the wallpaper, so white reads best.
        views.setImageViewBitmap(
            R.id.widget_image,
            WidgetRender.composite(context, data, w, h, Color.WHITE),
        )
        // Whole tile opens the app (current launcher alias, not MainActivity).
        views.setOnClickPendingIntent(R.id.widget_root, WidgetRender.launchIntent(context))
        mgr.updateAppWidget(id, views)
    }
}
