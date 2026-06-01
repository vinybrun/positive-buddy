import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/habit_repository.dart';
import '../../theme/buddy.dart';
import '../../theme/launcher_icon.dart';
import 'buddy_scoring_engine.dart';

part 'buddy_progress_repository.g.dart';

@Riverpod(keepAlive: true)
BuddyProgressRepository buddyProgressRepository(Ref ref) =>
    BuddyProgressRepository(ref.watch(appDbProvider));

/// Per-day reconciler + reader for the buddy-evolution score.
///
/// The reconciler is **idempotent** — it walks calendar days from
/// `lastScoredDayEpoch + 1` up to *yesterday* (today is excluded because
/// the day isn't done yet) and credits each one exactly once. Today's
/// score is computed on the fly for display but never persisted until
/// the day rolls over.
class BuddyProgressRepository {
  BuddyProgressRepository(this._db);
  final AppDb _db;

  Stream<BuddyProgressData?> watch(BuddyId buddy) =>
      (_db.select(_db.buddyProgress)
            ..where((p) => p.buddyId.equals(buddy.id))
            ..limit(1))
          .watchSingleOrNull();

  Future<BuddyProgressData?> read(BuddyId buddy) =>
      (_db.select(_db.buddyProgress)
            ..where((p) => p.buddyId.equals(buddy.id))
            ..limit(1))
          .getSingleOrNull();

  /// What stage to show RIGHT NOW for [buddy], based on the persisted
  /// total. Includes today's in-progress score so a fresh "yes" tap
  /// near a threshold lights up the new sprite immediately.
  Future<int> currentStage(BuddyId buddy) async {
    final p = await read(buddy);
    if (p == null) return 0;
    final pending = await _todayScoreFor(buddy);
    return BuddyScoringEngine.stageFromScore(p.totalScore + pending);
  }

  /// Max stage this buddy has ever reached. Used in the picker so a
  /// previously-loved buddy you switched away from keeps showing the
  /// form you evolved them to.
  Future<int> maxStageReached(BuddyId buddy) async {
    final p = await read(buddy);
    return p?.maxStageReached ?? 0;
  }

  /// Idempotent. Pulls forward all unscored days up to yesterday,
  /// credits them to [buddy]'s total, and bumps `maxStageReached` if a
  /// new stage was crossed. Safe to call from any lifecycle hook.
  Future<void> reconcile(BuddyId buddy) async {
    final todayEpoch = _dayEpoch(DateTime.now());
    final existing = await read(buddy);
    final startEpoch =
        existing?.lastScoredDayEpoch == null
            ? _dayEpoch(DateTime.now().subtract(const Duration(days: 60)))
            : _addDays(existing!.lastScoredDayEpoch!, 1);
    if (startEpoch >= todayEpoch) return; // nothing to credit

    final priorMaxStage = existing?.maxStageReached ?? 0;
    var total = existing?.totalScore ?? 0;
    var maxStage = priorMaxStage;
    var lastScored = existing?.lastScoredDayEpoch;
    var streak = await _streakAsOf(_addDays(startEpoch, -1));

    var cursor = startEpoch;
    while (cursor < todayEpoch) {
      final dayDone = await _doneCountForDay(cursor);
      final dayFired = await _firedCountForDay(cursor);
      streak = dayDone > 0 ? streak + 1 : 0;
      final pts = BuddyScoringEngine.dailyScore(
        doneCount: dayDone,
        firedCount: dayFired,
        streakDays: streak,
      );
      total += pts;
      final stage = BuddyScoringEngine.stageFromScore(total);
      if (stage > maxStage) maxStage = stage;
      lastScored = cursor;
      cursor = _addDays(cursor, 1);
    }

    await _db.into(_db.buddyProgress).insertOnConflictUpdate(
          BuddyProgressCompanion.insert(
            buddyId: buddy.id,
            totalScore: Value(total),
            lastScoredDayEpoch: Value(lastScored),
            maxStageReached: Value(maxStage),
            updatedAt: DateTime.now(),
          ),
        );

    // v15: the buddy just levelled up. Queue the matching launcher icon so
    // it swaps to the evolved form the next time the app backgrounds.
    // reconcile() is only ever called for the user's *active* buddy (the
    // lifecycle hooks pass the selected one), so this always targets the
    // icon actually on the home screen. Gated on a real stage increase so
    // we never trigger a needless launcher refresh.
    if (maxStage > priorMaxStage) {
      LauncherIconBridge.queueForBuddy(buddy, stage: maxStage);
    }
  }

