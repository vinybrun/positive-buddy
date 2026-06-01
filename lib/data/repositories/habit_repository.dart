import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../features/habits/window_selection.dart';
import '../db/app_db.dart';

part 'habit_repository.g.dart';

@Riverpod(keepAlive: true)
AppDb appDb(Ref ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) =>
    HabitRepository(ref.watch(appDbProvider));

/// A habit joined with its time slots, useful for the Today page.
class HabitWithSlots {
  const HabitWithSlots(this.habit, this.slots);
  final Habit habit;
  final List<ScheduleSlot> slots;
}

class HabitRepository {
  HabitRepository(this._db);
  final AppDb _db;
  static const _uuid = Uuid();

  // ---- queries --------------------------------------------------------------

  Stream<List<Habit>> watchAll() =>
      (_db.select(_db.habits)..where((h) => h.deletedAt.isNull())).watch();

  Stream<List<HabitWithSlots>> watchActiveWithSlots() {
    // v6: active = not soft-deleted AND not graduated. Graduated habits
    // live in Phase 5's Completed section, not on Today.
    final query = _db.select(_db.habits)
      ..where((h) =>
          h.active.equals(true) &
          h.deletedAt.isNull() &
          h.completedAt.isNull());
    return query.watch().asyncMap((habits) async {
      final result = <HabitWithSlots>[];
      for (final h in habits) {
        final slots = await (_db.select(_db.scheduleSlots)
              ..where((s) => s.habitId.equals(h.id) & s.enabled.equals(true)))
            .get();
        result.add(HabitWithSlots(h, slots));
      }
      return result;
    });
  }

  /// v6: habits belonging to a specific goal (active, not graduated).
  Stream<List<Habit>> watchByGoal(String goalId) =>
      (_db.select(_db.habits)
            ..where((h) =>
                h.goalId.equals(goalId) &
                h.active.equals(true) &
                h.deletedAt.isNull() &
                h.completedAt.isNull()))
          .watch();

  /// v6: graduated habits (used by the Completed section).
  Stream<List<Habit>> watchCompleted() =>
      (_db.select(_db.habits)
            ..where((h) => h.completedAt.isNotNull())
            ..orderBy(
                [(h) => OrderingTerm.desc(h.completedAt)]))
          .watch();

  /// v11: habits soft-deleted under an archived goal. Used by the
  /// Archived page to render the goal's habits read-only.
  Future<List<Habit>> readDeletedByGoal(String goalId) =>
      (_db.select(_db.habits)
            ..where((h) =>
                h.goalId.equals(goalId) & h.deletedAt.isNotNull()))
          .get();

  /// v11: total count of habits under any goal that's been archived. Used
  /// by the Wins page archived-stats card.
  Future<int> countDeletedHabitsForGoals(List<String> goalIds) async {
    if (goalIds.isEmpty) return 0;
    final rows = await (_db.select(_db.habits)
          ..where((h) =>
              h.goalId.isIn(goalIds) & h.deletedAt.isNotNull()))
        .get();
    return rows.length;
  }

