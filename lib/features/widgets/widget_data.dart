import 'dart:convert';
import 'dart:math' as math;

/// How the home-screen widgets color today's progress.
///
/// Persisted to `user_profile.widgetColorMode`. Surfaced to the user as a
/// toggle in the You page ("Buddy & look"). Pure data — no Flutter import —
/// so the color math is unit-testable in isolation.
enum WidgetColorMode {
  /// Fade red → yellow → green as the day's completion ratio climbs.
  progressive('progressive'),

  /// Always the user's primary color, regardless of completion.
  primary('primary');

  const WidgetColorMode(this.id);
  final String id;

  static WidgetColorMode fromId(String? id) {
    for (final m in WidgetColorMode.values) {
      if (m.id == id) return m;
    }
    return WidgetColorMode.primary;
  }
}

/// Resolves the ARGB progress color for a completion ratio in [0, 1].
///
/// In [WidgetColorMode.primary] this is just [primaryColor]. In
/// [WidgetColorMode.progressive] it interpolates hue along the HSV wheel
/// from red (0°) through yellow (60°) to green (120°) — saturation and
/// value held high so it reads as a confident traffic-light gradient. The
/// returned int is fully opaque (alpha 0xFF).
int resolveProgressColor({
  required double pct,
  required WidgetColorMode mode,
  required int primaryColor,
}) {
  if (mode == WidgetColorMode.primary) {
    // Force opaque so the native widget never paints a translucent bar.
    return 0xFF000000 | (primaryColor & 0x00FFFFFF);
  }
  final p = pct.clamp(0.0, 1.0);
  final hue = 120.0 * p; // 0 = red, 120 = green
  return _hsvToArgb(hue, 0.78, 0.85);
}

/// Minimal HSV→ARGB used by the progressive gradient. [h] in degrees
/// [0, 360), [s] and [v] in [0, 1]. Returns an opaque ARGB int.
int _hsvToArgb(double h, double s, double v) {
  final c = v * s;
  final x = c * (1 - (((h / 60.0) % 2) - 1).abs());
  final m = v - c;
  double r;
  double g;
  double b;
  if (h < 60) {
    r = c;
    g = x;
    b = 0;
  } else if (h < 120) {
    r = x;
    g = c;
    b = 0;
  } else if (h < 180) {
    r = 0;
    g = c;
    b = x;
  } else if (h < 240) {
    r = 0;
    g = x;
    b = c;
  } else if (h < 300) {
    r = x;
    g = 0;
    b = c;
  } else {
    r = c;
    g = 0;
    b = x;
  }
  int ch(double f) => ((f + m) * 255).round().clamp(0, 255);
  return (0xFF << 24) | (ch(r) << 16) | (ch(g) << 8) | ch(b);
}

/// Immutable snapshot of everything the native widgets need to render. The
/// app computes one of these on every data change and ships it to the
/// platform via [HomeWidget.saveWidgetData] using [toEntries].
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.buddyAsset,
    required this.doneCount,
    required this.totalCount,
    required this.progressColor,
    required this.trackColor,
    required this.circleColor,
    required this.accentColor,
    required this.bgColor,
    required this.onBgColor,
    required this.showCount,
    required this.pendingHabits,
  });

  /// Flutter asset path of the buddy sprite (e.g.
  /// `assets/buddies/fox/stages/stage_3.png`). Native resolves it to a
  /// lookup key via the Flutter loader.
  final String buddyAsset;
  final int doneCount;
  final int totalCount;

  /// Resolved (already mode-aware) progress fill color, ARGB.
  final int progressColor;

  /// Track / unfilled color for the bar and ring, ARGB.
  final int trackColor;

  /// Circle background behind the buddy sprite, ARGB.
  final int circleColor;

  /// Solid accent (the user's primary), ARGB. Used for the big widget's
  /// Done buttons regardless of completion color.
  final int accentColor;

  /// Big-widget card background, following the app's composed background
  /// (light / dark / tinted), ARGB opaque.
  final int bgColor;

  /// On-background text color for the big widget (legible on [bgColor]).
  final int onBgColor;

  /// Whether to draw the "done/total" count. When false the progress bar /
  /// ring is centered with no label.
  final bool showCount;

  /// Not-done habits, in display order, for the big widget's list.
  final List<({String id, String name})> pendingHabits;

  /// 0..100 completion percentage (integer, clamped).
  int get pct {
    if (totalCount <= 0) return 0;
    return ((doneCount / totalCount) * 100).round().clamp(0, 100);
  }

  /// Key/value pairs for `HomeWidget.saveWidgetData`. Kept stringly-typed
  /// and flat so the native `SharedPreferences` read is trivial. Habit
  /// names are JSON-encoded; everything else is a scalar.
  Map<String, Object> toEntries() => {
        widgetKeyBuddyAsset: buddyAsset,
        widgetKeyDone: doneCount,
        widgetKeyTotal: totalCount,
        widgetKeyPct: pct,
        widgetKeyProgressColor: progressColor,
        widgetKeyTrackColor: trackColor,
        widgetKeyCircleColor: circleColor,
        widgetKeyAccentColor: accentColor,
        widgetKeyBgColor: bgColor,
        widgetKeyOnBgColor: onBgColor,
        widgetKeyShowCount: showCount ? 1 : 0,
        widgetKeyHabits: jsonEncode([
          for (final h in pendingHabits) {'id': h.id, 'name': h.name},
        ]),
      };
}

// --- shared key + name constants (must match the Kotlin side) -------------

const String widgetKeyBuddyAsset = 'wb_buddy_asset';
const String widgetKeyDone = 'wb_done';
const String widgetKeyTotal = 'wb_total';
const String widgetKeyPct = 'wb_pct';
const String widgetKeyProgressColor = 'wb_progress_color';
const String widgetKeyTrackColor = 'wb_track_color';
const String widgetKeyCircleColor = 'wb_circle_color';
const String widgetKeyAccentColor = 'wb_accent_color';
const String widgetKeyBgColor = 'wb_bg_color';
const String widgetKeyOnBgColor = 'wb_on_bg_color';
const String widgetKeyShowCount = 'wb_show_count';
const String widgetKeyHabits = 'wb_habits';

/// Android provider class names (relative to the app package). Used by
/// `HomeWidget.updateWidget(androidName: ...)`.
const String widgetSmallName = 'SmallHabitWidgetProvider';
const String widgetBigName = 'BigHabitWidgetProvider';
const String widgetTinyName = 'TinyHabitWidgetProvider';

/// Background-callback URI scheme/host used by the big widget's Done
/// buttons. The query param `id` carries the habit id.
const String widgetDoneHost = 'done';
const String widgetScheme = 'positivebuddy';

/// Parses a habit id out of a Done-button callback URI, or null if the URI
/// isn't a done action. Pure so it can be unit-tested without a platform.
String? parseDoneHabitId(Uri? uri) {
  if (uri == null) return null;
  if (uri.host != widgetDoneHost) return null;
  final id = uri.queryParameters['id'];
  if (id == null || id.isEmpty) return null;
  return id;
}

/// Clamp helper kept here so both the service and tests agree on the cap
/// for how many pending habits we ship to the big widget. The launcher
/// clips overflow, but we cap to stay under RemoteViews' action budget.
int cappedHabitCount(int n) => math.min(n, maxWidgetHabits);
const int maxWidgetHabits = 12;
