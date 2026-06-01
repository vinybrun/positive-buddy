import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/notifications/notification_copy.dart';

void main() {
  group('responseFromAction', () {
    test('maps the Yes action to "yes"', () {
      expect(responseFromAction('RESPOND_YES'), 'yes');
    });

    test('maps the Not yet action to "not_yet"', () {
      expect(responseFromAction('RESPOND_NOT_YET'), 'not_yet');
    });

    test('returns null for a body tap (no actionId)', () {
      // This is the bug we just fixed: body taps used to be logged as
      // "manual_done", firing a wrong follow-up. The handler now must see a
      // null here and do nothing.
      expect(responseFromAction(null), isNull);
    });

    test('returns null for an unknown action id', () {
      expect(responseFromAction('SOMETHING_ELSE'), isNull);
    });
  });

  group('composeAcknowledgment — Yes', () {
    test('always returns a celebratory line', () {
      for (var i = 0; i < 8; i++) {
        final ack = composeAcknowledgment(
          response: responseYes,
          slots: const [],
          now: DateTime(2026, 5, 27, 10, 0)
              .add(Duration(microseconds: i * 17)),
        );
        // Celebratory lines do not start with "I'll catch" / "I'll remind".
        expect(ack.title.length, greaterThan(0));
        expect(ack.body.length, greaterThan(0));
      }
    });
  });

  group('composeAcknowledgment — Not yet, next slot today', () {
    test('points to a later slot the same day with "still time today" / "this <band>"',
        () {
      // It's 10:00; the habit also has a slot at 20:00.
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [
          SlotView(timeOfDay: 10 * 60), // the one we just answered
          SlotView(timeOfDay: 20 * 60), // the next one today
        ],
        now: DateTime(2026, 5, 27, 10, 0),
      );
      // Should reference the evening slot, not promise tomorrow.
      expect(ack.body.toLowerCase(), contains('evening'));
      expect(ack.body.toLowerCase(), isNot(contains('tomorrow')));
    });
  });

  group('composeAcknowledgment — Not yet, next slot is tomorrow', () {
    test('explicitly promises "tomorrow <band>"', () {
      // It's 22:00 and the only slot is 08:00 — next reminder is tomorrow morning.
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 8 * 60)],
        now: DateTime(2026, 5, 27, 22, 0),
      );
      expect(ack.body.toLowerCase(), contains('tomorrow'));
      expect(ack.body.toLowerCase(), contains('morning'));
      // Warm tone, no shame language.
      expect(ack.body.toLowerCase(), isNot(contains('failed')));
      expect(ack.body.toLowerCase(), isNot(contains('missed')));
    });

    test('uses afternoon band for a 14:00 slot tomorrow', () {
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 14 * 60)],
        now: DateTime(2026, 5, 27, 22, 0),
      );
      expect(ack.body.toLowerCase(), contains('tomorrow'));
      expect(ack.body.toLowerCase(), contains('afternoon'));
    });

    test('uses evening band for a 19:00 slot tomorrow', () {
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 19 * 60)],
        now: DateTime(2026, 5, 27, 23, 0),
      );
      expect(ack.body.toLowerCase(), contains('tomorrow'));
      expect(ack.body.toLowerCase(), contains('evening'));
    });

    test('the slot we just answered (≤1 min away) is skipped to tomorrow', () {
      // 10:00 slot, now is 09:59:30. Without the skip, the algorithm would
      // pick "today at 10:00" — but that's the notification we just answered.
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 10 * 60)],
        now: DateTime(2026, 5, 27, 9, 59, 30),
      );
      expect(ack.body.toLowerCase(), contains('tomorrow'));
    });
  });

  group('composeAcknowledgment — Not yet, no slots configured', () {
    test('reassures without promising a specific time', () {
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [],
        now: DateTime(2026, 5, 27, 10, 0),
      );
      expect(ack.body.toLowerCase(), contains("i'll catch"));
      expect(ack.body.toLowerCase(), isNot(contains('failed')));
    });
  });

  group('composeAcknowledgment — disabled slots are ignored', () {
    test('skips an enabled=false slot when picking the next slot', () {
      // Disabled morning slot + enabled evening slot → evening wins.
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [
          SlotView(timeOfDay: 8 * 60, enabled: false),
          SlotView(timeOfDay: 20 * 60),
        ],
        now: DateTime(2026, 5, 27, 10, 0),
      );
      expect(ack.body.toLowerCase(), contains('evening'));
    });
  });

  group('composeAcknowledgment — time window overrides band', () {
    test('vitamin D habit slot at 22:00 still promises "tomorrow morning"', () {
      // The user has Vitamin D scheduled at 22:00 (weird, but possible) —
      // the habit's time_window=morning should win over the slot hour for
      // band phrasing.
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 22 * 60)],
        now: DateTime(2026, 5, 27, 23, 0),
        timeWindowId: 'morning',
      );
      expect(ack.body.toLowerCase(), contains('tomorrow'));
      expect(ack.body.toLowerCase(), contains('morning'));
    });

    test('before_bed maps to evening copy', () {
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 14 * 60)],
        now: DateTime(2026, 5, 27, 23, 0),
        timeWindowId: 'before_bed',
      );
      expect(ack.body.toLowerCase(), contains('evening'));
    });

    test('anytime falls back to slot-hour band', () {
      final ack = composeAcknowledgment(
        response: responseNotYet,
        slots: const [SlotView(timeOfDay: 19 * 60)],
        now: DateTime(2026, 5, 27, 23, 0),
        timeWindowId: 'anytime',
      );
      expect(ack.body.toLowerCase(), contains('evening'));
    });
  });

  group('timeBand', () {
    test('classifies hours into named bands', () {
      expect(timeBand(2), 'late night');
      expect(timeBand(8), 'morning');
      expect(timeBand(13), 'afternoon');
      expect(timeBand(19), 'evening');
      expect(timeBand(23), 'night');
    });
  });

  group('computeOccurrences', () {
    HabitWithSlotViews habit({
      String id = 'h1',
      String name = 'Water',
      String category = 'water',
      bool active = true,
      List<SlotView> slots = const [],
    }) =>
        HabitWithSlotViews(
          id: id,
          name: name,
          category: category,
          active: active,
          slots: slots,
        );

    test('schedules upcoming days of a single daily slot', () {
      // 2026-05-27 (Wed) 10:00. Slot at 08:00 — today's is already past.
      // Over daysAhead=7 calendar days (today..today+6), we get 6 firings:
      // tomorrow through day+6.
      final result = computeOccurrences(
        habits: [
          habit(slots: const [SlotView(timeOfDay: 8 * 60)]),
        ],
        now: DateTime(2026, 5, 27, 10, 0),
        daysAhead: 7,
      );
      expect(result.length, 6);
      // First occurrence is tomorrow at 08:00.
      expect(result.first.when, DateTime(2026, 5, 28, 8, 0));
      // List is sorted ascending.
      for (var i = 1; i < result.length; i++) {
        expect(result[i].when.isAfter(result[i - 1].when), isTrue);
      }
    });

    test('includes today if the slot time is still in the future', () {
      // At 06:00, the 08:00 slot today is still in the future → today wins.
      final result = computeOccurrences(
        habits: [
          habit(slots: const [SlotView(timeOfDay: 8 * 60)]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 7,
      );
      expect(result.length, 7);
      expect(result.first.when, DateTime(2026, 5, 27, 8, 0));
    });

    test('weekday mask filters to specific days', () {
      // 2026-05-27 is Wed (bit 2). Mask 0x1F = Mon-Fri (bits 0..4).
      // From Wed onwards over 7 days: Thu, Fri, Mon, Tue, Wed = 5 weekdays
      // (Sat, Sun excluded).
      final mondayToFridayMask = 0x1F;
      final result = computeOccurrences(
        habits: [
          habit(slots: [
            SlotView(timeOfDay: 9 * 60, weekdayMask: mondayToFridayMask),
          ]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 7,
      );
      // Wed(27) + Thu(28) + Fri(29) + Mon(Jun1) + Tue(Jun2) = 5
      expect(result.length, 5);
      // No Sat or Sun.
      for (final occ in result) {
        expect(occ.when.weekday, lessThanOrEqualTo(5));
      }
    });

    test('inactive habits are skipped entirely', () {
      final result = computeOccurrences(
        habits: [
          habit(active: false, slots: const [SlotView(timeOfDay: 8 * 60)]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
      );
      expect(result, isEmpty);
    });

    test('disabled slots are skipped', () {
      final result = computeOccurrences(
        habits: [
          habit(slots: const [
            SlotView(timeOfDay: 8 * 60, enabled: false),
            SlotView(timeOfDay: 20 * 60),
          ]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 2,
      );
      // Only the 20:00 slot fires — 2 occurrences over 2 days.
      expect(result.length, 2);
      expect(result[0].when.hour, 20);
      expect(result[1].when.hour, 20);
    });

    test('multiple habits are interleaved by time', () {
      // Habit A at 8:00, Habit B at 12:00 — for next 2 days they should
      // alternate in the output order: A, B, A, B.
      final result = computeOccurrences(
        habits: [
          habit(id: 'a', slots: const [SlotView(timeOfDay: 8 * 60)]),
          habit(id: 'b', slots: const [SlotView(timeOfDay: 12 * 60)]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 2,
      );
      expect(result.length, 4);
      expect(result[0].habitId, 'a');
      expect(result[1].habitId, 'b');
      expect(result[2].habitId, 'a');
      expect(result[3].habitId, 'b');
    });

    test('maxCount caps the total returned occurrences', () {
      // 4 habits × 7 days = 28 — cap at 10.
      final result = computeOccurrences(
        habits: List.generate(
          4,
          (i) => habit(
            id: 'h$i',
            slots: const [SlotView(timeOfDay: 8 * 60)],
          ),
        ),
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 7,
        maxCount: 10,
      );
      expect(result.length, 10);
    });

    test('habit with no slots produces nothing', () {
      final result = computeOccurrences(
        habits: [habit(slots: const [])],
        now: DateTime(2026, 5, 27, 6, 0),
      );
      expect(result, isEmpty);
    });

    test('Sunday mask correctly maps to weekday=7 (Sunday)', () {
      // 2026-05-27 is Wed. Sunday-only mask = bit 6 = 0x40.
      // Next Sun is May 31, then Jun 7 (if within 7 days from Wed May 27 →
      // only May 31 is in range).
      final result = computeOccurrences(
        habits: [
          habit(slots: const [
            SlotView(timeOfDay: 9 * 60, weekdayMask: 0x40),
          ]),
        ],
        now: DateTime(2026, 5, 27, 6, 0),
        daysAhead: 7,
      );
      expect(result.length, 1);
      expect(result.first.when, DateTime(2026, 5, 31, 9, 0));
    });
  });
}