  Future<Habit?> getById(String id) =>
      (_db.select(_db.habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  // ---- mutations ------------------------------------------------------------

  /// Create a time-based habit with one or more reminder times.
  /// Returns the new habit ID.
  Future<String> createTimeBasedHabit({
    required String name,
    required String category,
    required List<TimeOfDay> times,
    String? customMessage,
    Set<int>? weekdays, // 1..7 (Mon..Sun); null = all 7
    String timeWindow = 'anytime',
    WindowSelection? windowSelection,
    String? goalId, // v6 — habit must belong to a goal going forward
    String alarmStyle = 'fixed', // 'fixed' | 'flexible' (v10)
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final mask = (weekdays == null)
        ? 0x7F
        : weekdays.fold<int>(0, (acc, w) => acc | (1 << (w - 1)));
    final sel = windowSelection;
    // Legacy column tracks the representative for back-compat readers.
    final legacyWindow =
        sel == null ? timeWindow : sel.representativeWindowId;

    await _db.transaction(() async {
      await _db.into(_db.habits).insert(HabitsCompanion.insert(
            id: id,
            name: name,
            category: category,
            kind: 'time',
            alarmStyle: Value(alarmStyle),
            customMessage: Value(customMessage),
            goalId: goalId == null ? const Value.absent() : Value(goalId),
            timeWindow: Value(legacyWindow),
            timeWindowsJson: sel == null
                ? Value('["$legacyWindow"]')
                : Value(sel.toJsonString()),
            customStartMinutes: sel?.customRange == null
                ? const Value.absent()
                : Value(sel!.customRange!.startMinutes),
            customEndMinutes: sel?.customRange == null
                ? const Value.absent()
                : Value(sel!.customRange!.endMinutes),
            createdAt: now,
            updatedAt: now,
          ));
      // 'flexible' time habits use the same engine-shifted priming slot
      // pattern as freq habits — the slot lives at noon as a placeholder
      // and the scheduler nudges it into the user's high-density hour
      // within the chosen window.
      if (alarmStyle == 'flexible') {
        await _db.into(_db.scheduleSlots).insert(ScheduleSlotsCompanion.insert(
              habitId: id,
              kind: 'priming',
              timeOfDay: 12 * 60,
              weekdayMask: Value(mask),
            ));
      } else {
        for (final t in times) {
          await _db.into(_db.scheduleSlots).insert(
              ScheduleSlotsCompanion.insert(
                habitId: id,
                kind: 'time',
                timeOfDay: t.hour * 60 + t.minute,
                weekdayMask: Value(mask),
              ));
        }
      }
    });
    return id;
  }

  /// Phase 5 — frequency-based habit. Records a weekly target and an
  /// optional "priming" question (e.g. Sunday evening: "going tomorrow?").
  Future<String> createFrequencyHabit({
    required String name,
    required String category,
    required int targetPerWeek,
    TimeOfDay? primingTime,
    Set<int>? primingDays, // 1..7
    String timeWindow = 'anytime',
    WindowSelection? windowSelection,
    String? goalId, // v6 — habit must belong to a goal going forward
    int? preferredWeekday, // Phase 3: optional 1..7 hint for app-picked time
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final mask = (primingDays == null)
        ? 0x00
        : primingDays.fold<int>(0, (acc, w) => acc | (1 << (w - 1)));
    final sel = windowSelection;
    final legacyWindow =
        sel == null ? timeWindow : sel.representativeWindowId;

    await _db.transaction(() async {
      await _db.into(_db.habits).insert(HabitsCompanion.insert(
            id: id,
            name: name,
            category: category,
            kind: 'freq',
            goalId: goalId == null ? const Value.absent() : Value(goalId),
            preferredWeekday: preferredWeekday == null
                ? const Value.absent()
                : Value(preferredWeekday),
            timeWindow: Value(legacyWindow),
            timeWindowsJson: sel == null
                ? Value('["$legacyWindow"]')
                : Value(sel.toJsonString()),
            customStartMinutes: sel?.customRange == null
                ? const Value.absent()
                : Value(sel!.customRange!.startMinutes),
            customEndMinutes: sel?.customRange == null
                ? const Value.absent()
                : Value(sel!.customRange!.endMinutes),
            targetPerWeek: Value(targetPerWeek),
            createdAt: now,
            updatedAt: now,
          ));
      // Phase 3: always materialize a single 'priming' slot so the
      // scheduler has something to put on the calendar. The actual time
      // of day is a noon placeholder — the personalization engine's
      // timeShiftRule moves it to the user's highest-density active hour
      // based on collected signals. The weekday mask honors the user's
      // optional preferredWeekday (or any day if they left it on Any).
      final dayMask = preferredWeekday == null
          ? 0x7F
          : 1 << (preferredWeekday - 1);
      await _db.into(_db.scheduleSlots).insert(ScheduleSlotsCompanion.insert(
            habitId: id,
            kind: 'priming',
            // Placeholder noon — the engine shifts this; if the user has
            // no signals collected yet the placeholder stays so they
            // still get *some* nudge while data accumulates.
            timeOfDay: (primingTime?.hour ?? 12) * 60 +
                (primingTime?.minute ?? 0),
            weekdayMask: Value(mask != 0 ? mask : dayMask),
          ));
    });
    return id;
  }

  /// Count of 'yes' logs for a habit in the current week (Mon → Sun, local
   /// time). Used by the Today page to show frequency-habit progress.
  Stream<int> watchWeeklyYesCount(String habitId) {
    final now = DateTime.now();
    // DateTime.weekday: Mon=1..Sun=7.
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final startUtc = monday.toUtc();
    final endUtc = monday.add(const Duration(days: 7)).toUtc();
    return (_db.select(_db.notificationLog)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.response.equals('yes') &
              l.respondedAt.isBiggerOrEqualValue(startUtc) &
              l.respondedAt.isSmallerThanValue(endUtc)))
        .watch()
        .map((rows) => rows.length);
  }

  /// Phase 5: graduate a habit. Sets completedAt; the habit drops off
  /// Today and lives in the Completed section.
  Future<void> graduate(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        completedAt: Value(now),
        active: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        deletedAt: Value(now),
        active: const Value(false),
        updatedAt: Value(now),
      ),
    );
  }

  /// Replace name/category + the full slot list for an existing habit.
  /// Used by the edit screen and the progressive-save wizard — slots are
  /// wiped and re-inserted so the user's choice (flexible vs fixed) is
  /// the only thing in effect.
  Future<void> updateHabitWithSlots({
    required String id,
    required String name,
    required String category,
    required List<TimeOfDay> times,
    String? customMessage,
    Set<int>? weekdays,
    String? timeWindow,
    WindowSelection? windowSelection,
    String alarmStyle = 'fixed', // 'fixed' | 'flexible' (v10)
  }) async {
    final now = DateTime.now();
    final mask = (weekdays == null)
        ? 0x7F
        : weekdays.fold<int>(0, (acc, w) => acc | (1 << (w - 1)));
    final sel = windowSelection;
    final legacyWindow =
        sel == null ? timeWindow : sel.representativeWindowId;

    await _db.transaction(() async {
      await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(
          name: Value(name),
          category: Value(category),
          kind: const Value('time'),
          alarmStyle: Value(alarmStyle),
          customMessage: Value(customMessage),
          targetPerWeek: const Value(null),
          preferredWeekday: const Value(null),
          timeWindow:
              legacyWindow == null ? const Value.absent() : Value(legacyWindow),
          timeWindowsJson: sel == null
              ? const Value.absent()
              : Value(sel.toJsonString()),
          customStartMinutes: sel == null
              ? const Value.absent()
              : (sel.customRange == null
                  ? const Value(null)
                  : Value(sel.customRange!.startMinutes)),
          customEndMinutes: sel == null
              ? const Value.absent()
              : (sel.customRange == null
                  ? const Value(null)
                  : Value(sel.customRange!.endMinutes)),
          updatedAt: Value(now),
        ),
      );
      await (_db.delete(_db.scheduleSlots)
            ..where((s) => s.habitId.equals(id)))
          .go();
      if (alarmStyle == 'flexible') {
        await _db.into(_db.scheduleSlots).insert(ScheduleSlotsCompanion.insert(
              habitId: id,
              kind: 'priming',
              timeOfDay: 12 * 60,
              weekdayMask: Value(mask),
            ));
      } else {
        for (final t in times) {
          await _db.into(_db.scheduleSlots).insert(
              ScheduleSlotsCompanion.insert(
                habitId: id,
                kind: 'time',
                timeOfDay: t.hour * 60 + t.minute,
                weekdayMask: Value(mask),
              ));
        }
      }
    });
  }

