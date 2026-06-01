import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/widgets/widget_data.dart';

int _r(int argb) => (argb >> 16) & 0xFF;
int _g(int argb) => (argb >> 8) & 0xFF;
int _b(int argb) => argb & 0xFF;
int _a(int argb) => (argb >> 24) & 0xFF;

void main() {
  group('WidgetColorMode.fromId', () {
    test('round-trips known ids and defaults to primary', () {
      expect(WidgetColorMode.fromId('progressive'), WidgetColorMode.progressive);
      expect(WidgetColorMode.fromId('primary'), WidgetColorMode.primary);
      expect(WidgetColorMode.fromId(null), WidgetColorMode.primary);
      expect(WidgetColorMode.fromId('garbage'), WidgetColorMode.primary);
    });
  });

  group('resolveProgressColor progressive', () {
    int colorAt(double pct) => resolveProgressColor(
          pct: pct,
          mode: WidgetColorMode.progressive,
          primaryColor: 0xFF123456,
        );

    test('0% is reddish (red dominates)', () {
      final c = colorAt(0);
      expect(_a(c), 0xFF);
      expect(_r(c) > _g(c), isTrue);
      expect(_r(c) > _b(c), isTrue);
    });

    test('50% is yellowish (red and green high, blue low)', () {
      final c = colorAt(0.5);
      expect(_r(c) > 150, isTrue);
      expect(_g(c) > 150, isTrue);
      expect(_b(c) < 80, isTrue);
    });

    test('100% is greenish (green dominates)', () {
      final c = colorAt(1.0);
      expect(_g(c) > _r(c), isTrue);
      expect(_g(c) > _b(c), isTrue);
    });

    test('clamps out-of-range pct', () {
      expect(colorAt(-5), colorAt(0));
      expect(colorAt(5), colorAt(1));
    });
  });

  group('resolveProgressColor primary', () {
    test('ignores pct and returns opaque primary', () {
      final c0 = resolveProgressColor(
          pct: 0, mode: WidgetColorMode.primary, primaryColor: 0x80123456);
      final c1 = resolveProgressColor(
          pct: 1, mode: WidgetColorMode.primary, primaryColor: 0x80123456);
      expect(c0, c1);
      expect(c0, 0xFF123456); // alpha forced opaque, rgb preserved
    });
  });

  group('WidgetSnapshot', () {
    WidgetSnapshot snap(int done, int total) => WidgetSnapshot(
          buddyAsset: 'assets/buddies/fox/idle.png',
          doneCount: done,
          totalCount: total,
          progressColor: 0xFFFF0000,
          trackColor: 0x33000000,
          circleColor: 0xFFEEEEEE,
          accentColor: 0xFF4C6FFF,
          bgColor: 0xFF1C1B1F,
          onBgColor: 0xFFFFFFFF,
          showCount: true,
          pendingHabits: const [
            (id: 'a', name: 'Drink water'),
            (id: 'b', name: 'Stretch'),
          ],
        );

    test('pct math', () {
      expect(snap(0, 0).pct, 0);
      expect(snap(0, 4).pct, 0);
      expect(snap(1, 4).pct, 25);
      expect(snap(2, 4).pct, 50);
      expect(snap(4, 4).pct, 100);
    });

    test('toEntries carries scalars and json-encoded habits', () {
      final e = snap(1, 4).toEntries();
      expect(e[widgetKeyBuddyAsset], 'assets/buddies/fox/idle.png');
      expect(e[widgetKeyDone], 1);
      expect(e[widgetKeyTotal], 4);
      expect(e[widgetKeyPct], 25);
      expect(e[widgetKeyProgressColor], 0xFFFF0000);
      final decoded = jsonDecode(e[widgetKeyHabits]! as String) as List;
      expect(decoded, hasLength(2));
      expect((decoded.first as Map)['name'], 'Drink water');
      expect((decoded.first as Map)['id'], 'a');
    });
  });

  group('parseDoneHabitId', () {
    test('extracts id from a done uri', () {
      final uri = Uri.parse('$widgetScheme://$widgetDoneHost?id=abc123');
      expect(parseDoneHabitId(uri), 'abc123');
    });

    test('returns null for non-done host, missing id, or null', () {
      expect(parseDoneHabitId(Uri.parse('$widgetScheme://other?id=x')), isNull);
      expect(parseDoneHabitId(Uri.parse('$widgetScheme://$widgetDoneHost')),
          isNull);
      expect(parseDoneHabitId(null), isNull);
    });
  });

  test('cappedHabitCount caps at maxWidgetHabits', () {
    expect(cappedHabitCount(3), 3);
    expect(cappedHabitCount(100), maxWidgetHabits);
  });
}
