import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/habit_repository.dart';
import 'package:habit_buddy/features/habits/time_windows.dart';
import 'package:habit_buddy/features/habits/window_selection.dart';

void main() {
  group('WindowSelection JSON', () {
    test('multi-preset round-trips through toJsonString / fromDb', () {
      final sel = WindowSelection(
        windows: {TimeWindow.morning, TimeWindow.afternoon},
      );
      final json = sel.toJsonString();
      final back = WindowSelection.fromDb(
        timeWindowsJson: json,
        customStartMinutes: null,
        customEndMinutes: null,
      );
      expect(back.windows, {TimeWindow.morning, TimeWindow.afternoon});
      expect(back.hasCustomRange, isFalse);
    });

    test('custom range round-trips and ignores windowsJson', () {
      final sel = WindowSelection(
        windows: const {},
        customRange:
            const CustomTimeRange(startMinutes: 8 * 60, endMinutes: 11 * 60),
      );
      expect(sel.toJsonString(), '[]');
      final back = WindowSelection.fromDb(
        timeWindowsJson: '[]',
        customStartMinutes: 8 * 60,
        customEndMinutes: 11 * 60,
      );
      expect(back.hasCustomRange, isTrue);
      expect(back.customRange?.startMinutes, 8 * 60);
      expect(back.customRange?.endMinutes, 11 * 60);
    });

    test('falls back to legacy single-window when JSON is malformed', () {
      final back = WindowSelection.fromDb(
        timeWindowsJson: 'not-json',
        customStartMinutes: null,
        customEndMinutes: null,
        legacyTimeWindow: 'evening',
      );
      expect(back.windows, {TimeWindow.evening});
    });

    test('representativeWindowId prefers morning over anytime', () {
      final sel = WindowSelection(
        windows: {TimeWindow.anytime, TimeWindow.morning},
      );
      expect(sel.representativeWindowId, 'morning');
    });

    test('representative is anytime when only anytime is selected', () {
      final sel = WindowSelection(windows: {TimeWindow.anytime});
      expect(sel.representativeWindowId, 'anytime');
    });

    test('representative for custom range falls back to anytime', () {
      final sel = WindowSelection(
        windows: const {},
        customRange: const CustomTimeRange(startMinutes: 0, endMinutes: 60),
      );
      expect(sel.representativeWindowId, 'anytime');
    });
  });

  group('HabitRepository v5 multi-window persistence', () {
    late AppDb db;
    late HabitRepository repo;

    setUp(() {
      db = AppDb.forTesting(NativeDatabase.memory());
      repo = HabitRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('createTimeBasedHabit persists multi-window selection', () async {
      final id = await repo.createTimeBasedHabit(
        name: 'Stretch',
        category: 'exercise',
        times: const [TimeOfDay(hour: 8, minute: 0)],
        windowSelection: WindowSelection(
          windows: {TimeWindow.morning, TimeWindow.afternoon},
        ),
      );
      final h = await (db.select(db.habits)..where((x) => x.id.equals(id)))
          .getSingle();
      expect(h.timeWindowsJson, '["afternoon","morning"]');
      expect(h.customStartMinutes, isNull);
      expect(h.customEndMinutes, isNull);
      // Legacy column tracks the representative (morning wins by priority).
      expect(h.timeWindow, 'morning');
    });

    test('createTimeBasedHabit persists custom range, empties windows',
        () async {
      final id = await repo.createTimeBasedHabit(
        name: 'Sun',
        category: 'exercise',
        times: const [TimeOfDay(hour: 9, minute: 0)],
        windowSelection: WindowSelection(
          windows: const {},
          customRange: const CustomTimeRange(
              startMinutes: 8 * 60, endMinutes: 11 * 60),
        ),
      );
      final h = await (db.select(db.habits)..where((x) => x.id.equals(id)))
          .getSingle();
      expect(h.timeWindowsJson, '[]');
      expect(h.customStartMinutes, 8 * 60);
      expect(h.customEndMinutes, 11 * 60);
    });

    test('updateHabitWithSlots switches custom → presets, clears columns',
        () async {
      final id = await repo.createTimeBasedHabit(
        name: 'X',
        category: 'water',
        times: const [TimeOfDay(hour: 9, minute: 0)],
        windowSelection: WindowSelection(
          windows: const {},
          customRange: const CustomTimeRange(
              startMinutes: 14 * 60, endMinutes: 15 * 60),
        ),
      );
      await repo.updateHabitWithSlots(
        id: id,
        name: 'X',
        category: 'water',
        times: const [TimeOfDay(hour: 9, minute: 0)],
        windowSelection: WindowSelection(windows: {TimeWindow.evening}),
      );
      final h = await (db.select(db.habits)..where((x) => x.id.equals(id)))
          .getSingle();
      expect(h.timeWindowsJson, '["evening"]');
      expect(h.customStartMinutes, isNull);
      expect(h.customEndMinutes, isNull);
    });
  });
}