  /// Convert an existing habit to (or keep it as) a frequency habit. Mirrors
  /// [createFrequencyHabit] but updates an existing row: wipes slots, drops
  /// a single 'priming' slot at noon (the engine shifts it), and stores the
  /// weekly target + optional preferred day.
  Future<void> updateFrequencyHabit({
    required String id,
    required String name,
    required String category,
    required int targetPerWeek,
    int? preferredWeekday,
    WindowSelection? windowSelection,
  }) async {
    final now = DateTime.now();
    final sel = windowSelection;
    final legacyWindow = sel?.representativeWindowId;
    final dayMask =
        preferredWeekday == null ? 0x7F : 1 << (preferredWeekday - 1);

    await _db.transaction(() async {
      await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(
          name: Value(name),
          category: Value(category),
          kind: const Value('freq'),
          targetPerWeek: Value(targetPerWeek),
          preferredWeekday: preferredWeekday == null
              ? const Value(null)
              : Value(preferredWeekday),
          timeWindow:
              legacyWindow == null ? const Value.absent() : Value(legacyWindow),
          timeWindowsJson: sel == null
              ? const Value.absent()
              : Value(sel.toJsonString()),
          customStartMinutes: sel == null
              ? const Value.absent()
              : (sel.customRange == null
                  ? const Value(null)
                  : Value(sel.customRange!.startMinutes)),
          customEndMinutes: sel == null
              ? const Value.absent()
              : (sel.customRange == null
                  ? const Value(null)
                  : Value(sel.customRange!.endMinutes)),
          updatedAt: Value(now),
        ),
      );
      await (_db.delete(_db.scheduleSlots)
            ..where((s) => s.habitId.equals(id)))
          .go();
      await _db.into(_db.scheduleSlots).insert(ScheduleSlotsCompanion.insert(
            habitId: id,
            kind: 'priming',
            timeOfDay: 12 * 60,
            weekdayMask: Value(dayMask),
          ));
    });
  }

  /// Read a habit + its slots for the edit screen.
  Future<({Habit habit, List<ScheduleSlot> slots})?> getWithSlots(
      String id) async {
    final h =
        await (_db.select(_db.habits)..where((row) => row.id.equals(id)))
            .getSingleOrNull();
    if (h == null) return null;
    final slots = await (_db.select(_db.scheduleSlots)
          ..where((s) => s.habitId.equals(id)))
        .get();
    return (habit: h, slots: slots);
  }

  // ---- debug helpers --------------------------------------------------------

  Future<void> createTestHabit() async {
    final now = DateTime.now();
    await _db.into(_db.habits).insert(
          HabitsCompanion.insert(
            id: _uuid.v4(),
            name: 'Test habit ${now.millisecondsSinceEpoch % 10000}',
            category: 'water',
            kind: 'time',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> deleteAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.scheduleSlots).go();
      await _db.delete(_db.habits).go();
    });
  }
}
