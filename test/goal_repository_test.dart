import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/goal_repository.dart';

void main() {
  late AppDb db;
  late GoalRepository repo;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = GoalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create + readActive round-trip', () async {
    await repo.create(title: 'Read more');
    await repo.create(title: 'Sleep before midnight');
    final active = await repo.readActive();
    expect(active.length, 2);
    expect(active.map((g) => g.title),
        containsAll(['Read more', 'Sleep before midnight']));
  });

  test('3-goal cap enforced', () async {
    await repo.create(title: 'A');
    await repo.create(title: 'B');
    await repo.create(title: 'C');
    expect(
      () => repo.create(title: 'D'),
      throwsA(isA<GoalCapException>()),
    );
  });

  test('completing a goal frees the cap', () async {
    final aId = await repo.create(title: 'A');
    await repo.create(title: 'B');
    await repo.create(title: 'C');
    await repo.complete(aId);
    // A is no longer active → cap has room.
    await repo.create(title: 'D');
    final active = await repo.readActive();
    expect(active.map((g) => g.title), containsAll(['B', 'C', 'D']));
  });

  test('archive cascades: soft-deletes child habits', () async {
    final gId = await repo.create(title: 'Get fit');
    // Insert a habit pointing at the goal so we can verify the cascade.
    await db.into(db.habits).insert(HabitsCompanion.insert(
          id: 'h1',
          name: 'Walk',
          category: 'exercise',
          kind: 'time',
          goalId: const Value('placeholder'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    await (db.update(db.habits)..where((h) => h.id.equals('h1'))).write(
      HabitsCompanion(goalId: Value(gId)),
    );
    await repo.archive(gId);
    final habit = await (db.select(db.habits)
          ..where((h) => h.id.equals('h1')))
        .getSingle();
    expect(habit.active, isFalse);
    expect(habit.deletedAt, isNotNull);
  });

  test('archive sets archivedAt (NOT completedAt) — keeps Wins clean',
      () async {
    final gId = await repo.create(title: 'Get fit');
    await repo.archive(gId);
    final g = await repo.getById(gId);
    expect(g, isNotNull);
    expect(g!.archivedAt, isNotNull,
        reason: 'archive() must populate archivedAt');
    expect(g.completedAt, isNull,
        reason: 'archive() must NOT populate completedAt — '
            'that is the Graduated section');
  });

  test('archived goal does not appear in active or completed lists',
      () async {
    final gId = await repo.create(title: 'Try it');
    await repo.archive(gId);
    final active = await repo.readActive();
    expect(active.map((g) => g.id), isNot(contains(gId)));
    final completed = await repo.watchCompleted().first;
    expect(completed.map((g) => g.id), isNot(contains(gId)));
    final archived = await repo.watchArchived().first;
    expect(archived.map((g) => g.id), contains(gId));
  });

  test('restore brings an archived goal back and unblocks its habits',
      () async {
    final gId = await repo.create(title: 'Stretch');
    await db.into(db.habits).insert(HabitsCompanion.insert(
          id: 'h2',
          name: 'Hamstrings',
          category: 'exercise',
          kind: 'time',
          goalId: Value(gId),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    await repo.archive(gId);
    await repo.restore(gId);
    final g = await repo.getById(gId);
    expect(g!.archivedAt, isNull);
    final h = await (db.select(db.habits)
          ..where((h) => h.id.equals('h2')))
        .getSingle();
    expect(h.active, isTrue);
    expect(h.deletedAt, isNull);
  });

  test('restore refuses when active cap is already at three', () async {
    final gId = await repo.create(title: 'Old goal');
    await repo.archive(gId);
    await repo.create(title: 'A');
    await repo.create(title: 'B');
    await repo.create(title: 'C');
    expect(() => repo.restore(gId), throwsA(isA<GoalCapException>()));
  });
}
