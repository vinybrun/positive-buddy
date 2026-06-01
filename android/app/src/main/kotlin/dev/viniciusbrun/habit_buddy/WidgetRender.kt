package dev.viniciusbrun.habit_buddy

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.os.Bundle
import kotlin.math.max
import kotlin.math.min

/**
 * Pixel-perfect drawing for the three home-screen widgets. Everything the
 * widgets show visually (circular buddy, gradient progress bar, progress
 * ring) is rasterized here at the widget's real size — passed down from the
 * provider via the AppWidget options bundle — so resizing never distorts a
 * rounded corner or the ring.
 *
 * Data (colors, percent, buddy asset path) comes from the SharedPreferences
 * that `home_widget` writes; keys mirror the Dart `widget_data.dart`.
 */
object WidgetRender {
    // Keys — keep in sync with lib/features/widgets/widget_data.dart.
    private const val KEY_BUDDY = "wb_buddy_asset"
    private const val KEY_DONE = "wb_done"
    private const val KEY_TOTAL = "wb_total"
    private const val KEY_PCT = "wb_pct"
    private const val KEY_PROGRESS = "wb_progress_color"
    private const val KEY_TRACK = "wb_track_color"
    private const val KEY_CIRCLE = "wb_circle_color"
    private const val KEY_ACCENT = "wb_accent_color"
    private const val KEY_BG = "wb_bg_color"
    private const val KEY_ON_BG = "wb_on_bg_color"
    private const val KEY_SHOW_COUNT = "wb_show_count"

    data class Data(
        val buddyAsset: String?,
        val done: Int,
        val total: Int,
        val pct: Int,
        val progressColor: Int,
        val trackColor: Int,
        val circleColor: Int,
        val accentColor: Int,
        val bgColor: Int,
        val onBgColor: Int,
        val showCount: Boolean,
    )

    fun read(context: Context): Data {
        val p = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        return Data(
            buddyAsset = p.getString(KEY_BUDDY, null),
            done = p.getInt(KEY_DONE, 0),
            total = p.getInt(KEY_TOTAL, 0),
            pct = p.getInt(KEY_PCT, 0),
            // getInt fails if home_widget stored as long; fall back via try.
            progressColor = colorPref(p, KEY_PROGRESS, 0xFF4C6FFF.toInt()),
            trackColor = colorPref(p, KEY_TRACK, 0x33FFFFFF),
            circleColor = colorPref(p, KEY_CIRCLE, 0xFF26252B.toInt()),
            accentColor = colorPref(p, KEY_ACCENT, 0xFF4C6FFF.toInt()),
            bgColor = colorPref(p, KEY_BG, 0xFF1C1B1F.toInt()),
            onBgColor = colorPref(p, KEY_ON_BG, 0xFFFFFFFF.toInt()),
            showCount = p.getInt(KEY_SHOW_COUNT, 1) != 0,
        )
    }

    private fun colorPref(
        p: android.content.SharedPreferences,
        key: String,
        def: Int,
    ): Int {
        // home_widget saves Dart ints as Long in SharedPreferences.
        return try {
            p.getLong(key, def.toLong()).toInt()
        } catch (e: ClassCastException) {
            try {
                p.getInt(key, def)
            } catch (e2: Exception) {
                def
            }
        }
    }

    // ---- sizing --------------------------------------------------------

