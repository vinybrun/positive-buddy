import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/profile_repository.dart';
import '../../features/buddy_progress/buddy_progress_repository.dart';
import '../../theme/app_theme.dart' show composeBackground, brightnessForBackground;
import '../../theme/buddy.dart';
import '../../theme/buddy_asset.dart';
import '../../theme/buddy_themes.dart';
import '../../theme/theme_palettes.dart';
import '../notifications/local_notification_service.dart' show notificationRefreshPortName;
import 'widget_data.dart';

/// Keeps the three home-screen widgets in sync with today's habit state.
///
/// The foreground app holds one long-lived instance (started from `main`)
/// that listens to the habit / log / profile streams and re-pushes a
/// [WidgetSnapshot] on every change. The same render path is reused by the
/// background interactivity callback ([widgetInteractivityCallback]) after a
/// Done button is tapped, so the widget reflects the new state immediately
/// even when the app isn't running.
class HomeWidgetService {
  HomeWidgetService(this._db);
  final AppDb _db;

  final _subs = <StreamSubscription<dynamic>>[];
  Timer? _debounce;
  bool _started = false;

  /// When the background Done handler renders the widgets itself it pings the
  /// foreground (see [notifyExternalRender]). The Drift streams then re-fire
  /// for that same write ~250ms later and would push an identical snapshot —
  /// a second, redundant launcher re-inflation (the "double blink"). We record
  /// when that external render happened and skip the next debounced push if it
  /// falls inside this window. This only suppresses the duplicate Dart-side
  /// push; the background isolate's native redraw is never skipped.
  DateTime? _externalRenderAt;
  static const _externalRenderTtl = Duration(milliseconds: 1500);

  /// Begin watching for changes. Idempotent.
  void start() {
    if (_started) return;
    _started = true;
    // These streams re-emit on any relevant write (including the BG
    // isolate's, since drift watches the file). We coalesce bursts with a
    // short debounce so a multi-row transaction pushes once.
    _subs.add(
      (_db.select(_db.habits)
            ..where((h) =>
                h.active.equals(true) &
                h.deletedAt.isNull() &
                h.completedAt.isNull()))
          .watch()
          .listen((_) => _schedule()),
    );
    _subs.add(_db.select(_db.notificationLog).watch().listen((_) => _schedule()));
    _subs.add(
      (_db.select(_db.userProfileTable)..limit(1))
          .watch()
          .listen((_) => _schedule()),
    );
    _subs.add(_db.select(_db.buddyProgress).watch().listen((_) => _schedule()));
    // Initial paint.
    _schedule(immediate: true);
  }

  /// Mark that the background isolate just rendered the widgets for a Done
  /// tap. Called from the foreground port listener (main.dart) the moment the
  /// BG handler pings. The next debounced render for that same write is then
  /// skipped, so the launcher blinks once (the BG render) instead of twice.
  void notifyExternalRender() {
    debugPrint('WB_DBG notifyExternalRender t=${DateTime.now().millisecondsSinceEpoch}');
    _externalRenderAt = DateTime.now();
  }

  void _schedule({bool immediate = false}) {
    _debounce?.cancel();
    if (immediate) {
      debugPrint('WB_DBG fg render immediate t=${DateTime.now().millisecondsSinceEpoch}');
      unawaited(render(_db));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () {
      // If the BG isolate already rendered this exact state moments ago, drop
      // this duplicate push (consume the flag so later real changes still
      // render). The native redraw the BG isolate did already stands.
      final ext = _externalRenderAt;
      if (ext != null && DateTime.now().difference(ext) < _externalRenderTtl) {
        _externalRenderAt = null;
        debugPrint('WB_DBG fg render SUPPRESSED t=${DateTime.now().millisecondsSinceEpoch}');
        return;
      }
      debugPrint('WB_DBG fg render stream t=${DateTime.now().millisecondsSinceEpoch}');
      unawaited(render(_db));
    });
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _started = false;
  }

  /// Reads the current state straight from [db], builds a [WidgetSnapshot],
  /// ships it to the platform, and refreshes all three widgets. Static so
  /// the background callback can reuse it with a freshly-opened db.
  static Future<void> render(AppDb db) async {
    debugPrint('WB_DBG render() ENTER t=${DateTime.now().millisecondsSinceEpoch}');
    final snap = await buildSnapshot(db);
    for (final entry in snap.toEntries().entries) {
      await HomeWidget.saveWidgetData<Object>(entry.key, entry.value);
    }
    // NOTE: each provider always calls updateAppWidget — no native dedupe.
    // A static last-signature skip was tried and reverted: when the launcher
    // clears the widget surface ahead of a redraw, skipping updateAppWidget
    // leaves it permanently blank. So the BG-isolate render + this main-isolate
    // re-push can still produce a second blink; that's the accepted tradeoff.
    await HomeWidget.updateWidget(androidName: widgetSmallName);
    await HomeWidget.updateWidget(androidName: widgetBigName);
    await HomeWidget.updateWidget(androidName: widgetTinyName);
  }

