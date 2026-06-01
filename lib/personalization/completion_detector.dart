/// Phase 5 — pure Dart completion heuristics. Given a habit's recent
/// yes/no log history, decides whether the user is "ready to graduate"
/// the habit. The app surfaces this as a celebratory prompt; the user
/// still confirms.
///
/// Kept Flutter/drift-free so it unit-tests cleanly.
library;

/// One day's outcome for a daily habit: did the user log a yes?
class DailyOutcome {
  const DailyOutcome({required this.date, required this.didYes});
  final DateTime date;
  final bool didYes;
}

/// One week's outcome for a frequency habit: how many yeses vs the
/// weekly target.
class WeeklyOutcome {
  const WeeklyOutcome({
    required this.weekStart,
    required this.yesCount,
    required this.target,
  });
  final DateTime weekStart;
  final int yesCount;
  final int target;

  bool get metTarget => yesCount >= target;
}

class GraduationVerdict {
  const GraduationVerdict({
    required this.eligible,
    required this.reason,
  });
  final bool eligible;
  final String reason;
}

const int dailyStreakThreshold = 21;
const double dailyRateThreshold = 0.9;
const int dailyRateWindow = 28;
const int weeklyMetStreakThreshold = 4;

/// Daily habit graduation: 21+ consecutive yes days (the canonical
/// "habit formed" heuristic from the behavioral-change literature) OR
/// 28 days with ≥90% yes-rate (catches users who miss occasionally but
/// are clearly living the habit).
GraduationVerdict evaluateDailyHabit(List<DailyOutcome> history) {
  if (history.isEmpty) {
    return const GraduationVerdict(
        eligible: false, reason: 'No log history yet.');
  }
  final sorted = [...history]
    ..sort((a, b) => a.date.compareTo(b.date));
  // Reverse-walk to count current streak.
  var streak = 0;
  for (var i = sorted.length - 1; i >= 0; i--) {
    if (sorted[i].didYes) {
      streak++;
    } else {
      break;
    }
  }
  if (streak >= dailyStreakThreshold) {
    return GraduationVerdict(
      eligible: true,
      reason: '$streak-day streak — that\'s a habit.',
    );
  }
  // 28-day window with ≥90% yes-rate.
  if (sorted.length >= dailyRateWindow) {
    final last28 = sorted.sublist(sorted.length - dailyRateWindow);
    final yesCount = last28.where((d) => d.didYes).length;
    final rate = yesCount / dailyRateWindow;
    if (rate >= dailyRateThreshold) {
      return GraduationVerdict(
        eligible: true,
        reason:
            'Hit it $yesCount of $dailyRateWindow days — you\'ve got it.',
      );
    }
  }
  return GraduationVerdict(
    eligible: false,
    reason: 'Current streak: $streak day(s). Keep going.',
  );
}

/// Frequency habit graduation: 4+ consecutive weeks at or above the
/// weekly target.
GraduationVerdict evaluateFrequencyHabit(List<WeeklyOutcome> history) {
  if (history.isEmpty) {
    return const GraduationVerdict(
        eligible: false, reason: 'No log history yet.');
  }
  final sorted = [...history]
    ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  var streak = 0;
  for (var i = sorted.length - 1; i >= 0; i--) {
    if (sorted[i].metTarget) {
      streak++;
    } else {
      break;
    }
  }
  if (streak >= weeklyMetStreakThreshold) {
    return GraduationVerdict(
      eligible: true,
      reason: '$streak weeks in a row at target — that\'s mastery.',
    );
  }
  return GraduationVerdict(
    eligible: false,
    reason: '$streak week(s) at target. Keep stacking.',
  );
}
