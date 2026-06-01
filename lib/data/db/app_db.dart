import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

/// v6: goal-anchored habits. Every habit belongs to a Goal. Goals are
/// what the user actually wants — the habits are the daily moves that
/// achieve them.
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  /// Set when the user (or the heuristic + user confirm in Phase 5)
  /// declares the goal achieved. Active goals have this null.
  DateTimeColumn get completedAt => dateTime().nullable()();
  /// v11: distinct from completedAt — set when the user gives up on / removes
  /// a goal mid-flight (the orphan-cleanup in the goal wizard also uses this).
  /// Graduated and archived goals were indistinguishable before v11.
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Habits extends Table {
  TextColumn get id => text()();
  /// v6: every habit is tied to a goal. Nullable in the column for
  /// migration safety / defensive reads of legacy rows; the UI requires
  /// a goal at creation time.
  TextColumn get goalId =>
      text().nullable().references(Goals, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get category => text()();
  TextColumn get customMessage => text().nullable()();
  TextColumn get kind => text()(); // 'time' | 'freq'
  /// v10: for 'time' kind, how the alarm fires:
  /// - 'flexible' (default): engine picks the time within the chosen window
  /// - 'fixed': user picks exact time(s) — stored as 'time' slots
  /// Ignored for 'freq' (those are always engine-shifted priming).
  TextColumn get alarmStyle =>
      text().withDefault(const Constant('flexible'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  /// v6: set when the user graduates the habit (Phase 5). Active habits
  /// have this null; once set the habit is hidden from Today and lives
  /// in the Completed section.
  DateTimeColumn get completedAt => dateTime().nullable()();
  // Legacy single-window hint. Kept for back-compat; new code reads
  // `timeWindowsJson` (which gets populated from this on migration). When
  // both are present, `timeWindowsJson` wins.
  TextColumn get timeWindow =>
      text().withDefault(const Constant('anytime'))();
  // v5: JSON-encoded list of window ids, e.g. ["morning","afternoon"]. Empty
  // ([]) when the habit uses a custom range (see `customStartMinutes`).
  TextColumn get timeWindowsJson =>
      text().withDefault(const Constant('["anytime"]'))();
  // v5: literal custom range in minutes since midnight (0..1439). Both
  // non-null = custom range active and `timeWindowsJson` is ignored. Both
  // null = preset windows in `timeWindowsJson` are in effect (exclusive).
  IntColumn get customStartMinutes => integer().nullable()();
  IntColumn get customEndMinutes => integer().nullable()();
  // Frequency-habit target (e.g. 2x/week). Null for time-based habits.
  IntColumn get targetPerWeek => integer().nullable()();
  /// Phase 3: optional preferred day-of-week for frequency habits (1..7,
  /// Mon..Sun). The smart scheduler picks the time of day; this column
  /// lets the user pin the day. Null = "any day works".
  IntColumn get preferredWeekday => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScheduleSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId => text().references(Habits, #id)();
  TextColumn get kind => text()(); // 'time' | 'priming'
  IntColumn get timeOfDay => integer()(); // minutes since midnight (0..1439)
  IntColumn get weekdayMask => integer().withDefault(const Constant(0x7F))(); // bits 1..127
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

class NotificationLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get scheduledFor => dateTime()(); // UTC
  DateTimeColumn get firedAt => dateTime().nullable()();
  TextColumn get response => text()(); // yes|not_yet|missed|manual_done|snoozed|expired
  DateTimeColumn get respondedAt => dateTime().nullable()();
  TextColumn get source => text()(); // action_button|app|auto_missed|auto_expired
  TextColumn get toneUsed => text().nullable()();
}

class UserProfileTable extends Table {
  @override
  String get tableName => 'user_profile';

  IntColumn get id => integer().withDefault(const Constant(1))(); // single row
  TextColumn get tonePreference => text().withDefault(const Constant('mixed'))();
  IntColumn get dailyNotifBudget => integer().withDefault(const Constant(4))();
  TextColumn get wakingWindowJson => text().withDefault(const Constant('{}'))();
  TextColumn get slotPreferencesJson => text().withDefault(const Constant('{}'))();
  TextColumn get weekdayOverridesJson => text().withDefault(const Constant('{}'))();
  TextColumn get goalsJson => text().withDefault(const Constant('[]'))();
  // Phase 2.5b: per-user notification settings.
  BoolColumn get followUpEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get popupEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get vibrationEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get soundEnabled =>
      boolean().withDefault(const Constant(false))();
  // 0 = never expire. Otherwise the reminder auto-dismisses after N minutes.
  IntColumn get ttlMinutes =>
      integer().withDefault(const Constant(60))();
  // Phase 3: set to true once the user finishes onboarding.
  BoolColumn get onboarded =>
      boolean().withDefault(const Constant(false))();
  // v4: visual personalization. selectedBuddy is null until the user picks
  // one in onboarding; themeId 'auto' means "follow the buddy's default";
  // customPrimaryColor / customAccentColor are ARGB overrides that take
  // precedence over the palette. darkMode is 'system' | 'light' | 'dark'.
  TextColumn get selectedBuddy => text().nullable()();
  TextColumn get themeId => text().withDefault(const Constant('auto'))();
  IntColumn get customPrimaryColor => integer().nullable()();
  IntColumn get customAccentColor => integer().nullable()();
  /// v8 — legacy direct background color. Kept readable for old data but
  /// the active path is the v9 triple below.
  IntColumn get customBackgroundColor => integer().nullable()();
  /// v9 — background is composed: a base ('light' | 'dark' | 'colorful')
  /// blended with a tint color at a 0..100 strength. The themeProvider
  /// computes the actual scaffold from these three. Defaults give the
  /// shipped "cream + sunrise tint at 10%" look on a fresh install.
  TextColumn get bgBase => text().withDefault(const Constant('auto'))();
  IntColumn get bgTintColor =>
      integer().withDefault(const Constant(0xFFCC6B49))();
  IntColumn get bgTintStrength =>
      integer().withDefault(const Constant(15))();
  TextColumn get darkMode => text().withDefault(const Constant('system'))();
  // v4: presence-aware notification gating (Android-only honors this; iOS
  // ignores the column). 'active' | 'away' | 'both'.
  TextColumn get presenceMode => text().withDefault(const Constant('both'))();
  /// v13 — home-screen widget progress color. 'primary' (default) paints the
  /// bar / ring the user's primary color at all completion levels;
  /// 'progressive' fades it red → yellow → green as more habits are checked.
  TextColumn get widgetColorMode =>
      text().withDefault(const Constant('primary'))();
  /// v14 — whether the widgets show the "done/total" count. When false the
  /// count is hidden and the progress bar is vertically centered.
  BoolColumn get widgetShowCount =>
      boolean().withDefault(const Constant(true))();
  /// v15 — user-defined buddy ordering for the picker, stored as a JSON
  /// array of BuddyId.id strings (e.g. ["cat","fox","snake",…]). Empty /
  /// null means "use the built-in default order". The picker floats a
  /// buddy chosen from behind the "More" tray to the front of this list so
  /// it stays visible next time.
  TextColumn get buddyOrderJson =>
      text().withDefault(const Constant(''))();
  /// v16 — when true (default) habit reminders play the selected buddy's
  /// own animal sound (per-buddy notification channel). When false, sound
  /// falls back to the system default. Only matters when [soundEnabled].
  BoolColumn get customSoundsEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProfileSignals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get ts => dateTime()();
  TextColumn get kind => text()(); // response|dismissal|manual_edit|app_open
  TextColumn get payloadJson => text()();
}

/// User-defined habit categories. Augments the preset enum so the
/// category picker can grow without code changes.
class UserCategories extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get label => text().withLength(min: 1, max: 60)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// v12: per-buddy progress for the 5-stage evolution arc. Score is
/// monotonically non-decreasing — a bad week never demotes you. The
/// reconciler credits one row per (buddy, day) by walking the
/// notification log; `lastScoredDayEpoch` lets us skip already-credited
/// days. `maxStageReached` is persisted (not derived) so a buddy you
/// stop using still shows the form you'd evolved them to.
class BuddyProgress extends Table {
  TextColumn get buddyId => text()(); // BuddyId.id
  IntColumn get totalScore =>
      integer().withDefault(const Constant(0))();
  // YYYYMMDD encoded as an int (e.g. 20260529). Null = never scored.
  IntColumn get lastScoredDayEpoch => integer().nullable()();
  IntColumn get maxStageReached =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {buddyId};
}

class AdaptiveState extends Table {
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get lastEvaluatedAt => dateTime()();
  TextColumn get responseWindowJson => text().withDefault(const Constant('{}'))();
  TextColumn get currentOffsetsJson => text().withDefault(const Constant('{}'))();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastMissAt => dateTime().nullable()();
  TextColumn get currentToneKey => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {habitId};
}

@DriftDatabase(tables: [
  Goals,
  Habits,
  ScheduleSlots,
  NotificationLog,
  UserProfileTable,
  ProfileSignals,
  AdaptiveState,
  UserCategories,
  BuddyProgress,
])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'habit_buddy'));

  AppDb.forTesting(super.executor);

  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(scheduleSlots);
            await m.createTable(notificationLog);
            await m.createTable(userProfileTable);
            await m.createTable(profileSignals);
            await m.createTable(adaptiveState);
          }
          if (from < 3) {
            await m.addColumn(habits, habits.timeWindow);
            await m.addColumn(habits, habits.targetPerWeek);
            await m.addColumn(
                userProfileTable, userProfileTable.followUpEnabled);
            await m.addColumn(
                userProfileTable, userProfileTable.popupEnabled);
            await m.addColumn(
                userProfileTable, userProfileTable.vibrationEnabled);
            await m.addColumn(
                userProfileTable, userProfileTable.soundEnabled);
            await m.addColumn(
                userProfileTable, userProfileTable.ttlMinutes);
            await m.addColumn(
                userProfileTable, userProfileTable.onboarded);
          }
          if (from < 4) {
            await m.addColumn(
                userProfileTable, userProfileTable.selectedBuddy);
            await m.addColumn(userProfileTable, userProfileTable.themeId);
            await m.addColumn(
                userProfileTable, userProfileTable.customPrimaryColor);
            await m.addColumn(
                userProfileTable, userProfileTable.customAccentColor);
            await m.addColumn(userProfileTable, userProfileTable.darkMode);
            await m.addColumn(
                userProfileTable, userProfileTable.presenceMode);
          }
          if (from < 5) {
            await m.addColumn(habits, habits.timeWindowsJson);
            await m.addColumn(habits, habits.customStartMinutes);
            await m.addColumn(habits, habits.customEndMinutes);
            // Lift each existing single-window value into the JSON list so
            // existing habits don't lose their "When?" selection.
            await customStatement(
              "UPDATE habits SET time_windows_json = "
              "'[\"' || COALESCE(time_window,'anytime') || '\"]'",
            );
          }
          if (from < 6) {
            // v6 goal-anchored model. The user explicitly accepted a wipe
            // pre-launch — habits and the log get rebuilt from scratch
            // under the new goalId model, but profile preferences survive.
            await customStatement('DROP TABLE IF EXISTS adaptive_state');
            await customStatement('DROP TABLE IF EXISTS notification_log');
            await customStatement('DROP TABLE IF EXISTS schedule_slots');
            await customStatement('DROP TABLE IF EXISTS habits');
            await customStatement('DROP TABLE IF EXISTS profile_signals');
            await m.createTable(goals);
            await m.createTable(habits);
            await m.createTable(scheduleSlots);
            await m.createTable(notificationLog);
            await m.createTable(profileSignals);
            await m.createTable(adaptiveState);
            // The free-text goals_json from prior versions no longer maps
            // onto the structured Goals table — clear it so the user
            // re-enters them in the new flow.
            await customStatement("UPDATE user_profile SET goals_json='[]'");
          }
          if (from < 7) {
            await m.createTable(userCategories);
          }
          if (from < 8) {
            await m.addColumn(
                userProfileTable, userProfileTable.customBackgroundColor);
          }
          if (from < 9) {
            await m.addColumn(userProfileTable, userProfileTable.bgBase);
            await m.addColumn(
                userProfileTable, userProfileTable.bgTintColor);
            await m.addColumn(
                userProfileTable, userProfileTable.bgTintStrength);
          }
          if (from < 10) {
            await m.addColumn(habits, habits.alarmStyle);
          }
          if (from < 11) {
            // v11: split archived from graduated. New column on Goals.
            // The bgBase default changes from 'light' to 'auto' — existing
            // rows keep whatever they have (could be the explicit user
            // pref or the old default); we don't rewrite to avoid stomping
            // an intentional 'light' pick.
            await m.addColumn(goals, goals.archivedAt);
          }
          if (from < 12) {
            // v12: per-buddy evolution progress.
            await m.createTable(buddyProgress);
          }
          if (from < 13) {
            // v13: home-screen widget progress color preference.
            await m.addColumn(
                userProfileTable, userProfileTable.widgetColorMode);
          }
          if (from < 14) {
            // v14: widget count-visibility toggle.
            await m.addColumn(
                userProfileTable, userProfileTable.widgetShowCount);
          }
          if (from < 15) {
            // v15: custom buddy ordering for the picker.
            await m.addColumn(
                userProfileTable, userProfileTable.buddyOrderJson);
          }
          if (from < 16) {
            // v16: per-buddy custom notification sounds toggle.
            await m.addColumn(
                userProfileTable, userProfileTable.customSoundsEnabled);
          }
        },
      );
}
