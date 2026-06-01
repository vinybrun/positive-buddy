package dev.viniciusbrun.habit_buddy

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val LAUNCHER_CHANNEL = "habit_buddy/launcher_icon"
        private const val PRESENCE_CHANNEL = "habit_buddy/presence"

        // Static-species aliases (one icon each). Full component name is
        // `${packageName}.${suffix}`. Keep in sync with AndroidManifest.xml.
        private val STATIC_ALIASES = mapOf(
            "cat" to "MainActivityCat",
            "dog" to "MainActivityDog",
            "butterfly" to "MainActivityButterfly",
        )

        // Evolving species: one alias per stage (1..5), suffix
        // `MainActivity<Cap>S<n>`. The Dart layer passes a 0-indexed stage;
        // we map it to the 1-indexed alias, clamped to the available range.
        private val STAGED_SPECIES = mapOf(
            "fox" to "MainActivityFox",
            "snake" to "MainActivitySnake",
            "bird" to "MainActivityBird",
        )
        private const val STAGE_COUNT = 5

        // Every togglable alias component simple-name — used to disable all
        // the ones we aren't switching to.
        private val ALL_ALIASES: List<String> =
            STATIC_ALIASES.values.toList() +
                STAGED_SPECIES.values.flatMap { base ->
                    (1..STAGE_COUNT).map { "${base}S$it" }
                }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LAUNCHER_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setIcon" -> {
                    val buddyId = call.argument<String?>("buddyId")
                    val stage = call.argument<Int?>("stage") ?: 0
                    try {
                        setAlternateIcon(buddyId, stage)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("set_icon_failed", e.message, null)
                    }
                }
                "pinWidget" -> {
                    // Debug-only: ask the launcher to pin one of our app
                    // widgets so we can exercise it without manual placement.
                    val provider = call.argument<String?>("provider")
                    result.success(requestPin(provider))
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PRESENCE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isInteractive" -> {
                    val pm = applicationContext
                        .getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(pm.isInteractive)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPin(simpleName: String?): Boolean {
        if (simpleName == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        val awm = getSystemService(AppWidgetManager::class.java) ?: return false
        if (!awm.isRequestPinAppWidgetSupported) return false
        val provider = ComponentName(packageName, "$packageName.$simpleName")
        return awm.requestPinAppWidget(provider, null, null)
    }

    /**
     * Enable the activity-alias matching [buddyId] at evolution [stage] and
     * disable every other one. For evolving species the alias is the
     * per-stage variant (`MainActivity<Cap>S<n>`); for static species it's
     * the single per-buddy alias. Passing null (or an unknown id) falls
     * back to the default MainActivity icon.
     *
     * Note: changing component-enabled state causes the launcher to
     * refresh its icon list, which on most launchers (including MIUI /
     * HyperOS) briefly closes the home screen. That's inherent to this
     * technique — there's no Android API to swap an icon without a
     * launcher refresh.
     */
    private fun setAlternateIcon(buddyId: String?, stage: Int) {
        val pm = packageManager
        val pkg = packageName

        // Resolve the single alias we want enabled (null = default icon).
        val target: String? = when {
            buddyId == null -> null
            STAGED_SPECIES.containsKey(buddyId) -> {
                val n = (stage + 1).coerceIn(1, STAGE_COUNT)
                "${STAGED_SPECIES[buddyId]}S$n"
            }
            STATIC_ALIASES.containsKey(buddyId) -> STATIC_ALIASES[buddyId]
            else -> null
        }

        for (suffix in ALL_ALIASES) {
            val state = if (suffix == target) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            pm.setComponentEnabledSetting(
                ComponentName(pkg, "$pkg.$suffix"),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }
        // The default MainActivity stays as the LAUNCHER intent target so
        // app-link behavior is preserved; whether its icon shows on the
        // home screen depends on which alias (if any) is enabled. When no
        // alias is targeted we re-enable MainActivity so its icon is used.
        pm.setComponentEnabledSetting(
            ComponentName(pkg, "$pkg.MainActivity"),
            if (target == null) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            },
            PackageManager.DONT_KILL_APP,
        )
    }
}
