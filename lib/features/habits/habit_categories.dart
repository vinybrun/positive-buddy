import 'package:flutter/material.dart';

enum HabitCategory {
  water('water', 'Water', '💧', 'Quick check 💧'),
  meds('meds', 'Meds', '💊', 'Meds time'),
  exercise('exercise', 'Movement', '🏃', 'Movement time'),
  mindfulness('mindfulness', 'Mindfulness', '🧘', 'A moment for you'),
  sleep('sleep', 'Sleep', '🌙', 'Wind-down check'),
  custom('custom', 'Other', '✨', 'Quick check');

  const HabitCategory(this.id, this.label, this.emoji, this.promptTitle);

  final String id;
  final String label;
  final String emoji;
  final String promptTitle;

  String promptFor(String name) => 'Did you $name?';

  IconData get icon => switch (this) {
        HabitCategory.water => Icons.water_drop_outlined,
        HabitCategory.meds => Icons.medication_outlined,
        HabitCategory.exercise => Icons.directions_run,
        HabitCategory.mindfulness => Icons.self_improvement,
        HabitCategory.sleep => Icons.nightlight_outlined,
        HabitCategory.custom => Icons.auto_awesome_outlined,
      };

  static HabitCategory fromId(String id) =>
      HabitCategory.values.firstWhere((c) => c.id == id,
          orElse: () => HabitCategory.custom);
}
