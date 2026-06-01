import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/features/widgets/home_widget_service.dart';

void main() {
  late AppDb db;

  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addHabit(String id, String name,
      {int? slotMinutes, DateTime? createdAt}) async {
    final now = createdAt ?? DateTime(2026, 1, 1);
    await db.into(db.habits).insert(HabitsCompanion.insert(
          id: id,
          name: name,
          category: 'water',
          kind: slotMinutes == null ? 'freq' : 'time',
          createdAt: now,
          updatedAt: now,
        ));
    if (slotMinutes != null) {
      await db.into(db.scheduleSlots).insert(ScheduleSlotsCompanion.insert(
            habitId: id,
            kind: 'time',
            timeOfDay: slotMinutes,
          ));
    }
  }

  Future<void> logYes(String habitId) async {
    final now = DateTime.now().toUtc();
    await db.into(db.notificationLog).insert(NotificationLogCompanion.insert(
          habitId: habitId,
          scheduledFor: now,
          response: 'yes',
          source: 'app',
          firedAt: Value(now),
          respondedAt: Value(now),
        ));
  }

  test('counts: total/done/pct and pending excludes done habits', () async {
    await addHabit('a', 'Morning walk', slotMinutes: 600);
    await addHabit('b', 'Drink water', slotMinutes: 480);
    await logYes('a');

    final snap = await HomeWidgetService.buildSnapshot(db);
    expect(snap.totalCount, 2);
    expect(snap.doneCount, 1);
    expect(snap.pct, 50);
    expect(snap.pendingHabits.map((h) => h.id), ['b']); // a is done
  });

  test('pending ordered by earliest time window, slotless last', () async {
    await addHabit('late', 'Late', slotMinutes: 1200); // 20:00
    await addHabit('early', 'Early', slotMinutes: 360); // 06:00
    await addHabit('none', 'Anytime'); // no slot → last
    await addHabit('mid', 'Mid', slotMinutes: 720); // 12:00

    final snap = await HomeWidgetService.buildSnapshot(db);
    expect(
      snap.pendingHabits.map((h) => h.id),
      ['early', 'mid', 'late', 'none'],
    );
    // Names, not ids, are what we ship to the widget.
    expect(snap.pendingHabits.first.name, 'Early');
  });

  test('defaults: primary color mode + showCount when no profile row',
      () async {
    await addHabit('a', 'A', slotMinutes: 480);
    final snap = await HomeWidgetService.buildSnapshot(db);
    expect(snap.showCount, isTrue);
    // primary mode → progress color equals the accent (opaque primary).
    expect(snap.progressColor, snap.accentColor);
  });

  test('progressive mode makes progress color differ from accent', () async {
    await db.into(db.userProfileTable).insert(UserProfileTableCompanion.insert(
          updatedAt: DateTime.now(),
          widgetColorMode: const Value('progressive'),
        ));
    await addHabit('a', 'A', slotMinutes: 480); // 0% done → red, not primary
    final snap = await HomeWidgetService.buildSnapshot(db);
    expect(snap.progressColor, isNot(snap.accentColor));
  });

  test('showCount=false is carried through', () async {
    await db.into(db.userProfileTable).insert(UserProfileTableCompanion.insert(
          updatedAt: DateTime.now(),
          widgetShowCount: const Value(false),
        ));
    await addHabit('a', 'A', slotMinutes: 480);
    final snap = await HomeWidgetService.buildSnapshot(db);
    expect(snap.showCount, isFalse);
  });
}
