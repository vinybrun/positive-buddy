import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/theme/buddy.dart';

void main() {
  group('UserSettings.parseBuddyOrder', () {
    test('empty / null → default order (staged species first)', () {
      expect(UserSettings.parseBuddyOrder(null),
          UserSettings.defaultBuddyOrder);
      expect(UserSettings.parseBuddyOrder(''), UserSettings.defaultBuddyOrder);
      // The default really does lead with the evolving buddies.
      expect(UserSettings.defaultBuddyOrder.take(3),
          BuddyId.values.where((b) => b.hasStages));
    });

    test('round-trips a custom order', () {
      final order = [BuddyId.cat, BuddyId.fox, BuddyId.snake, BuddyId.bird,
          BuddyId.dog, BuddyId.butterfly];
      final json = UserSettings.encodeBuddyOrder(order);
      expect(UserSettings.parseBuddyOrder(json), order);
    });

    test('backfills buddies missing from a partial stored list', () {
      // Only cat persisted — the rest append in default order behind it.
      final json = UserSettings.encodeBuddyOrder([BuddyId.cat]);
      final parsed = UserSettings.parseBuddyOrder(json);
      expect(parsed.first, BuddyId.cat);
      expect(parsed.toSet(), BuddyId.values.toSet(),
          reason: 'always a full permutation');
      expect(parsed.length, BuddyId.values.length);
    });

    test('ignores unknown / duplicate ids and stays a full permutation', () {
      final parsed = UserSettings.parseBuddyOrder('["cat","cat","dragon"]');
      expect(parsed.first, BuddyId.cat);
      expect(parsed.toSet(), BuddyId.values.toSet());
      expect(parsed.length, BuddyId.values.length);
    });

    test('malformed json → default order', () {
      expect(UserSettings.parseBuddyOrder('{not json'),
          UserSettings.defaultBuddyOrder);
    });
  });
}
