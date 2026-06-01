import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/notifications/notification_copy.dart';
import 'package:habit_buddy/personalization/engine.dart';

void main() {
  Occurrence occ(String id, DateTime when, {String name = 'Water'}) =>
      Occurrence(
          habitId: id, habitName: name, category: 'water', when: when);

  ProfileInput profile({
    int budget = 4,
    int wakeStartHour = 7,
    int wakeStartMin = 0,
    int wakeEndHour = 22,
    int wakeEndMin = 0,
    String tone = 'mixed',
  }) =>
      ProfileInput(
        tonePreference: tone,
        dailyNotifBudget: budget,
        wakingStartHour: wakeStartHour,
        wakingStartMinute: wakeStartMin,
        wakingEndHour: wakeEndHour,
        wakingEndMinute: wakeEndMin,
      );

  group('quietHoursRule', () {
    test('drops occurrences before waking window', () {
      // Waking 07:00–22:00. A 05:00 reminder should be dropped.
      final plan = PersonalizationPlan([
        PlannedOccurrence(
          occurrence: occ('h1', DateTime(2026, 5, 27, 5, 0)),
          toneKey: 'mixed',
        ),
      ]);
      final result = quietHoursRule(
          plan,
          PersonalizationInput(
            profile: profile(),
            candidates: const [],
            now: DateTime(2026, 5, 27, 4, 0),
          ));
      expect(result.occurrences.first.dropped, isTrue);
    });

    test('drops occurrences after waking window', () {
      final plan = PersonalizationPlan([
        PlannedOccurrence(
          occurrence: occ('h1', DateTime(2026, 5, 27, 23, 0)),
          toneKey: 'mixed',
        ),
      ]);
      final result = quietHoursRule(
          plan,
          PersonalizationInput(
            profile: profile(),
            candidates: const [],
            now: DateTime(2026, 5, 27, 22, 30),
          ));
      expect(result.occurrences.first.dropped, isTrue);
    });

    test('keeps occurrences inside the window', () {
      final plan = PersonalizationPlan([
        PlannedOccurrence(
          occurrence: occ('h1', DateTime(2026, 5, 27, 10, 0)),
          toneKey: 'mixed',
        ),
      ]);
      final result = quietHoursRule(
          plan,
          PersonalizationInput(
            profile: profile(),
            candidates: const [],
            now: DateTime(2026, 5, 27, 9, 0),
          ));
      expect(result.occurrences.first.dropped, isFalse);
    });

    test('respects edge times exactly', () {
      // 07:00 sharp should be kept (the start of the window is inclusive).
      final plan = PersonalizationPlan([
        PlannedOccurrence(
          occurrence: occ('h1', DateTime(2026, 5, 27, 7, 0)),
          toneKey: 'mixed',
        ),
      ]);
      final result = quietHoursRule(
          plan,
          PersonalizationInput(
            profile: profile(),
            candidates: const [],
            now: DateTime(2026, 5, 27, 6, 0),
          ));
      expect(result.occurrences.first.dropped, isFalse);
    });
  });

  group('cadenceRule', () {
    test('caps a single day at the daily budget', () {
      // Budget=2, 4 reminders the same day → drops the latest 2.
      final candidates = [
        occ('h1', DateTime(2026, 5, 27, 8, 0)),
        occ('h2', DateTime(2026, 5, 27, 12, 0)),
        occ('h3', DateTime(2026, 5, 27, 16, 0)),
        occ('h4', DateTime(2026, 5, 27, 20, 0)),
      ];
      final plan = PersonalizationPlan(candidates
          .map((o) => PlannedOccurrence(occurrence: o, toneKey: 'mixed'))
          .toList());
      final result = cadenceRule(
          plan,
          PersonalizationInput(
            profile: profile(budget: 2),
            candidates: const [],
            now: DateTime(2026, 5, 27, 7, 0),
          ));
      // First two kept, last two dropped.
      expect(result.occurrences[0].dropped, isFalse);
      expect(result.occurrences[1].dropped, isFalse);
      expect(result.occurrences[2].dropped, isTrue);
      expect(result.occurrences[3].dropped, isTrue);
    });

    test('does not drop when under budget', () {
      final candidates = [
        occ('h1', DateTime(2026, 5, 27, 8, 0)),
        occ('h2', DateTime(2026, 5, 27, 20, 0)),
      ];
      final plan = PersonalizationPlan(candidates
          .map((o) => PlannedOccurrence(occurrence: o, toneKey: 'mixed'))
          .toList());
      final result = cadenceRule(
          plan,
          PersonalizationInput(
            profile: profile(budget: 4),
            candidates: const [],
            now: DateTime(2026, 5, 27, 7, 0),
          ));
      expect(result.occurrences.every((p) => !p.dropped), isTrue);
    });

    test('cap applies per calendar day, not across the window', () {
      // 3 same-day + 3 next-day. Budget=2 → 1 dropped per day = 2 total.
      final candidates = [
        occ('h1', DateTime(2026, 5, 27, 8, 0)),
        occ('h1', DateTime(2026, 5, 27, 14, 0)),
        occ('h1', DateTime(2026, 5, 27, 20, 0)),
        occ('h1', DateTime(2026, 5, 28, 8, 0)),
        occ('h1', DateTime(2026, 5, 28, 14, 0)),
        occ('h1', DateTime(2026, 5, 28, 20, 0)),
      ];
      final plan = PersonalizationPlan(candidates
          .map((o) => PlannedOccurrence(occurrence: o, toneKey: 'mixed'))
          .toList());
      final result = cadenceRule(
          plan,
          PersonalizationInput(
            profile: profile(budget: 2),
            candidates: const [],
            now: DateTime(2026, 5, 27, 7, 0),
          ));
      final dropped =
          result.occurrences.where((p) => p.dropped).toList();
      expect(dropped.length, 2);
      // The dropped ones should be the LAST of each day (20:00 entries).
      for (final d in dropped) {
        expect(d.occurrence.when.hour, 20);
      }
    });
  });

  group('PersonalizationEngine end-to-end', () {
    test('combines quiet hours + cadence', () {
      // Waking 07:00–22:00, budget=2. Candidates: 05:00 (drop quiet),
      // 08:00 (keep), 12:00 (keep), 16:00 (drop budget), 23:00 (drop quiet).
      final candidates = [
        occ('h', DateTime(2026, 5, 27, 5, 0)),
        occ('h', DateTime(2026, 5, 27, 8, 0)),
        occ('h', DateTime(2026, 5, 27, 12, 0)),
        occ('h', DateTime(2026, 5, 27, 16, 0)),
        occ('h', DateTime(2026, 5, 27, 23, 0)),
      ];
      final engine = PersonalizationEngine(defaultRules());
      final plan = engine.plan(PersonalizationInput(
        profile: profile(budget: 2),
        candidates: candidates,
        now: DateTime(2026, 5, 27, 4, 0),
      ));
      final keepers = plan.keepers;
      expect(keepers.length, 2);
      expect(keepers[0].occurrence.when.hour, 8);
      expect(keepers[1].occurrence.when.hour, 12);
    });

    test('tone defaults match preference', () {
      final engine = PersonalizationEngine(defaultRules());
      final out = engine.plan(PersonalizationInput(
        profile: profile(tone: 'direct'),
        candidates: [occ('h', DateTime(2026, 5, 27, 10, 0))],
        now: DateTime(2026, 5, 27, 9, 0),
      ));
      expect(out.keepers.first.toneKey, 'direct');
    });

    test('auto tone falls back to mixed when no signals available', () {
      final engine = PersonalizationEngine(defaultRules());
      final out = engine.plan(PersonalizationInput(
        profile: profile(tone: 'auto'),
        candidates: [occ('h', DateTime(2026, 5, 27, 10, 0))],
        now: DateTime(2026, 5, 27, 9, 0),
      ));
      expect(out.keepers.first.toneKey, 'mixed');
    });
  });
}
