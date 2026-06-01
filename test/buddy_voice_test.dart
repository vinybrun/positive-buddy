import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/notifications/notification_copy.dart';
import 'package:habit_buddy/personalization/buddy_voice.dart';
import 'package:habit_buddy/theme/buddy.dart';

void main() {
  group('greetingFor', () {
    test('null buddy falls back to a buddy-agnostic greeting', () {
      expect(greetingFor(null, 0), contains('Nothing'));
      expect(greetingFor(null, 3), contains('3 left'));
    });

    test('buddy is named in the greeting', () {
      for (final b in BuddyId.values) {
        final s = greetingFor(b, 2);
        expect(s, contains(b.label));
      }
    });

    test('singular vs plural matches pending count', () {
      expect(greetingFor(BuddyId.fox, 1), contains('1 thing left'));
      expect(greetingFor(BuddyId.fox, 4), contains('4 things left'));
    });

    test('zero-pending greeting is upbeat per buddy', () {
      for (final b in BuddyId.values) {
        final s = greetingFor(b, 0);
        expect(s, contains(b.label));
      }
    });
  });

  group('yesAcksFor', () {
    test('default pool is non-empty when no buddy is picked', () {
      expect(yesAcksFor(null).length, greaterThan(0));
    });

    test('each buddy has its own pool with distinct titles', () {
      final titles = <BuddyId, Set<String>>{};
      for (final b in BuddyId.values) {
        final pool = yesAcksFor(b);
        expect(pool.length, greaterThanOrEqualTo(5));
        titles[b] = pool.map((p) => p.$1).toSet();
      }
      // Cat's pool and Dog's pool should not be identical sets — quick
      // sanity check that we didn't accidentally share lists.
      expect(titles[BuddyId.cat], isNot(equals(titles[BuddyId.dog])));
    });
  });

  group('composeAcknowledgment threading', () {
    test('YES with buddy=fox picks a fox-flavored title', () {
      // Stitch enough timestamps to cycle through the pool so we catch at
      // least one of the fox lines.
      final foxTitles = yesAcksFor(BuddyId.fox).map((p) => p.$1).toSet();
      final defaultTitles =
          yesAcksFor(null).map((p) => p.$1).toSet();
      // Confirm the two pools don't overlap — otherwise this test is meaningless.
      expect(foxTitles.intersection(defaultTitles), isEmpty);
      // Cycle through many `now` values until we hit a fox-flavored title.
      var sawFox = false;
      for (var i = 0; i < 200 && !sawFox; i++) {
        final ack = composeAcknowledgment(
          response: 'yes',
          slots: const [],
          now: DateTime.fromMicrosecondsSinceEpoch(i),
          buddy: BuddyId.fox,
        );
        if (foxTitles.contains(ack.title)) sawFox = true;
      }
      expect(sawFox, isTrue);
    });

    test('null buddy keeps v1 default titles', () {
      final defaultTitles = yesAcksFor(null).map((p) => p.$1).toSet();
      final ack = composeAcknowledgment(
        response: 'yes',
        slots: const [],
        now: DateTime.fromMicrosecondsSinceEpoch(0),
        buddy: null,
      );
      expect(defaultTitles, contains(ack.title));
    });
  });
}
