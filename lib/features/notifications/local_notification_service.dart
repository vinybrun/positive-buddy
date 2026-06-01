import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/db/app_db.dart';
import '../../data/repositories/profile_repository.dart';
import '../../theme/buddy.dart';
import '../../personalization/buddy_voice.dart';
import '../../personalization/engine.dart';
import '../habits/habit_categories.dart';
import '../onboarding/onboarding_model.dart';
import 'notification_copy.dart';
import 'presence.dart';

part 'local_notification_service.g.dart';

const String notificationRefreshPortName = 'habit_buddy.refresh';

const String defaultChannelId = 'habit_reminders';
const String defaultChannelName = 'Habit reminders';
const String defaultChannelDesc = 'Reminders for your habits';

/// Shared group key so multiple habit reminders auto-stack into one shade
/// entry on Android instead of piling up.
const String reminderGroupKey = 'habit_buddy.reminders';

// v2: bumped importance to HIGH so the ack peeks as a heads-up. Channel
// importance is locked at creation on Android 8+, so we need a new id to
// upgrade existing installs. Sound + vibration are still off — it peeks
// silently, like a quick reply.
const String ackChannelId = 'habit_acknowledgments_v2';
const String ackChannelName = 'Buddy replies';
const String ackChannelDesc =
    'Brief confirmations after you tap a response (silent peek)';
const String _legacyAckChannelId = 'habit_acknowledgments';

// Per-buddy reminder sound. Each buddy gets its own notification channel so
// Android can play that buddy's animal sound (channel sound is immutable after
// creation, so a custom sound MUST live on its own channel). The raw resource
// is `res/raw/buddy_<species>.ogg`. Bump [buddySoundVersion] whenever the
// shipped sound files change so installed devices recreate the channels with
// the new audio instead of keeping the stale one.
const String buddySoundVersion = 'v1';

String buddyReminderChannelId(BuddyId b) =>
    'habit_reminders_${b.id}_$buddySoundVersion';
String buddyReminderChannelName(BuddyId b) => 'Habit reminders · ${b.label}';
String buddyRawSoundName(BuddyId b) => 'buddy_${b.id}';

/// Resolved channel + sound for a habit reminder, derived purely from the
/// user's settings. Extracted as a pure function so the routing is unit
/// testable without the platform plugin.
class ReminderChannelChoice {
  const ReminderChannelChoice({
    required this.channelId,
    required this.channelName,
    required this.rawSoundName,
    required this.playSound,
  });

  final String channelId;
  final String channelName;

  /// Raw resource name for the buddy sound, or null when no custom sound is
  /// used (default channel — system sound, gated by [playSound]).
  final String? rawSoundName;

  /// Whether the notification should make sound at all.
  final bool playSound;

  bool get usesBuddySound => rawSoundName != null;
}

/// Picks the buddy sound channel when the user has sound on, custom sounds on,
/// and a buddy selected; otherwise the shared default channel (system sound
/// gated by [UserSettings.soundEnabled]).
ReminderChannelChoice resolveReminderChannel(UserSettings s) {
  final buddy = s.selectedBuddy;
  if (s.soundEnabled && s.customSoundsEnabled && buddy != null) {
    return ReminderChannelChoice(
      channelId: buddyReminderChannelId(buddy),
      channelName: buddyReminderChannelName(buddy),
      rawSoundName: buddyRawSoundName(buddy),
      playSound: true,
    );
  }
  return ReminderChannelChoice(
    channelId: defaultChannelId,
    channelName: defaultChannelName,
    rawSoundName: null,
    playSound: s.soundEnabled,
  );
}

const String actionYes = 'RESPOND_YES';
const String actionNotYet = 'RESPOND_NOT_YET';

const int testNotificationId = 1;

const int defaultTtlMs = 60 * 60 * 1000;
const int ackTtlMs = 8 * 1000;

