import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_db.dart';
import 'habit_repository.dart';
import 'signal_repository.dart';

part 'log_repository.g.dart';

@Riverpod(keepAlive: true)
LogRepository logRepository(Ref ref) =>
    LogRepository(ref.watch(appDbProvider));

class LogRepository {
  LogRepository(this._db);
  final AppDb _db;

  Stream<int> watchCount() =>
      _db.notificationLog.count().map((rows) => rows).watchSingle();

  /// Latest log row per habit for today (local time). Used by the Today page
  /// to show "done"/"not yet"/"missed" status next to each habit.
  Stream<Map<String, NotificationLogData>> watchTodayLogsByHabit() {
    final now = DateTime.now();
    final startOfDayLocal = DateTime(now.year, now.month, now.day).toUtc();
    return (_db.select(_db.notificationLog)
          ..where((l) => l.respondedAt.isBiggerOrEqualValue(startOfDayLocal))
          ..orderBy([(l) => OrderingTerm.desc(l.respondedAt)]))
        .watch()
        .map((rows) {
      final map = <String, NotificationLogData>{};
      for (final r in rows) {
        // First occurrence (most recent due to desc order) wins per habit.
        map.putIfAbsent(r.habitId, () => r);
      }
      return map;
    });
  }

  Future<void> logResponse({
    required String habitId,
    required String response,
    String source = 'app',
  }) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.notificationLog).insert(
          NotificationLogCompanion.insert(
            habitId: habitId,
            scheduledFor: now,
            response: response,
            source: source,
            firedAt: Value(now),
            respondedAt: Value(now),
          ),
        );
    // Phase 3: mirror the response into profile_signals so the engine
    // can fold it into the active-hour histogram and the engagement
    // classifier. Done inline so the BG isolate path picks it up too —
    // it always hits this repo when the user taps an action button.
    await SignalRepository(_db).record(
      kind: SignalRepository.kindResponse,
      payload: {'habitId': habitId, 'response': response, 'source': source},
    );
  }

  /// Legacy debug helper kept for the debug page.
  Future<void> insertFake({
    required String habitId,
    required String response,
    String source = 'app',
  }) =>
      logResponse(habitId: habitId, response: response, source: source);
}