    /** Portrait pixel size of the widget instance, with sane fallbacks. */
    fun sizePx(
        context: Context,
        mgr: AppWidgetManager,
        widgetId: Int,
        fallbackWdp: Int,
        fallbackHdp: Int,
    ): Pair<Int, Int> {
        val density = context.resources.displayMetrics.density
        val opts: Bundle? = mgr.getAppWidgetOptions(widgetId)
        var wdp = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
        var hdp = opts?.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0) ?: 0
        if (wdp <= 0) wdp = fallbackWdp
        if (hdp <= 0) hdp = fallbackHdp
        val w = (wdp * density).toInt().coerceIn(48, 1600)
        val h = (hdp * density).toInt().coerceIn(40, 1600)
        return Pair(w, h)
    }

    // ---- launch --------------------------------------------------------

    /**
     * A PendingIntent that opens the app's CURRENT launcher activity. We
     * can't target MainActivity explicitly: the stage-aware icon swap
     * disables it in favor of a per-buddy alias (e.g. MainActivityButterfly),
     * so an explicit MainActivity intent would resolve to nothing.
     * getLaunchIntentForPackage picks whichever LAUNCHER alias is enabled.
     */
    fun launchIntent(context: Context): PendingIntent {
        val intent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?: Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
                setPackage(context.packageName)
            }
        intent.flags =
            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getActivity(context, 0, intent, flags)
    }

    // ---- backgrounds ---------------------------------------------------

    /**
     * A rounded-rect card filled with [color], drawn straight into a bitmap
     * at the widget's real px size. Used as the big widget's background so a
     * re-inflation can never flash white the way a runtime-tinted white shape
     * can — the only intermediate is the (transparent) empty ImageView.
     */
    fun roundedCard(w: Int, h: Int, color: Int, radiusDp: Float, density: Float): Bitmap {
        val out = Bitmap.createBitmap(
            w.coerceAtLeast(1),
            h.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888,
        )
        val c = Canvas(out)
        val r = radiusDp * density
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = color
        c.drawRoundRect(RectF(0f, 0f, w.toFloat(), h.toFloat()), r, r, paint)
        return out
    }

    // ---- buddy ---------------------------------------------------------

    /** Loads a bundled Flutter asset (e.g. assets/buddies/fox/idle.png). */
    fun loadBuddy(context: Context, assetPath: String?): Bitmap? {
        if (assetPath.isNullOrEmpty()) return null
        return try {
            context.assets.open("flutter_assets/$assetPath").use {
                BitmapFactory.decodeStream(it)
            }
        } catch (e: Exception) {
            null
        }
    }

    /** A center-cropped circular buddy on a [circleColor] disc, [size] px. */
    fun circularBuddy(buddy: Bitmap?, size: Int, circleColor: Int): Bitmap {
        val out = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val c = Canvas(out)
        val r = size / 2f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = circleColor
        c.drawCircle(r, r, r, paint)
        if (buddy != null) {
            c.save()
            val clip = Path().apply { addCircle(r, r, r, Path.Direction.CW) }
            c.clipPath(clip)
            // cover: scale so the shorter side fills, center-crop.
            val scale = max(size.toFloat() / buddy.width, size.toFloat() / buddy.height)
            val dw = (buddy.width * scale)
            val dh = (buddy.height * scale)
            val left = (size - dw) / 2f
            val top = (size - dh) / 2f
            val dst = RectF(left, top, left + dw, top + dh)
            c.drawBitmap(buddy, null, dst, Paint(Paint.FILTER_BITMAP_FLAG))
            c.restore()
        }
        return out
    }

    // ---- composites ----------------------------------------------------

    /**
     * Small widget / big-widget header: circular buddy on the left, a
     * "done/total" count and a rounded gradient progress bar on the right.
     */
    fun composite(context: Context, d: Data, w: Int, h: Int, textColor: Int): Bitmap {
        val out = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(out)
        val pad = (h * 0.12f).coerceIn(6f, 22f)
        val diameter = (h - pad * 2).toInt().coerceAtLeast(8)

        val buddy = loadBuddy(context, d.buddyAsset)
        val circle = circularBuddy(buddy, diameter, d.circleColor)
        c.drawBitmap(circle, pad, pad, null)

        val rightX = pad + diameter + pad
        val rightW = w - rightX - pad
        if (rightW > 24) {
            val barH = (h * 0.16f).coerceIn(8f, 26f)
            if (d.showCount) {
                val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = textColor
                    textSize = (h * 0.22f).coerceIn(13f, 40f)
                    isFakeBoldText = true
                }
                val label = "${d.done}/${d.total}"
                val gap = (h * 0.10f).coerceIn(4f, 16f)
                val fm = text.fontMetrics
                val textH = fm.descent - fm.ascent
                val blockH = textH + gap + barH
                val top = (h - blockH) / 2f
                val baseline = top - fm.ascent
                c.drawText(label, rightX, baseline, text)
                val barTop = top + textH + gap
                drawBar(c, rightX, barTop, rightW, barH, d.pct, d.progressColor, d.trackColor)
            } else {
                // No count — vertically center the bar.
                val barTop = (h - barH) / 2f
                drawBar(c, rightX, barTop, rightW, barH, d.pct, d.progressColor, d.trackColor)
            }
        }
        return out
    }

    private fun drawBar(
        c: Canvas,
        x: Float,
        y: Float,
        w: Float,
        h: Float,
        pct: Int,
        fill: Int,
        track: Int,
    ) {
        val r = h / 2f
        val p = Paint(Paint.ANTI_ALIAS_FLAG)
        p.color = track
        c.drawRoundRect(RectF(x, y, x + w, y + h), r, r, p)
        val ratio = pct.coerceIn(0, 100) / 100f
        if (ratio > 0f) {
            // Keep at least a rounded nub so 1% still reads as "started".
            val fw = max(w * ratio, h)
            p.color = fill
            c.drawRoundRect(RectF(x, y, x + min(fw, w), y + h), r, r, p)
        }
    }

    /** Tiny 1x1: square buddy disc with a progress ring around it. */
    fun tiny(context: Context, d: Data, size: Int): Bitmap {
        val out = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val c = Canvas(out)
        val stroke = (size * 0.09f).coerceIn(5f, 26f)
        val pad = stroke * 0.5f
        val cx = size / 2f
        val ringRect = RectF(
            stroke / 2f + pad,
            stroke / 2f + pad,
            size - stroke / 2f - pad,
            size - stroke / 2f - pad,
        )
        val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }
        // Track (full circle) then progress arc from the top.
        ringPaint.color = d.trackColor
        c.drawArc(ringRect, 0f, 360f, false, ringPaint)
        val sweep = d.pct.coerceIn(0, 100) / 100f * 360f
        if (sweep > 0f) {
            ringPaint.color = d.progressColor
            c.drawArc(ringRect, -90f, sweep, false, ringPaint)
        }
        // Buddy disc inside the ring.
        val inner = (ringRect.width() - stroke * 1.4f).toInt().coerceAtLeast(8)
        val buddy = loadBuddy(context, d.buddyAsset)
        val circle = circularBuddy(buddy, inner, d.circleColor)
        c.drawBitmap(circle, cx - inner / 2f, cx - inner / 2f, null)
        return out
    }
}
