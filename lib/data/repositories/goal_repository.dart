import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../db/app_db.dart';
import 'habit_repository.dart';

part 'goal_repository.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) =>
    GoalRepository(ref.watch(appDbProvider));

/// Phase 2 — goals are now the anchor; habits live underneath them.
///
/// Capped at [activeGoalCap] active goals at a time. The cap exists
/// because the spec is clear: nobody can meaningfully maintain more
/// than three concurrent goals. The repo enforces it; the UI hides
/// the "+" button.
class GoalRepository {
  GoalRepository(this._db);
  final AppDb _db;
  static const _uuid = Uuid();

  /// Max number of goals the user can have in flight at once.
  static const int activeGoalCap = 3;

  Stream<List<Goal>> watchActive() {
    return (_db.select(_db.goals)
          ..where((g) => g.completedAt.isNull() & g.archivedAt.isNull())
          ..orderBy([(g) => OrderingTerm.asc(g.displayOrder)]))
        .watch();
  }

  Stream<List<Goal>> watchCompleted() {
    return (_db.select(_db.goals)
          ..where((g) => g.completedAt.isNotNull() & g.archivedAt.isNull())
          ..orderBy([(g) => OrderingTerm.desc(g.completedAt)]))
        .watch();
  }

  /// v11: goals the user gave up on / removed mid-flight. Distinct from
  /// completed (graduated) — see [archive] vs [complete].
  Stream<List<Goal>> watchArchived() {
    return (_db.select(_db.goals)
          ..where((g) => g.archivedAt.isNotNull())
          ..orderBy([(g) => OrderingTerm.desc(g.archivedAt)]))
        .watch();
  }

  Future<List<Goal>> readActive() => (_db.select(_db.goals)
        ..where((g) => g.completedAt.isNull() & g.archivedAt.isNull()))
      .get();

  Future<int> activeCount() async {
    final all = await readActive();
    return all.length;
  }

  Future<Goal?> getById(String id) =>
      (_db.select(_db.goals)..where((g) => g.id.equals(id)))
          .getSingleOrNull();

  /// Add a goal. Throws [GoalCapException] if the cap is already hit.
  Future<String> create({
    required String title,
    String? description,
  }) async {
    final count = await activeCount();
    if (count >= activeGoalCap) {
      throw const GoalCapException();
    }
    final id = _uuid.v4();
    await _db.into(_db.goals).insert(GoalsCompanion.insert(
          id: id,
          title: title.trim(),
          description: description == null
              ? const Value.absent()
              : Value(description.trim()),
          createdAt: DateTime.now(),
          displayOrder: Value(count),
        ));
    return id;
  }

  Future<void> rename(String id, String newTitle) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(id)))
        .write(GoalsCompanion(title: Value(newTitle.trim())));
  }

  /// Phase 5: graduate a goal — typically fired when all the goal's
  /// habits are themselves completed and the user confirms.
  Future<void> complete(String id) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(completedAt: Value(DateTime.now())),
    );
  }

  /// Remove a goal mid-flight. Sets `archivedAt` (NOT `completedAt` — that
  /// would pollute the Graduated section in Wins) and soft-deletes the
  /// goal's habits. Reversible via [restore].
  Future<void> archive(String goalId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.goals)..where((g) => g.id.equals(goalId)))
          .write(GoalsCompanion(archivedAt: Value(now)));
      await (_db.update(_db.habits)..where((h) => h.goalId.equals(goalId)))
          .write(HabitsCompanion(
        active: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
    });
  }

  /// Bring an archived goal back. Clears `archivedAt` on the goal and
  /// `deletedAt` on its habits. Refuses if it would push the active goal
  /// count past the cap.
  Future<void> restore(String goalId) async {
    final activeNow = await activeCount();
    if (activeNow >= activeGoalCap) {
      throw const GoalCapException();
    }
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.goals)..where((g) => g.id.equals(goalId)))
          .write(const GoalsCompanion(archivedAt: Value(null)));
      await (_db.update(_db.habits)..where((h) => h.goalId.equals(goalId)))
          .write(HabitsCompanion(
        active: const Value(true),
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ));
    });
  }
}

class GoalCapException implements Exception {
  const GoalCapException();
  @override
  String toString() =>
      'You already have ${GoalRepository.activeGoalCap} active goals — '
      'finish or remove one before adding another.';
}
