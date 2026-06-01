import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level guards on the new goal-creator wizard. We don't pump
/// the widget tree (it pushes the habit wizard which pushes drift
/// streams — easy to deadlock). The on-device walkthrough is what
/// catches behaviour; this just locks in the structural decisions.
void main() {
  final src = File('lib/features/plan/goal_creator_page.dart').readAsStringSync();
  final planSrc = File('lib/features/plan/plan_page.dart').readAsStringSync();

  test('GoalCreatorPage exists and pushes the habit wizard', () {
    expect(src.contains('class GoalCreatorPage'), isTrue);
    expect(src.contains('AddHabitPage(goalId: id)'), isTrue);
  });

  test('Add-a-goal flow no longer uses the crashing AlertDialog', () {
    // The AlertDialog with "Next: add a habit" was the source of both
    // red-screen crashes (tap outside + tap Next). Killed for stable.
    // (Other Plan-page dialogs — rename + archive confirm — are
    // unrelated; the crash was specifically in the add-goal path.)
    expect(planSrc.contains("Next: add a habit"), isFalse);
    expect(planSrc.contains('_promptForGoalTitle'), isFalse);
    expect(planSrc.contains("What's the goal?"), isFalse);
  });

  test('Plan page launches the goal creator wizard', () {
    expect(planSrc.contains('GoalCreatorPage()'), isTrue);
  });

  test('GoalCreatorPage archives empty goals on finish', () {
    expect(src.contains('archive(id)'), isTrue);
  });

  test('GoalCreatorPage back arrow steps back, only pops from step 0', () {
    expect(src.contains('PopScope'), isTrue);
    expect(src.contains('previousPage'), isTrue);
  });
}
