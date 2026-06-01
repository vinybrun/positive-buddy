import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/notifications/notification_copy.dart';
import 'package:habit_buddy/personalization/engine.dart';

const _profile = ProfileInput(
  tonePreference: 'mixed',
  dailyNotifBudget: 4,
  wakingStartHour: 7,
  wakingStartMinute: 0,
  wakingEndHour: 22,
  wakingEndMinute: 0,
);

PlannedOccurrence _planned(int hour, {String slotKind = 'priming'}) =>
    PlannedOccurrence(
      occurrence: Occurrence(
        habitId: 'h1',
        habitName: 'Walk',
        category: 'exercise',
        when: DateTime(2026, 5, 28, hour, 0),
        slotKind: slotKind,
      ),
      toneKey: 'mixed',
    );

void main() {
  group('Phase 3 — smartTimeShiftRule', () {
    test('shifts a priming occurrence to the highest-density active hour',
        () {
      final now = DateTime(2026, 5, 28, 12);
      // Heavy yes-responses at 19:00 over the last week → the engine should
      // move our noon-placeholder freq-habit nudge into the 7pm slot.
      final signals = [
        for (var d = 1; d <= 7; d++)
          EngagementSignal(
            kind: EngagementSignal.kindResponse,
            response: 'yes',
            ts: DateTime(2026, 5, 28 - d, 19, 5),
          ),
        for (var d = 1; d <= 7; d++)
          EngagementSignal(
            kind: EngagementSignal.kindAppOpen,
            ts: DateTime(2026, 5, 28 - d, 19, 0),
          ),
      ];
      final plan = PersonalizationPlan([_planned(12)]);
      final out = smartTimeShiftRule(
          plan,
          PersonalizationInput(
            profile: _profile,
            candidates: const [],
            now: now,
            signals: signals,
          ));
      expect(out.occurrences.first.occurrence.when.hour, 19);
    });

    test('leaves time-slot occurrences alone', () {
      final signals = [
        EngagementSignal(
            kind: EngagementSignal.kindAppOpen,
            ts: DateTime(2026, 5, 27, 19)),
      ];
      final plan = PersonalizationPlan([_planned(8, slotKind: 'time')]);
      final out = smartTimeShiftRule(
          plan,
          PersonalizationInput(
            profile: _profile,
            candidates: const [],
            now: DateTime(2026, 5, 28),
            signals: signals,
          ));
      // Time-slot occurrences are user-picked: never moved.
      expect(out.occurrences.first.occurrence.when.hour, 8);
    });

    test('returns the plan unchanged with no signals', () {
      final plan = PersonalizationPlan([_planned(12)]);
      final out = smartTimeShiftRule(
          plan,
          PersonalizationInput(
            profile: _profile,
            candidates: const [],
            now: DateTime(2026, 5, 28),
            signals: const [],
          ));
      expect(out.occurrences.first.occurrence.when.hour, 12);
    });
  });

  group('Phase 4 — classifyEngagement', () {
    final now = DateTime(2026, 5, 28, 12);

    test('active: a response within 3 days → active', () {
      final state = classifyEngagement(
        signals: [
          EngagementSignal(
              kind: EngagementSignal.kindResponse,
              response: 'yes',
              ts: now.subtract(const Duration(days: 1))),
        ],
        now: now,
      );
      expect(state, EngagementState.active);
    });

    test(
        'cooling: no response in 4 days but an app_open within 7 days → cooling',
        () {
      final state = classifyEngagement(
        signals: [
          EngagementSignal(
              kind: EngagementSignal.kindAppOpen,
              ts: now.subtract(const Duration(days: 4))),
        ],
        now: now,
      );
      expect(state, EngagementState.cooling);
    });

    test('dropped: nothing for 8+ days → dropped', () {
      final state = classifyEngagement(
        signals: [
          EngagementSignal(
              kind: EngagementSignal.kindAppOpen,
              ts: now.subtract(const Duration(days: 10))),
        ],
        now: now,
      );
      expect(state, EngagementState.dropped);
    });

    test('superseded: many manual_done with no lapses → superseded', () {
      final signals = <EngagementSignal>[];
      for (var i = 1; i <= 6; i++) {
        signals.add(EngagementSignal(
            kind: EngagementSignal.kindResponse,
            response: 'manual_done',
            ts: now.subtract(Duration(days: i))));
      }
      final state = classifyEngagement(signals: signals, now: now);
      expect(state, EngagementState.superseded);
    });
  });

  group('Phase 4 — adaptiveToneRule', () {
    test('overrides tone for cooling users', () {
      final plan = PersonalizationPlan([_planned(10)]);
      final out = adaptiveToneRule(
        plan,
        PersonalizationInput(
          profile: _profile,
          candidates: const [],
          now: DateTime(2026, 5, 28),
          engagementState: EngagementState.cooling,
        ),
      );
      expect(out.occurrences.first.toneKey, 'cooling');
    });

    test('leaves tone alone for active users', () {
      final plan = PersonalizationPlan([_planned(10)]);
      final out = adaptiveToneRule(
        plan,
        PersonalizationInput(
          profile: _profile,
          candidates: const [],
          now: DateTime(2026, 5, 28),
          engagementState: EngagementState.active,
        ),
      );
      expect(out.occurrences.first.toneKey, 'mixed');
    });
  });
}
