import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/habit_repository.dart';
import '../../personalization/completion_detector.dart';

part 'completion_service.g.dart';

/// Phase 5 — bridges the pure-Dart [completion_detector] with the
/// drift-backed log history. Used by the Today page to surface a
/// graduation prompt and by the Completed section to render throwback
/// stats.
@Riverpod(keepAlive: true)
CompletionService completionService(Ref ref) =>
    CompletionService(ref.watch(appDbProvider));

class CompletionService {
  CompletionService(this._db);
  final AppDb _db;

  /// Build the daily-outcome history for a habit: the last 60 days,
  /// each marked yes/no based on whether any 'yes' response landed on
  /// that local-time calendar day.
  Future<List<DailyOutcome>> dailyHistory(String habitId,
      {int days = 60}) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final cutoffUtc = cutoff.toUtc();
    final logs = await (_db.select(_db.notificationLog)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.response.equals('yes') &
              l.respondedAt.isBiggerOrEqualValue(cutoffUtc)))
        .get();
    final yesByDay = <String>{};
    for (final l in logs) {
      final d = l.respondedAt!.toLocal();
      yesByDay.add('${d.year}-${d.month}-${d.day}');
    }
    final out = <DailyOutcome>[];
    for (var i = 0; i < days; i++) {
      final d = DateTime(cutoff.year, cutoff.month, cutoff.day)
          .add(Duration(days: i));
      final key = '${d.year}-${d.month}-${d.day}';
      out.add(DailyOutcome(date: d, didYes: yesByDay.contains(key)));
    }
    return out;
  }

  /// Build the weekly-outcome history for a frequency habit. Walks
  /// back [weeks] ISO weeks (Mon → Sun) and counts yes responses.
  Future<List<WeeklyOutcome>> weeklyHistory(String habitId,
      {required int target, int weeks = 12}) async {
    final now = DateTime.now();
    // Most recent Monday at 00:00.
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final cutoff = monday.subtract(Duration(days: 7 * (weeks - 1)));
    final cutoffUtc = cutoff.toUtc();
    final logs = await (_db.select(_db.notificationLog)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.response.equals('yes') &
              l.respondedAt.isBiggerOrEqualValue(cutoffUtc)))
        .get();
    final out = <WeeklyOutcome>[];
    for (var w = 0; w < weeks; w++) {
      final start = cutoff.add(Duration(days: 7 * w));
      final end = start.add(const Duration(days: 7));
      final count = logs
          .where((l) =>
              l.respondedAt != null &&
              l.respondedAt!.toLocal().isAfter(start) &&
              l.respondedAt!.toLocal().isBefore(end))
          .length;
      out.add(WeeklyOutcome(
        weekStart: start,
        yesCount: count,
        target: target,
      ));
    }
    return out;
  }

  /// Evaluate every active habit and return the IDs the user should
  /// be prompted to graduate. Cheap-ish — we read 60 days of logs per
  /// habit, but only active habits, and only on Today-page mount /
  /// reconcile boundaries.
  Future<List<({Habit habit, GraduationVerdict verdict})>>
      eligibleForGraduation() async {
    final habits = await (_db.select(_db.habits)
          ..where((h) =>
              h.active.equals(true) &
              h.deletedAt.isNull() &
              h.completedAt.isNull()))
        .get();
    final out = <({Habit habit, GraduationVerdict verdict})>[];
    for (final h in habits) {
      if (h.kind == 'time') {
        final hist = await dailyHistory(h.id);
        final v = evaluateDailyHabit(hist);
        if (v.eligible) out.add((habit: h, verdict: v));
      } else {
        final target = h.targetPerWeek ?? 0;
        if (target == 0) continue;
        final hist = await weeklyHistory(h.id, target: target);
        final v = evaluateFrequencyHabit(hist);
        if (v.eligible) out.add((habit: h, verdict: v));
      }
    }
    return out;
  }
}
