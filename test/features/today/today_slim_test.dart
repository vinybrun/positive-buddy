import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Source-level guard test: the cheap, reliable way to assert "we got rid of
// the edit affordances from Today" without spinning up the full widget tree
// (which deadlocks on the StreamProviders + reconcile timers).
void main() {
  final src = File('lib/features/today/today_page.dart').readAsStringSync();

  test('no inline _NoGoalsCard editor on Today', () {
    expect(src.contains('_NoGoalsCard'), isFalse);
    expect(src.contains('_promptForGoalTitle'), isFalse);
  });

  test('no per-goal "Add habit" button on Today', () {
    expect(src.contains('Add habit to this goal'), isFalse);
  });

  test('Today has no add-habit wizard, but long-press opens the editor', () {
    // No create flow on Today (that lives under Plan)...
    expect(src.contains("habits/add_habit_page.dart"), isFalse);
    // ...but a long-press on a habit tile jumps straight to editing it.
    expect(src.contains("habits/edit_habit_page.dart"), isTrue);
    expect(src.contains('onLongPress'), isTrue);
    expect(src.contains('EditHabitPage(habitId:'), isTrue);
  });

  test('Today does not show the orphans "Other" section', () {
    expect(src.contains('_GoalSection.orphan'), isFalse);
    expect(src.contains("'Other'"), isFalse);
  });

  test('Today wires Plan / Wins / You navigation', () {
    expect(src.contains('PlanPage()'), isTrue);
    expect(src.contains('WinsPage()'), isTrue);
    expect(src.contains('YouPage()'), isTrue);
  });

  test('Today renders a BuddyHero', () {
    expect(src.contains('_BuddyHero'), isTrue);
    expect(src.contains('BuddyAsset.forPose'), isTrue);
  });
}
