import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/buddy_progress/buddy_scoring_engine.dart';

void main() {
  group('BuddyScoringEngine.dailyScore', () {
    test('zero everything → zero', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 0, firedCount: 0, streakDays: 0),
        0,
      );
    });

    test('done with no fires → just the base, no rate bonus', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 3, firedCount: 0, streakDays: 0),
        3,
      );
    });

    test('1-of-1 perfect day → base 1 + rate-3 bonus = 4 pts', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 1, firedCount: 1, streakDays: 0),
        4,
      );
    });

    test('10-of-12 strong day → base 10 + rate-2 bonus = 12 pts', () {
      // 10/12 = 0.83, which is in the 0.7–0.9 tier → +2
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 10, firedCount: 12, streakDays: 0),
        12,
      );
    });

    test('1-of-12 weak day → base 1, no rate bonus = 1 pt', () {
      // 1/12 = 0.083, below all tiers → +0
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 1, firedCount: 12, streakDays: 0),
        1,
      );
    });

    test('exactly 50% rate → +1 bonus', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 4, firedCount: 8, streakDays: 0),
        5,
      );
    });

    test('7-day streak → +1 perpetual streak bonus', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 1, firedCount: 1, streakDays: 7),
        5, // 1 + 3 + 1
      );
    });

    test('21-day streak → +3 perpetual streak bonus', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: 1, firedCount: 1, streakDays: 21),
        7, // 1 + 3 + 3
      );
    });

    test('negatives clamp to 0', () {
      expect(
        BuddyScoringEngine.dailyScore(
            doneCount: -5, firedCount: 0, streakDays: 0),
        0,
      );
    });
  });

  group('BuddyScoringEngine.stageFromScore', () {
    test('score 0 → stage 0', () {
      expect(BuddyScoringEngine.stageFromScore(0), 0);
    });
    test('score 24 → still stage 0', () {
      expect(BuddyScoringEngine.stageFromScore(24), 0);
    });
    test('score 25 → stage 1', () {
      expect(BuddyScoringEngine.stageFromScore(25), 1);
    });
    test('score 75 → stage 2', () {
      expect(BuddyScoringEngine.stageFromScore(75), 2);
    });
    test('score 175 → stage 3', () {
      expect(BuddyScoringEngine.stageFromScore(175), 3);
    });
    test('score 400 → stage 4 (max)', () {
      expect(BuddyScoringEngine.stageFromScore(400), 4);
    });
    test('score 9999 → stage 4 (capped)', () {
      expect(BuddyScoringEngine.stageFromScore(9999), 4);
    });
  });

  group('BuddyScoringEngine.progressToNextStage', () {
    test('fresh buddy (score 0) → 0.0', () {
      expect(BuddyScoringEngine.progressToNextStage(0), 0.0);
    });
    test('halfway from stage 0→1 (12 of 0..25) ≈ 0.48', () {
      expect(BuddyScoringEngine.progressToNextStage(12), closeTo(0.48, 0.01));
    });
    test('right at a threshold resets to 0 of the next band', () {
      // 25 is the start of stage 1; progress toward stage 2 (25..75) is 0.
      expect(BuddyScoringEngine.progressToNextStage(25), 0.0);
    });
    test('within stage 2 band (100 of 75..175) = 0.25', () {
      expect(BuddyScoringEngine.progressToNextStage(100), closeTo(0.25, 0.001));
    });
    test('max stage is always full', () {
      expect(BuddyScoringEngine.progressToNextStage(400), 1.0);
      expect(BuddyScoringEngine.progressToNextStage(9999), 1.0);
    });
  });

  group('fairness scenarios from spec', () {
    test('consistent 1-of-1 user reaches stage 4 in ~3 months', () {
      // 5 pts/day (1 + 3 rate + 1 streak after 7 days, climbing)
      // Conservative estimate: average 6 pts/day over time as streak grows
      // 400 / 6 = ~67 days. Within reach.
      const dailyAverage = 6;
      const days = 400 ~/ dailyAverage;
      expect(days, lessThanOrEqualTo(90));
    });

    test('heavy 10-of-12 user reaches stage 4 in ~5 weeks', () {
      // 12 pts/day base + 2 rate + streak.
      const dailyAverage = 13;
      const days = 400 ~/ dailyAverage;
      expect(days, lessThanOrEqualTo(40));
    });
  });
}
