import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/backup_repository.dart';

void main() {
  late AppDb db;
  late BackupRepository repo;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = BackupRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed() async {
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            id: 'h-water',
            name: 'Drink water',
            category: 'water',
            kind: 'time',
            createdAt: DateTime.utc(2026, 5, 1, 8),
            updatedAt: DateTime.utc(2026, 5, 1, 8),
          ),
        );
    await db.into(db.scheduleSlots).insert(
          ScheduleSlotsCompanion.insert(
            habitId: 'h-water',
            kind: 'time',
            timeOfDay: 8 * 60,
          ),
        );
    await db.into(db.notificationLog).insert(
          NotificationLogCompanion.insert(
            habitId: 'h-water',
            scheduledFor: DateTime.utc(2026, 5, 1, 8),
            response: 'yes',
            source: 'action_button',
            firedAt: Value(DateTime.utc(2026, 5, 1, 8, 1)),
            respondedAt: Value(DateTime.utc(2026, 5, 1, 8, 2)),
          ),
        );
    await db.into(db.userProfileTable).insert(
          UserProfileTableCompanion.insert(
            tonePreference: const Value('empathetic'),
            dailyNotifBudget: const Value(7),
            updatedAt: DateTime.utc(2026, 5, 1, 8),
          ),
        );
    await db.into(db.profileSignals).insert(
          ProfileSignalsCompanion.insert(
            ts: DateTime.utc(2026, 5, 1, 9),
            kind: 'app_open',
            payloadJson: '{}',
          ),
        );
  }

  test('export -> wipe -> import restores the same rows', () async {
    await seed();
    final json = await repo.exportJson();
    expect(json, contains('"h-water"'));

    // Wipe everything (sim a fresh install).
    await db.transaction(() async {
      await db.delete(db.adaptiveState).go();
      await db.delete(db.profileSignals).go();
      await db.delete(db.notificationLog).go();
      await db.delete(db.scheduleSlots).go();
      await db.delete(db.habits).go();
      await db.delete(db.userProfileTable).go();
    });
    expect((await db.select(db.habits).get()).length, 0);

    final result = await repo.importJson(json);
    expect(result.habits, 1);
    expect(result.scheduleSlots, 1);
    expect(result.notificationLog, 1);
    expect(result.profileRows, 1);
    expect(result.signals, 1);

    final habit = (await db.select(db.habits).get()).single;
    expect(habit.id, 'h-water');
    expect(habit.name, 'Drink water');
    expect(habit.category, 'water');

    final slot = (await db.select(db.scheduleSlots).get()).single;
    expect(slot.habitId, 'h-water');
    expect(slot.timeOfDay, 8 * 60);

    final profile = (await db.select(db.userProfileTable).get()).single;
    expect(profile.tonePreference, 'empathetic');
    expect(profile.dailyNotifBudget, 7);
  });

  test('importJson refuses a non-Positive Buddy file', () async {
    expect(
      () => repo.importJson('{"some": "other"}'),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('importJson refuses a mismatched schema version', () async {
    final mismatched =
        '{"fileFormat": "${BackupRepository.fileFormat}", "schemaVersion": 99}';
    expect(
      () => repo.importJson(mismatched),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('importJson refuses garbage input', () async {
    expect(
      () => repo.importJson('not json at all'),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('export+import round-trips goals and user categories (v11)',
      () async {
    // Seed a goal, a habit hanging off it, and a custom category.
    await db.into(db.goals).insert(GoalsCompanion.insert(
          id: 'g-sleep',
          title: 'Sleep before midnight',
          createdAt: DateTime.utc(2026, 5, 1, 8),
        ));
    await db.into(db.habits).insert(HabitsCompanion.insert(
          id: 'h-noPhone',
          name: 'No phone after 11pm',
          category: 'custom-evening',
          kind: 'time',
          goalId: const Value('g-sleep'),
          createdAt: DateTime.utc(2026, 5, 1, 8),
          updatedAt: DateTime.utc(2026, 5, 1, 8),
        ));
    await db.into(db.userCategories).insert(UserCategoriesCompanion.insert(
          id: 'custom-evening',
          label: 'Evening wind-down',
          createdAt: DateTime.utc(2026, 5, 1, 8),
        ));

    final json = await repo.exportJson();
    expect(json, contains('"g-sleep"'));
    expect(json, contains('"custom-evening"'));

    // Wipe everything (FK order: children before parents).
    await db.transaction(() async {
      await db.delete(db.adaptiveState).go();
      await db.delete(db.profileSignals).go();
      await db.delete(db.notificationLog).go();
      await db.delete(db.scheduleSlots).go();
      await db.delete(db.habits).go();
      await db.delete(db.goals).go();
      await db.delete(db.userCategories).go();
      await db.delete(db.userProfileTable).go();
    });

    final result = await repo.importJson(json);
    expect(result.goals, 1);
    expect(result.habits, 1);
    expect(result.categories, 1);

    final goal = (await db.select(db.goals).get()).single;
    expect(goal.id, 'g-sleep');
    expect(goal.title, 'Sleep before midnight');
    final habit = (await db.select(db.habits).get()).single;
    expect(habit.goalId, 'g-sleep');
    final cat = (await db.select(db.userCategories).get()).single;
    expect(cat.label, 'Evening wind-down');
  });

  test('archived goals survive export+import (archivedAt preserved)',
      () async {
    await db.into(db.goals).insert(GoalsCompanion.insert(
          id: 'g-old',
          title: 'Defunct',
          createdAt: DateTime.utc(2026, 5, 1, 8),
          archivedAt: Value(DateTime.utc(2026, 5, 15, 12)),
        ));

    final json = await repo.exportJson();
    await db.delete(db.goals).go();
    await repo.importJson(json);
    final restored = (await db.select(db.goals).get()).single;
    expect(restored.archivedAt?.toUtc(), DateTime.utc(2026, 5, 15, 12));
  });
}
