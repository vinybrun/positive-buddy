import 'package:flutter/material.dart';

import 'habit_categories.dart';

/// When during the day a habit is "supposed to" happen. Drives the auto-
/// suggested category mapping (Vitamin D → morning), the buddy copy, and
/// (later, Phase 4) the personalization engine's slot suppression.
enum TimeWindow {
  anytime('anytime', 'Anytime', 'whenever', null),
  morning('morning', 'Morning', 'this morning', '🌅'),
  afternoon('afternoon', 'Afternoon', 'this afternoon', '☀️'),
  evening('evening', 'Evening', 'this evening', '🌙'),
  beforeBed('before_bed', 'Before bed', 'before bed', '😴'),
  withMeals('with_meals', 'With meals', 'with a meal', '🍽️');

  const TimeWindow(this.id, this.label, this.bandPhrase, this.emoji);

  final String id;
  final String label;
  final String bandPhrase;
  final String? emoji;

  /// Time range (24h) that this window prefers. `null` for `anytime` /
  /// `withMeals` which don't bind to a single block.
  ({int startHour, int endHour})? get range => switch (this) {
        TimeWindow.morning => (startHour: 6, endHour: 11),
        TimeWindow.afternoon => (startHour: 12, endHour: 16),
        TimeWindow.evening => (startHour: 17, endHour: 20),
        TimeWindow.beforeBed => (startHour: 21, endHour: 23),
        TimeWindow.anytime || TimeWindow.withMeals => null,
      };

  /// Whether [hour] (0..23) falls inside this window. `anytime` and
  /// `withMeals` always match.
  bool containsHour(int hour) {
    final r = range;
    if (r == null) return true;
    return hour >= r.startHour && hour <= r.endHour;
  }

  /// A reasonable default reminder time for this window, used to prefill the
  /// time picker on Add Habit.
  TimeOfDay get suggestedTime => switch (this) {
        TimeWindow.morning => const TimeOfDay(hour: 8, minute: 0),
        TimeWindow.afternoon => const TimeOfDay(hour: 14, minute: 0),
        TimeWindow.evening => const TimeOfDay(hour: 19, minute: 0),
        TimeWindow.beforeBed => const TimeOfDay(hour: 22, minute: 0),
        TimeWindow.withMeals => const TimeOfDay(hour: 12, minute: 30),
        TimeWindow.anytime => const TimeOfDay(hour: 9, minute: 0),
      };

  static TimeWindow fromId(String? id) {
    if (id == null) return TimeWindow.anytime;
    return TimeWindow.values.firstWhere((w) => w.id == id,
        orElse: () => TimeWindow.anytime);
  }

  /// Best-guess time window for a habit category. The user is free to
  /// override on the form; this is just a starting point so the picker
  /// lands somewhere reasonable.
  static TimeWindow suggestForCategory(HabitCategory c) => switch (c) {
        HabitCategory.water => TimeWindow.anytime,
        HabitCategory.meds => TimeWindow.withMeals,
        HabitCategory.exercise => TimeWindow.morning,
        HabitCategory.mindfulness => TimeWindow.evening,
        HabitCategory.sleep => TimeWindow.beforeBed,
        HabitCategory.custom => TimeWindow.anytime,
      };

  /// Best-guess time window for a habit name (case-insensitive keywords).
  /// Used in addition to the category-based default for finer specificity
  /// — e.g. "Vitamin D" → morning even if the user picked Custom category.
  static TimeWindow? suggestForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('vitamin d') || n.contains('sunlight')) {
      return TimeWindow.morning;
    }
    if (n.contains('floss') ||
        n.contains('brush teeth') ||
        n.contains('dental') ||
        n.contains('mouthguard')) {
      return TimeWindow.beforeBed;
    }
    if (n.contains('stretch') ||
        n.contains('run') ||
        n.contains('jog') ||
        n.contains('walk') ||
        n.contains('workout') ||
        n.contains('gym')) {
      return TimeWindow.morning;
    }
    if (n.contains('meditat') || n.contains('journal')) {
      return TimeWindow.evening;
    }
    if (n.contains('vitamin') ||
        n.contains('supplement') ||
        n.contains('omega') ||
        n.contains('iron') ||
        n.contains('probiotic')) {
      return TimeWindow.withMeals;
    }
    return null;
  }

  IconData get icon => switch (this) {
        TimeWindow.morning => Icons.wb_sunny_outlined,
        TimeWindow.afternoon => Icons.wb_cloudy_outlined,
        TimeWindow.evening => Icons.nights_stay_outlined,
        TimeWindow.beforeBed => Icons.bedtime_outlined,
        TimeWindow.withMeals => Icons.restaurant_outlined,
        TimeWindow.anytime => Icons.all_inclusive,
      };
}
