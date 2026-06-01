/// Pure scoring math for the buddy-evolution system. No state, no side
/// effects, no async — every input is explicit so the rules can be
/// unit-tested without spinning up a DB.
///
/// The arc the points are designed for:
///
///   - **Volume rewards work**: the more habits you actually do, the
///     more you earn that day.
///   - **Consistency rewards intent**: if you've set up 12 habits but
///     do 2, that's worse than someone who set up 1 and did it. The
///     completion-rate tiers up your score so the 1/1 user is still
///     evolving steadily.
///   - **Streaks compound**: a per-7-day perpetual bonus credits people
///     who keep showing up over weeks.
///   - **You never lose ground**: scores are monotonically
///     non-decreasing. A bad week pauses growth but doesn't roll the
///     buddy back.
class BuddyScoringEngine {
  BuddyScoringEngine._();

  /// Cumulative thresholds for each stage. Index = stage; values are the
  /// minimum total score to reach that stage. Heavy users (~12 pts/day)
  /// hit max in ~5-6 weeks; light-but-consistent users (~5 pts/day) hit
  /// max in ~3 months. Both are reachable; that's the point.
  static const List<int> stageThresholds = [0, 25, 75, 175, 400];

  static int get maxStage => stageThresholds.length - 1;

  /// Map cumulative score → current stage. Stage is 0-indexed, so a
  /// fresh buddy is stage 0 (the picker form).
  static int stageFromScore(int score) {
    for (var i = stageThresholds.length - 1; i >= 0; i--) {
      if (score >= stageThresholds[i]) return i;
    }
    return 0;
  }

  /// How far [score] sits between the current stage's threshold and the
  /// next one, as a 0..1 fraction. Used to fill the evolution ring around
  /// a buddy in the picker. At (or past) the final stage the buddy is
  /// fully evolved, so this returns 1.0.
  static double progressToNextStage(int score) {
    final stage = stageFromScore(score);
    if (stage >= maxStage) return 1.0;
    final lower = stageThresholds[stage];
    final upper = stageThresholds[stage + 1];
    if (upper <= lower) return 1.0;
    final frac = (score - lower) / (upper - lower);
    return frac.clamp(0.0, 1.0);
  }

  /// Daily score formula. All inputs are non-negative integers.
  ///
  /// - [doneCount]: habits the user actually completed today (yes +
  ///   manual_done).
  /// - [firedCount]: habits the schedule asked for today (number of
  ///   notification fires). When 0, only manual completions count and
  ///   the consistency bonus is skipped (no proposal to measure against).
  /// - [streakDays]: consecutive days the user did *something* (≥1
  ///   completion). A 14-day streak earns +2 perpetual streak bonus.
  static int dailyScore({
    required int doneCount,
    required int firedCount,
    required int streakDays,
  }) {
    if (doneCount < 0 || firedCount < 0 || streakDays < 0) return 0;
    final base = doneCount;
    final consistencyBonus = _consistencyBonus(doneCount, firedCount);
    final streakBonus = streakDays ~/ 7;
    return base + consistencyBonus + streakBonus;
  }

  static int _consistencyBonus(int done, int fired) {
    // If nothing was scheduled, we can't measure rate. Skip the bonus —
    // base already credits the manual-done volume.
    if (fired <= 0) return 0;
    final rate = done / fired;
    if (rate >= 0.9) return 3;
    if (rate >= 0.7) return 2;
    if (rate >= 0.5) return 1;
    return 0;
  }
}