  /// Today's in-progress score. NOT persisted — recomputed each read so
  /// the avatar reacts to live taps.
  Future<int> _todayScoreFor(BuddyId buddy) async {
    final todayEpoch = _dayEpoch(DateTime.now());
    final done = await _doneCountForDay(todayEpoch);
    final fired = await _firedCountForDay(todayEpoch);
    final streak = await _streakAsOf(_addDays(todayEpoch, -1));
    final liveStreak = done > 0 ? streak + 1 : streak;
    return BuddyScoringEngine.dailyScore(
      doneCount: done,
      firedCount: fired,
      streakDays: liveStreak,
    );
  }

  /// Number of "done" responses (yes + manual_done) logged on a day.
  /// We dedupe per-habit so the same habit yes-tapped twice doesn't
  /// double-count.
  Future<int> _doneCountForDay(int dayEpoch) async {
    final range = _epochToUtcRange(dayEpoch);
    final rows = await (_db.select(_db.notificationLog)
          ..where((l) =>
              l.respondedAt.isBiggerOrEqualValue(range.$1) &
              l.respondedAt.isSmallerThanValue(range.$2) &
              (l.response.equals('yes') |
                  l.response.equals('manual_done'))))
        .get();
    final perHabit = <String>{};
    for (final r in rows) {
      perHabit.add(r.habitId);
    }
    return perHabit.length;
  }

  /// Number of habits the schedule actually fired today.
  Future<int> _firedCountForDay(int dayEpoch) async {
    final range = _epochToUtcRange(dayEpoch);
    final rows = await (_db.select(_db.notificationLog)
          ..where((l) =>
              l.firedAt.isBiggerOrEqualValue(range.$1) &
              l.firedAt.isSmallerThanValue(range.$2)))
        .get();
    final perHabit = <String>{};
    for (final r in rows) {
      perHabit.add(r.habitId);
    }
    return perHabit.length;
  }

  /// Walk back day-by-day from [endEpoch] (inclusive) and count
  /// consecutive days where the user logged ≥1 done. Caps at 365 to
  /// keep the scan bounded.
  Future<int> _streakAsOf(int endEpoch) async {
    var cursor = endEpoch;
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final done = await _doneCountForDay(cursor);
      if (done == 0) break;
      streak += 1;
      cursor = _addDays(cursor, -1);
    }
    return streak;
  }

  // ---- date helpers --------------------------------------------------

  /// YYYYMMDD encoding of the LOCAL calendar date. Calendar day is what
  /// the user sees; storing in UTC would shift days for east-of-UTC
  /// users.
  static int _dayEpoch(DateTime t) {
    final local = t.toLocal();
    return local.year * 10000 + local.month * 100 + local.day;
  }

  /// Convert YYYYMMDD back into the local-midnight → next-local-midnight
  /// range, but expressed in UTC for the query (`notificationLog`
  /// timestamps are stored in UTC). This way "today" lines up with the
  /// user's calendar regardless of timezone.
  static (DateTime, DateTime) _epochToUtcRange(int epoch) {
    final y = epoch ~/ 10000;
    final m = (epoch ~/ 100) % 100;
    final d = epoch % 100;
    final start = DateTime(y, m, d).toUtc();
    final end = DateTime(y, m, d).add(const Duration(days: 1)).toUtc();
    return (start, end);
  }

  static int _addDays(int epoch, int days) {
    final y = epoch ~/ 10000;
    final m = (epoch ~/ 100) % 100;
    final d = epoch % 100;
    final shifted = DateTime(y, m, d).add(Duration(days: days));
    return shifted.year * 10000 + shifted.month * 100 + shifted.day;
  }
}
