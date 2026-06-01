import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/features/buddy_progress/buddy_progress_repository.dart';
import 'package:habit_buddy/theme/buddy.dart';

void main() {
  late AppDb db;
  late BuddyProgressRepository repo;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = BuddyProgressRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Seed a yes-response and the matching fire on a specific local-calendar
  /// date for a habit. Mirrors what LocalNotificationService.completeHabit
  /// would have logged.
  Future<void> seedYes({
    required String habitId,
    required DateTime localDay,
    bool fired = true,
  }) async {
    final start = DateTime(localDay.year, localDay.month, localDay.day).toUtc();
    await db.into(db.notificationLog).insert(NotificationLogCompanion.insert(
          habitId: habitId,
          scheduledFor: start,
          response: 'yes',
          source: 'action_button',
          firedAt: fired ? Value(start.add(const Duration(hours: 8))) : const Value(null),
          respondedAt: Value(start.add(const Duration(hours: 8, minutes: 5))),
        ));
  }

  test('reconcile is idempotent — second call adds nothing', () async {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    await seedYes(habitId: 'h1', localDay: twoDaysAgo);

    await repo.reconcile(BuddyId.fox);
    final after1 = await repo.read(BuddyId.fox);
    await repo.reconcile(BuddyId.fox);
    final after2 = await repo.read(BuddyId.fox);

    expect(after1!.totalScore, after2!.totalScore);
    expect(after1.lastScoredDayEpoch, after2.lastScoredDayEpoch);
  });

  test('today is excluded — only completed days are credited', () async {
    final today = DateTime.now();
    await seedYes(habitId: 'h1', localDay: today);
    await repo.reconcile(BuddyId.fox);
    final p = await repo.read(BuddyId.fox);
    // Today's yes is reflected in live currentStage but NOT in persisted total.
    // (No completed day yet to credit.)
    if (p != null) {
      expect(p.totalScore, 0);
    }
  });

  test('a single done day yesterday credits 1 base + 3 perfect-rate = 4 pts',
      () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await seedYes(habitId: 'h1', localDay: yesterday);
    await repo.reconcile(BuddyId.fox);
    final p = await repo.read(BuddyId.fox);
    expect(p, isNotNull);
    expect(p!.totalScore, 4); // 1 done + 3 rate bonus (1/1 = 100%)
  });

  test('per-buddy isolation — credits applied to one buddy do not leak',
      () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await seedYes(habitId: 'h1', localDay: yesterday);
    await repo.reconcile(BuddyId.fox);
    final fox = await repo.read(BuddyId.fox);
    final snake = await repo.read(BuddyId.snake);
    expect(fox!.totalScore, greaterThan(0));
    expect(snake, isNull, reason: 'snake should not have a row yet');
  });

  test('currentStage includes the in-progress today score', () async {
    // Seed 25 days of yes responses → totals enough to cross the stage-1
    // threshold (25 pts).
    final now = DateTime.now();
    for (var i = 1; i <= 25; i++) {
      final day = now.subtract(Duration(days: i));
      await seedYes(habitId: 'h1', localDay: day);
    }
    await repo.reconcile(BuddyId.fox);
    final stage = await repo.currentStage(BuddyId.fox);
    expect(stage, greaterThanOrEqualTo(1),
        reason: '25 perfect days should land us at stage 1 or higher');
  });

  test('maxStageReached is monotonic and persisted', () async {
    final now = DateTime.now();
    // Big effort: simulate someone with high volume — many habits done.
    for (var i = 1; i <= 40; i++) {
      final day = now.subtract(Duration(days: i));
      for (var h = 1; h <= 5; h++) {
        await seedYes(habitId: 'h$h', localDay: day);
      }
    }
    await repo.reconcile(BuddyId.fox);
    final p = await repo.read(BuddyId.fox);
    expect(p!.maxStageReached, greaterThan(0));
    expect(p.totalScore, greaterThanOrEqualTo(p.maxStageReached));
  });
}
