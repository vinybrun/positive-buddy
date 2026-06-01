import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/habit_repository.dart';
import 'package:habit_buddy/features/habits/add_habit_page.dart';
import 'package:habit_buddy/features/notifications/local_notification_service.dart';

/// Stand-in so the wizard's progressive-save can fire `reconcile` without
/// touching platform channels in a widget test.
class _NoopNotif extends LocalNotificationService {
  @override
  Future<void> reconcile(AppDb db) async {}
}

/// Two flavors:
///   - Source guard on the wizard file (window before times, alarm style,
///     PopScope, back-only-pops-at-step-0).
///   - Repo-level guard on the alarm-style branch in createTimeBasedHabit
///     and updateHabitWithSlots — they must produce the right slot kind
///     so the wizard's progressive saves don't silently convert habits.
void main() {
  final wizardSrc = File('lib/features/habits/add_habit_page.dart')
      .readAsStringSync();

  group('Wizard source guards', () {
    test('window step comes before style + details', () {
      // Pages list in order: name, category, when, style, details.
      final nameIdx = wizardSrc.indexOf('_NameStep(');
      final catIdx = wizardSrc.indexOf('_CategoryStep(');
      final whenIdx = wizardSrc.indexOf('_WhenStep(');
      final styleIdx = wizardSrc.indexOf('_StyleStep(');
      expect(nameIdx, lessThan(catIdx));
      expect(catIdx, lessThan(whenIdx));
      expect(whenIdx, lessThan(styleIdx),
          reason: 'Window should be asked before Style + details');
    });

    test('alarm style is "flexible" by default', () {
      expect(wizardSrc.contains('_AlarmStyle _alarmStyle = _AlarmStyle.flexible'),
          isTrue);
    });

    test('back arrow steps back via PopScope, only pops at step 0', () {
      expect(wizardSrc.contains('PopScope'), isTrue);
      expect(wizardSrc.contains('automaticallyImplyLeading: false'), isTrue);
      expect(wizardSrc.contains('previousPage'), isTrue);
    });

    test('progressive save: persist creates on first call, updates after', () {
      // _persist() should call create if _habitId is null, update if not.
      expect(wizardSrc.contains('if (_habitId == null)'), isTrue);
      expect(wizardSrc.contains('createTimeBasedHabit('), isTrue);
      expect(wizardSrc.contains('updateHabitWithSlots('), isTrue);
    });
  });

  group('HabitRepository alarm style behaviour', () {
    late AppDb db;
    late HabitRepository repo;

    setUp(() async {
      db = AppDb.forTesting(NativeDatabase.memory());
      repo = HabitRepository(db);
      // Goals table needs at least one row since habits FK to it.
      await db.into(db.goals).insert(GoalsCompanion.insert(
            id: 'g1',
            title: 'Test goal',
            createdAt: DateTime.now(),
          ));
    });

    tearDown(() async {
      await db.close();
    });

    test('flexible alarm creates a single priming slot, not time slots',
        () async {
      final id = await repo.createTimeBasedHabit(
        name: 'Read',
        category: 'water',
        times: const [TimeOfDay(hour: 8, minute: 0)],
        goalId: 'g1',
        alarmStyle: 'flexible',
      );
      final slots = await (db.select(db.scheduleSlots)
            ..where((s) => s.habitId.equals(id)))
          .get();
      expect(slots.length, 1);
      expect(slots.first.kind, 'priming');
      // Placeholder at noon — engine shifts based on signals + window.
      expect(slots.first.timeOfDay, 12 * 60);
    });

    test('fixed alarm creates time slots matching the user picks', () async {
      final id = await repo.createTimeBasedHabit(
        name: 'Read',
        category: 'water',
        times: const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 21, minute: 30),
        ],
        goalId: 'g1',
        alarmStyle: 'fixed',
      );
      final slots = await (db.select(db.scheduleSlots)
            ..where((s) => s.habitId.equals(id))
            ..orderBy([(s) => OrderingTerm.asc(s.timeOfDay)]))
          .get();
      expect(slots.length, 2);
      expect(slots.every((s) => s.kind == 'time'), isTrue);
      expect(slots[0].timeOfDay, 8 * 60);
      expect(slots[1].timeOfDay, 21 * 60 + 30);
    });

    test('update flips flexible → fixed by rewriting slots', () async {
      final id = await repo.createTimeBasedHabit(
        name: 'Read',
        category: 'water',
        times: const [TimeOfDay(hour: 8, minute: 0)],
        goalId: 'g1',
        alarmStyle: 'flexible',
      );
      await repo.updateHabitWithSlots(
        id: id,
        name: 'Read',
        category: 'water',
        times: const [TimeOfDay(hour: 9, minute: 0)],
        alarmStyle: 'fixed',
      );
      final slots = await (db.select(db.scheduleSlots)
            ..where((s) => s.habitId.equals(id)))
          .get();
      expect(slots.length, 1);
      expect(slots.first.kind, 'time');
      expect(slots.first.timeOfDay, 9 * 60);
    });
  });

  group('Add-habit route contract', () {
    // Regression: AddHabitPage pops with the new habit's id (a String?).
    // plan_page used to push it as MaterialPageRoute<bool>, so the final
    // `Navigator.pop(habitId)` threw "type 'String' is not a subtype of
    // type 'bool?'" — the wizard never closed and Save looked dead. This
    // only bit the *second* habit on a goal, because the first-habit path
    // (goal_creator_page) already used the correct <String?> route.
    test('plan_page pushes AddHabitPage with a String? route, not <bool>', () {
      final planSrc = File('lib/features/plan/plan_page.dart').readAsStringSync();
      // The AddHabitPage push must be typed <String?>.
      final addIdx = planSrc.indexOf('AddHabitPage(goalId: widget.goal.id)');
      expect(addIdx, greaterThan(-1));
      final before = planSrc.substring(0, addIdx);
      final routeStart = before.lastIndexOf('MaterialPageRoute<');
      expect(routeStart, greaterThan(-1));
      final routeType = before.substring(routeStart);
      expect(routeType.startsWith('MaterialPageRoute<String?>'), isTrue,
          reason: 'AddHabitPage pops a String id; route must be <String?>');
    });

    testWidgets('driving the wizard to Save pops with a String id (no throw)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDb.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db.into(db.goals).insert(GoalsCompanion.insert(
            id: 'g1',
            title: 'Test goal',
            createdAt: DateTime.now(),
          ));

      Object? popped = 'unset';
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appDbProvider.overrideWithValue(db),
          localNotificationServiceProvider.overrideWithValue(_NoopNotif()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .push<String?>(MaterialPageRoute<String?>(
                        builder: (_) => const AddHabitPage(goalId: 'g1'),
                      ))
                      .then((v) => popped = v),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Bounded pump: each Next/Save fires a progressive save that briefly
      // shows a CircularProgressIndicator (an *infinite* animation), so
      // pumpAndSettle would hang. Step the clock in fixed chunks instead —
      // long enough for the in-memory write to resolve and the page/route
      // transition to finish.
      Future<void> grind() async {
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // Name → enables Next.
      await tester.enterText(find.byType(TextField), 'Read');
      await tester.pump();

      // Walk category → when → style → details (all valid by default).
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await grind();
      }

      // Last page: Save must pop the route with the created habit's id.
      await tester.tap(find.text('Save habit'));
      await grind();

      expect(popped, isA<String>(),
          reason: 'Save should pop the wizard with the new habit id');
      expect(find.text('Save habit'), findsNothing,
          reason: 'wizard route should be gone after Save');

      // And the habit really landed in the goal.
      final habits = await (db.select(db.habits)
            ..where((h) => h.goalId.equals('g1')))
          .get();
      expect(habits.map((h) => h.name), contains('Read'));

      // Tear the tree down inside the test and pump, so drift's
      // stream-close timer (scheduled on ProviderScope dispose) fires
      // before the framework's "no pending timers" invariant check.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
