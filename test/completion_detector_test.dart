import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/personalization/completion_detector.dart';

List<DailyOutcome> _outcomes(List<bool> yeses) {
  final start = DateTime(2026, 4, 1);
  return [
    for (var i = 0; i < yeses.length; i++)
      DailyOutcome(date: start.add(Duration(days: i)), didYes: yeses[i]),
  ];
}

void main() {
  group('evaluateDailyHabit', () {
    test('21+ consecutive yes days → eligible', () {
      final v = evaluateDailyHabit(_outcomes(List.filled(21, true)));
      expect(v.eligible, isTrue);
      expect(v.reason, contains('21'));
    });

    test('20 consecutive yes days → not yet', () {
      final v = evaluateDailyHabit(_outcomes(List.filled(20, true)));
      expect(v.eligible, isFalse);
    });

    test('28 days at 89% yes-rate → not yet (below threshold)', () {
      // The last day is `false`, so streak == 0 and the rate path
      // is the only one in play. 25/28 ≈ 89.3%, just under 90%.
      final pattern = List<bool>.generate(28, (i) => i % 10 != 0);
      expect(pattern.where((b) => b).length, 25);
      final v = evaluateDailyHabit(_outcomes(pattern));
      expect(v.eligible, isFalse);
    });

    test('28 days at >=90% yes-rate (26/28) → eligible', () {
      final pattern = List<bool>.generate(28, (i) => true);
      pattern[5] = false;
      // Put the last miss in the *middle* so the current streak is
      // 7 (under 21) — proves the rate path is what's triggering.
      pattern[15] = false;
      final v = evaluateDailyHabit(_outcomes(pattern));
      expect(v.eligible, isTrue);
    });

    test('empty history → not eligible', () {
      final v = evaluateDailyHabit(<DailyOutcome>[]);
      expect(v.eligible, isFalse);
    });
  });

  group('evaluateFrequencyHabit', () {
    test('4 consecutive weeks at target → eligible', () {
      final v = evaluateFrequencyHabit([
        for (var i = 0; i < 4; i++)
          WeeklyOutcome(
            weekStart: DateTime(2026, 4, 1).add(Duration(days: 7 * i)),
            yesCount: 3,
            target: 3,
          ),
      ]);
      expect(v.eligible, isTrue);
    });

    test('3 consecutive weeks at target → not yet', () {
      final v = evaluateFrequencyHabit([
        for (var i = 0; i < 3; i++)
          WeeklyOutcome(
            weekStart: DateTime(2026, 4, 1).add(Duration(days: 7 * i)),
            yesCount: 3,
            target: 3,
          ),
      ]);
      expect(v.eligible, isFalse);
    });

    test('streak resets on a missed week', () {
      final v = evaluateFrequencyHabit([
        for (var i = 0; i < 5; i++)
          WeeklyOutcome(
            weekStart: DateTime(2026, 4, 1).add(Duration(days: 7 * i)),
            yesCount: i == 2 ? 1 : 3,
            target: 3,
          ),
      ]);
      // Last 2 weeks at target; 3rd-last broke the streak.
      expect(v.eligible, isFalse);
    });
  });
}

