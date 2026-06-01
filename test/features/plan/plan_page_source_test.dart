import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final src = File('lib/features/plan/plan_page.dart').readAsStringSync();

  test('Plan page imports AddHabitPage and EditHabitPage', () {
    // These editors used to live on Today; Phase 2 moved them here.
    expect(src.contains("habits/add_habit_page.dart"), isTrue);
    expect(src.contains("habits/edit_habit_page.dart"), isTrue);
  });

  test('Plan page renders an Add goal tile and per-goal Add habit', () {
    expect(src.contains('Add a goal'), isTrue);
    expect(src.contains('Add habit'), isTrue);
  });

  test('Plan page archives a goal when the user cancels the habit step', () {
    // The transactional add-goal flow (rollback if habit step aborted)
    // is the Phase 5 guarantee. Source-guard ensures we wired it.
    expect(src.contains('goalRepositoryProvider).archive'), isTrue);
  });

  test('Plan page surfaces rename + archive in the goal menu', () {
    expect(src.contains('_GoalAction.rename'), isTrue);
    expect(src.contains('_GoalAction.archive'), isTrue);
  });
}