@Riverpod(keepAlive: true)
LocalNotificationService localNotificationService(Ref ref) {
  return LocalNotificationService();
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Buddy sound channels are created lazily (only the active buddy's channel
  /// is ever needed). Tracks which ids we've already created this run so we
  /// don't hammer the platform with redundant create calls.
  final Set<String> _createdBuddyChannels = {};

  /// Make sure the channel the reminder will post to exists. No-op for the
  /// default channel (created in [init]); creates the per-buddy channel with
  /// its animal sound the first time that buddy needs it.
  Future<void> _ensureChannelFor(ReminderChannelChoice choice) async {
    if (!choice.usesBuddySound) return;
    if (_createdBuddyChannels.contains(choice.channelId)) return;
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      AndroidNotificationChannel(
        choice.channelId,
        choice.channelName,
        description: defaultChannelDesc,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(choice.rawSoundName!),
      ),
    );
    _createdBuddyChannels.add(choice.channelId);
  }

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Failed to set local timezone: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        defaultChannelId,
        defaultChannelName,
        description: defaultChannelDesc,
        importance: Importance.high,
      ),
    );
    // Clean up the legacy low-importance ack channel from earlier builds.
    try {
      await androidImpl?.deleteNotificationChannel(
          channelId: _legacyAckChannelId);
    } catch (_) {
      // Channel may not exist — that's fine.
    }
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        ackChannelId,
        ackChannelName,
        description: ackChannelDesc,
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final notif = await Permission.notification.request();
    return notif.isGranted;
  }

  Future<void> fireTestNotification({UserSettings? settings}) async {
    const body = 'Did you drink water in the last hour?';
    final s = settings ?? UserSettings.defaults;
    await _ensureChannelFor(resolveReminderChannel(s));
    await _plugin.show(
      id: testNotificationId,
      title: 'Quick check 🙂',
      body: body,
      notificationDetails:
          _details(habitId: 'test', body: body, settings: s),
      payload: 'habit:test',
    );
  }

  /// Schedule a habit reminder at [when] (local time). Stable id derived from
  /// habit + occurrence so re-scheduling is idempotent. If [db] is provided,
  /// the user's notification settings (popup/vibration/sound/TTL) are loaded
  /// from it; otherwise built-in defaults apply.
  Future<void> scheduleHabitReminder({
    required String habitId,
    required DateTime when,
    required String title,
    required String body,
    AppDb? db,
  }) async {
    final settings = db == null
        ? UserSettings.defaults
        : await ProfileRepository(db).readSettings();
    await _ensureChannelFor(resolveReminderChannel(settings));
    // Sweep any stale reminders currently in the shade so we never pile up.
    // Pending (not-yet-fired) alarms are left alone — they fire at their own
    // time and that fresh fire will be the only thing visible.
    await cancelActiveReminders();
    await _scheduleRaw(
        habitId: habitId,
        when: when,
        title: title,
        body: body,
        settings: settings);
  }

  /// Raw schedule without the active-reminder sweep — used by [reconcile] in
  /// a loop where the sweep would be wasteful.
  Future<void> _scheduleRaw({
    required String habitId,
    required DateTime when,
    required String title,
    required String body,
    required UserSettings settings,
  }) async {
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    final id = notificationIdFor(habitId, when);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzWhen,
      notificationDetails:
          _details(habitId: habitId, body: body, settings: settings),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'habit:$habitId',
    );
  }

  /// Rolling-window reconcile. Reads all active habits + their slots, computes
  /// the next 7 days of occurrences (capped at 50 total), cancels any pending
  /// habit reminders not in the new set, and schedules anything missing.
  /// Idempotent — safe to call on every app resume, habit edit, response, etc.
  Future<void> reconcile(AppDb db) async {
    final settings = await ProfileRepository(db).readSettings();
    await _ensureChannelFor(resolveReminderChannel(settings));
    final habitRows = await (db.select(db.habits)
          ..where((h) => h.active.equals(true) & h.deletedAt.isNull()))
        .get();
    final habits = <HabitWithSlotViews>[];
    for (final h in habitRows) {
      final slotRows = await (db.select(db.scheduleSlots)
            ..where((s) => s.habitId.equals(h.id)))
          .get();
      habits.add(HabitWithSlotViews(
        id: h.id,
        name: h.name,
        category: h.category,
        timeWindow: h.timeWindow,
        active: h.active,
        slots: slotRows
            .map((s) => SlotView(
                  timeOfDay: s.timeOfDay,
                  enabled: s.enabled,
                  weekdayMask: s.weekdayMask,
                  kind: s.kind,
                ))
            .toList(),
      ));
    }

    final candidates = computeOccurrences(
      habits: habits,
      now: DateTime.now(),
      daysAhead: 7,
      maxCount: 50,
    );

    // Run the personalization engine: shifts freq-habit nudges to the
    // user's active hour, drops occurrences outside the waking window,
    // caps to daily budget, adapts tone. Engine is a pure function, no
    // IO — easy to unit-test independently of the schedule loop.
    final profileRow = await ProfileRepository(db).read();
    final profileInput = _profileInputFrom(profileRow);
    // Load the last 14 days of signals for the time-shift rule + the
    // engagement-state classifier (Phase 3/4).
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 14));
    final signalRows = await (db.select(db.profileSignals)
          ..where((s) => s.ts.isBiggerOrEqualValue(since))
          ..orderBy([(s) => OrderingTerm.asc(s.ts)]))
        .get();
    final signals = signalRows.map((s) {
      String? response;
      try {
        final m = jsonDecode(s.payloadJson) as Map<String, dynamic>;
        response = m['response'] as String?;
      } catch (_) {
        response = null;
      }
      return EngagementSignal(
        kind: s.kind,
        ts: s.ts,
        response: response,
      );
    }).toList();
    final engagementState =
        classifyEngagement(signals: signals, now: now);
    final engine = PersonalizationEngine(defaultRules());
    final plan = engine.plan(PersonalizationInput(
      profile: profileInput,
      candidates: candidates,
      now: now,
      signals: signals,
      engagementState: engagementState,
    ));
    final desired = plan.keepers; // PlannedOccurrence, carries toneKey
    final desiredIds = <int>{
      for (final p in desired)
        notificationIdFor(p.occurrence.habitId, p.occurrence.when),
    };

    // Cancel pending habit reminders that are NOT in the new desired set.
    // We identify ours by the 'habit:' payload prefix — other notifications
    // (system, etc.) aren't ours and stay untouched.
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      final payload = p.payload;
      if (payload == null || !payload.startsWith('habit:')) continue;
      if (!desiredIds.contains(p.id)) {
        await _plugin.cancel(id: p.id);
      }
    }

    // Schedule anything missing.
    final pendingIds = {for (final p in pending) p.id};
    for (final p in desired) {
      final occ = p.occurrence;
      final id = notificationIdFor(occ.habitId, occ.when);
      if (pendingIds.contains(id)) continue; // already scheduled
      String title;
      String body;
      if (isAdaptiveTone(p.toneKey)) {
        // Phase 4: re-engagement copy overrides the per-category default
        // so dropped/cooling users hear "missed you," not "Did you drink
        // your water?". The buddy's voice still flavors the line.
        final ack = adaptiveAckFor(
            settings.selectedBuddy, p.toneKey, DateTime.now());
        title = ack.$1;
        body = ack.$2;
      } else {
        final cat = _categoryFor(occ.category);
        title = cat.title;
        body = cat.bodyFor(occ.habitName);
      }
      await _scheduleRaw(
        habitId: occ.habitId,
        when: occ.when,
        title: title,
        body: body,
        settings: settings,
      );
    }
  }

  ProfileInput _profileInputFrom(UserProfileTableData? row) {
    if (row == null) return ProfileInput.fallback;
    final wake = OnboardingData.parseWakingWindow(row.wakingWindowJson);
    final start = wake?.start;
    final end = wake?.end;
    return ProfileInput(
      tonePreference: row.tonePreference,
      dailyNotifBudget: row.dailyNotifBudget,
      wakingStartHour: start?.hour ?? ProfileInput.fallback.wakingStartHour,
      wakingStartMinute:
          start?.minute ?? ProfileInput.fallback.wakingStartMinute,
      wakingEndHour: end?.hour ?? ProfileInput.fallback.wakingEndHour,
      wakingEndMinute:
          end?.minute ?? ProfileInput.fallback.wakingEndMinute,
    );
  }

  ({String title, String Function(String habitName) bodyFor}) _categoryFor(
      String categoryId) {
    final cat = HabitCategory.fromId(categoryId);
    return (
      title: cat.promptTitle,
      bodyFor: (name) => cat.promptFor(name.toLowerCase()),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
  Future<void> cancelAll() => _plugin.cancelAll();
  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();

  /// Cancel every currently-DISPLAYED habit reminder (channel
  /// [defaultChannelId]). Leaves ack notifications and pending alarms alone.
  /// Used to keep the shade clean — call on action tap, app resume, and
  /// before scheduling a new reminder.
  Future<void> cancelActiveReminders() async {
    try {
      final active = await _plugin.getActiveNotifications();
      for (final n in active) {
        if (n.id == null) continue;
        if (n.channelId == defaultChannelId) {
          await _plugin.cancel(id: n.id!);
        }
      }
    } catch (e) {
      debugPrint('cancelActiveReminders failed: $e');
    }
  }

  NotificationDetails _details({
    required String habitId,
    String? body,
    UserSettings? settings,
  }) {
    final s = settings ?? UserSettings.defaults;
    // ttl=0 means "never auto-expire". Plugin treats 0/negative as "no
    // timeout" — pass null instead so we don't accidentally instant-dismiss.
    final timeoutMs = s.ttlMinutes <= 0 ? null : s.ttlMinutes * 60 * 1000;
    final channel = resolveReminderChannel(s);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.channelId,
        channel.channelName,
        channelDescription: defaultChannelDesc,
        // popupEnabled off → demote to default importance (no heads-up).
        importance: s.popupEnabled ? Importance.high : Importance.defaultImportance,
        priority: s.popupEnabled ? Priority.max : Priority.defaultPriority,
        // Alarm category gets more presentation budget on most Android skins
        // (HyperOS included) — better odds of the action buttons surviving the
        // compact layout. We're not running a true alarm (no full-screen
        // intent), but a habit reminder is semantically close.
        category: AndroidNotificationCategory.alarm,
        // Shared group key so back-to-back reminders auto-stack into a single
        // shade entry instead of piling up.
        groupKey: reminderGroupKey,
        timeoutAfter: timeoutMs,
        showWhen: true,
        autoCancel: true,
        playSound: channel.playSound,
        sound: channel.rawSoundName == null
            ? null
            : RawResourceAndroidNotificationSound(channel.rawSoundName!),
        enableVibration: s.vibrationEnabled,
        // Force expanded layout when the user pulls the shade.
        styleInformation: BigTextStyleInformation(
          body ?? '',
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
        ),
        actions: const [
          AndroidNotificationAction(
            actionYes,
            'Yes',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            actionNotYet,
            'Not yet',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    );
  }

  static void _onForegroundResponse(NotificationResponse response) {
    debugPrint(
        'Notification tapped (fg): payload=${response.payload} action=${response.actionId}');
    _handleResponse(response).then((_) => _pingMainIsolate());
  }
}

void _pingMainIsolate() {
  try {
    final port = IsolateNameServer.lookupPortByName(notificationRefreshPortName);
    port?.send('refresh');
  } catch (e) {
    debugPrint('Refresh ping failed: $e');
  }
}

bool _bgIsolateInit = false;
Future<void> _ensureBgInit() async {
  if (_bgIsolateInit) return;
  try {
    tz_data.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (e) {
    debugPrint('BG tz init failed: $e');
  }
  // The BG isolate is a fresh Dart VM; re-initialize the plugin so we can
  // call show() to post the acknowledgment notification.
  try {
    await FlutterLocalNotificationsPlugin().initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  } catch (e) {
    debugPrint('BG plugin init failed: $e');
  }
  _bgIsolateInit = true;
}

/// Deterministic 31-bit notification id from (habitId, occurrenceMillis).
int notificationIdFor(String habitId, DateTime when) {
  final combined = '$habitId|${when.toUtc().millisecondsSinceEpoch}';
  return combined.hashCode & 0x7fffffff;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  debugPrint(
      'Notification tapped (bg): payload=${response.payload} action=${response.actionId}');
  await _ensureBgInit();
  await _handleResponse(response);
  _pingMainIsolate();
}

/// In the main isolate, the app populates this so notification responses
/// write through the *same* drift instance that the UI is watching — otherwise
/// reactive streams would miss the new row. In the background isolate (where
/// this stays null), we open a transient AppDb.
AppDb? _activeForegroundDb;

void bindForegroundDb(AppDb db) {
  _activeForegroundDb = db;
}

Future<void> _handleResponse(NotificationResponse response) async {
  final payload = response.payload;
  if (payload == null || !payload.startsWith('habit:')) return;
  final habitId = payload.substring('habit:'.length);
  if (habitId.isEmpty || habitId == 'test') return;

  // Body taps (no action) just open the app — never log a fake response.
  final responseStr = responseFromAction(response.actionId);
  if (responseStr == null) {
    debugPrint('Body tap on habit $habitId — opening app, not logging.');
    return;
  }

  final shared = _activeForegroundDb;
  final db = shared ?? AppDb();
  final shouldClose = shared == null;

  try {
    final nowUtc = DateTime.now().toUtc();
    await db.into(db.notificationLog).insert(
          NotificationLogCompanion.insert(
            habitId: habitId,
            scheduledFor: nowUtc,
            response: responseStr,
            source: 'action_button',
            firedAt: Value(nowUtc),
            respondedAt: Value(nowUtc),
          ),
        );

    final slots = await (db.select(db.scheduleSlots)
          ..where((s) => s.habitId.equals(habitId) & s.enabled.equals(true)))
        .get();
    final habit = await (db.select(db.habits)
          ..where((h) => h.id.equals(habitId)))
        .getSingleOrNull();
    // Read settings once so we can pass the buddy to the copy engine *and*
    // gate the follow-up notification on the user's preference below.
    final settings = await ProfileRepository(db).readSettings();
    final ack = composeAcknowledgment(
      response: responseStr,
      slots: slots
          .map((s) =>
              SlotView(timeOfDay: s.timeOfDay, enabled: s.enabled))
          .toList(),
      now: DateTime.now(),
      timeWindowId: habit?.timeWindow,
      buddy: settings.selectedBuddy,
    );

    // Clean the shade of any sibling habit reminders. The notification we
    // just responded to is already gone (cancelNotification: true on the
    // action button) — this clears anything else that piled up while the
    // user was away.
    await _cancelActiveRemindersFromHandler();
    // Gate the follow-up on (a) the user's master toggle and (b) their
    // presence-mode setting. Presence is best-effort — when we can't read
    // it (iOS, test env) we fire as if presenceMode='both'.
    final presenceOk = await PresenceBridge.shouldFire(settings.presenceMode);
    if (settings.followUpEnabled && presenceOk) {
      await _showAcknowledgment(
        habitId: habitId,
        title: ack.title,
        body: ack.body,
      );
    }

    // Top up the schedule — keeps the next 7 days of reminders pending even
    // if the user only interacts via notifications for a week.
    try {
      final svc = LocalNotificationService();
      await svc.reconcile(db);
    } catch (e) {
      debugPrint('post-response reconcile failed: $e');
    }
  } finally {
    if (shouldClose) await db.close();
  }
}

/// Static helper for the response handler — the handler can run in either
/// the foreground or background isolate, neither of which has a reference to
/// the `LocalNotificationService` instance.
Future<void> _cancelActiveRemindersFromHandler() async {
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    final active = await plugin.getActiveNotifications();
    for (final n in active) {
      if (n.id == null) continue;
      if (n.channelId == defaultChannelId) {
        await plugin.cancel(id: n.id!);
      }
    }
  } catch (e) {
    debugPrint('handler cancelActiveReminders failed: $e');
  }
}

Future<void> _showAcknowledgment({
  required String habitId,
  required String title,
  required String body,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  final id = ('ack:$habitId').hashCode & 0x7fffffff;
  await plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        ackChannelId,
        ackChannelName,
        channelDescription: ackChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: false,
        timeoutAfter: ackTtlMs,
        autoCancel: true,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
        ),
      ),
    ),
    payload: 'ack:$habitId',
  );
}