  /// Pure-ish snapshot builder: a handful of one-shot drift reads plus the
  /// color resolution from [widget_data]. No platform calls, so it can be
  /// exercised directly in a db-backed test.
  static Future<WidgetSnapshot> buildSnapshot(AppDb db) async {
    final settings = UserSettings.fromRow(
      await (db.select(db.userProfileTable)..limit(1)).getSingleOrNull(),
    );
    final buddy = settings.selectedBuddy ?? BuddyId.fox;

    // Active, non-graduated habits.
    final habits = await (db.select(db.habits)
          ..where((h) =>
              h.active.equals(true) &
              h.deletedAt.isNull() &
              h.completedAt.isNull()))
        .get();

    // Earliest enabled schedule-slot time per habit, so the big widget can
    // list habits in the order they come up during the day (earliest time
    // window first). Habits with no slot sort last.
    final earliestSlot = <String, int>{};
    if (habits.isNotEmpty) {
      final slots = await (db.select(db.scheduleSlots)
            ..where((s) =>
                s.habitId.isIn(habits.map((h) => h.id).toList()) &
                s.enabled.equals(true)))
          .get();
      for (final s in slots) {
        final cur = earliestSlot[s.habitId];
        if (cur == null || s.timeOfDay < cur) {
          earliestSlot[s.habitId] = s.timeOfDay;
        }
      }
    }
    int slotOf(String id) => earliestSlot[id] ?? 24 * 60 + 1;
    habits.sort((a, b) {
      final byTime = slotOf(a.id).compareTo(slotOf(b.id));
      if (byTime != 0) return byTime;
      return a.createdAt.compareTo(b.createdAt);
    });

    // Today's latest log per habit (local day).
    final now = DateTime.now();
    final startOfDayUtc = DateTime(now.year, now.month, now.day).toUtc();
    final logRows = await (db.select(db.notificationLog)
          ..where((l) => l.respondedAt.isBiggerOrEqualValue(startOfDayUtc))
          ..orderBy([(l) => OrderingTerm.desc(l.respondedAt)]))
        .get();
    final latestByHabit = <String, String>{};
    for (final r in logRows) {
      latestByHabit.putIfAbsent(r.habitId, () => r.response);
    }
    bool isDone(String habitId) {
      final r = latestByHabit[habitId];
      return r == 'yes' || r == 'manual_done';
    }

    final total = habits.length;
    final done = habits.where((h) => isDone(h.id)).length;
    final pending = [
      for (final h in habits)
        if (!isDone(h.id)) (id: h.id, name: h.name),
    ];
    final cappedPending =
        pending.take(cappedHabitCount(pending.length)).toList();

    // Buddy sprite: same logic as the Today header — stage art if the
    // species has it, else the idle pose.
    final stage = await BuddyProgressRepository(db).maxStageReached(buddy);
    final buddyAsset = BuddyAsset.stageFor(buddy, stage) ??
        BuddyAsset.forPose(buddy, BuddyPose.idle);

    // Colors. Primary = explicit override, else the buddy's brand seed.
    final primary = settings.customPrimaryColor ??
        palettes[buddyDefaultThemes[buddy]!.light]!.seed.toARGB32();
    // Widget background follows the app's composed background so the big
    // widget's card matches the user's chosen look (light / dark / tinted).
    final bg = composeBackground(
      base: settings.bgBase,
      tint: Color(settings.bgTintColor),
      strength: settings.bgTintStrength,
      systemBrightness: PlatformDispatcher.instance.platformBrightness,
    );
    final brightness = brightnessForBackground(bg);
    // Neutral on-background for legible text on whatever the bg resolved to.
    final onBg = brightness == Brightness.light ? 0xDE000000 : 0xFFFFFFFF;
    final scheme =
        ColorScheme.fromSeed(seedColor: Color(primary), brightness: brightness);
    final pct = total == 0 ? 0.0 : done / total;
    final progressColor = resolveProgressColor(
      pct: pct,
      mode: WidgetColorMode.fromId(settings.widgetColorMode),
      primaryColor: primary,
    );

    return WidgetSnapshot(
      buddyAsset: buddyAsset,
      doneCount: done,
      totalCount: total,
      progressColor: progressColor,
      trackColor: scheme.surfaceContainerHighest.toARGB32(),
      circleColor: scheme.primaryContainer.toARGB32(),
      accentColor: 0xFF000000 | (primary & 0x00FFFFFF),
      bgColor: 0xFF000000 | (bg.toARGB32() & 0x00FFFFFF),
      onBgColor: onBg,
      showCount: settings.widgetShowCount,
      pendingHabits: cappedPending,
    );
  }
}

/// Background isolate entry point invoked by `home_widget` when a widget
/// element with a background PendingIntent is tapped (the big widget's Done
/// buttons). Logs the habit as done and re-renders the widgets. Must be a
/// top-level / static function annotated for AOT retention.
@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  final habitId = parseDoneHabitId(uri);
  if (habitId == null) return;

  debugPrint('WB_DBG bg callback ENTER t=${DateTime.now().millisecondsSinceEpoch}');
  final db = AppDb();
  try {
    final nowUtc = DateTime.now().toUtc();
    await db.into(db.notificationLog).insert(
          NotificationLogCompanion.insert(
            habitId: habitId,
            scheduledFor: nowUtc,
            response: 'manual_done',
            source: 'widget',
            firedAt: Value(nowUtc),
            respondedAt: Value(nowUtc),
          ),
        );
    await HomeWidgetService.render(db);
    // Nudge the foreground app (if open) to re-query so its UI updates too.
    final fgPort = IsolateNameServer.lookupPortByName(notificationRefreshPortName);
    debugPrint('WB_DBG bg ping fgPort=${fgPort != null} t=${DateTime.now().millisecondsSinceEpoch}');
    fgPort?.send(null);
  } finally {
    await db.close();
  }
}
