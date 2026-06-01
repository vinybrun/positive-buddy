import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_db.dart';
import 'habit_repository.dart';

part 'backup_repository.g.dart';

/// One-stop JSON export/import of every user-owned table. Pre-launch
/// the schema is allowed to break, so we tag exports with the current
/// schemaVersion and refuse to import mismatched ones — a corrupt restore
/// is worse than a refused one.
@Riverpod(keepAlive: true)
BackupRepository backupRepository(Ref ref) =>
    BackupRepository(ref.watch(appDbProvider));

class BackupRepository {
  BackupRepository(this._db);
  final AppDb _db;

  static const String fileFormat = 'positive_buddy.backup.v1';

  Future<String> exportJson() async {
    final goals = await _db.select(_db.goals).get();
    final habits = await _db.select(_db.habits).get();
    final slots = await _db.select(_db.scheduleSlots).get();
    final logs = await _db.select(_db.notificationLog).get();
    final profile = await _db.select(_db.userProfileTable).get();
    final signals = await _db.select(_db.profileSignals).get();
    final adaptive = await _db.select(_db.adaptiveState).get();
    final categories = await _db.select(_db.userCategories).get();
    final buddyProg = await _db.select(_db.buddyProgress).get();
    final json = {
      'fileFormat': fileFormat,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'scheduleSlots': slots.map((s) => s.toJson()).toList(),
      'notificationLog': logs.map((l) => l.toJson()).toList(),
      'userProfile': profile.map((p) => p.toJson()).toList(),
      'profileSignals': signals.map((s) => s.toJson()).toList(),
      'adaptiveState': adaptive.map((a) => a.toJson()).toList(),
      'userCategories': categories.map((c) => c.toJson()).toList(),
      'buddyProgress': buddyProg.map((b) => b.toJson()).toList(),
    };
    return jsonEncode(json);
  }

  Future<BackupImportResult> importJson(String raw) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      throw const BackupFormatException(
          'Backup file is not valid JSON. Pick a Positive Buddy backup.');
    }
    final format = data['fileFormat'];
    if (format != fileFormat) {
      throw BackupFormatException(
          'Unrecognized backup format: ${format ?? '(none)'}.');
    }
    final v = data['schemaVersion'] as int? ?? -1;
    if (v != _db.schemaVersion) {
      throw BackupFormatException(
          'Backup was taken at schema v$v but the current app is at '
          'v${_db.schemaVersion}. The schema changed; restore aborted to '
          'avoid corrupting data.');
    }

    final goals = _listOfMaps(data['goals']);
    final habits = _listOfMaps(data['habits']);
    final slots = _listOfMaps(data['scheduleSlots']);
    final logs = _listOfMaps(data['notificationLog']);
    final profile = _listOfMaps(data['userProfile']);
    final signals = _listOfMaps(data['profileSignals']);
    final adaptive = _listOfMaps(data['adaptiveState']);
    final categories = _listOfMaps(data['userCategories']);
    final buddyProg = _listOfMaps(data['buddyProgress']);

    await _db.transaction(() async {
      // Delete in FK-respecting order: children before parents.
      // Habits reference Goals (FK on goal_id) so habits must die first.
      await _db.delete(_db.adaptiveState).go();
      await _db.delete(_db.profileSignals).go();
      await _db.delete(_db.notificationLog).go();
      await _db.delete(_db.scheduleSlots).go();
      await _db.delete(_db.habits).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.userCategories).go();
      await _db.delete(_db.buddyProgress).go();
      await _db.delete(_db.userProfileTable).go();

      // Insert parents before children.
      for (final m in goals) {
        await _db
            .into(_db.goals)
            .insert(Goal.fromJson(m), mode: InsertMode.insert);
      }
      for (final m in habits) {
        await _db
            .into(_db.habits)
            .insert(Habit.fromJson(m), mode: InsertMode.insert);
      }
      for (final m in slots) {
        await _db
            .into(_db.scheduleSlots)
            .insert(ScheduleSlot.fromJson(m), mode: InsertMode.insert);
      }
      for (final m in logs) {
        await _db.into(_db.notificationLog).insert(
            NotificationLogData.fromJson(m),
            mode: InsertMode.insert);
      }
      for (final m in profile) {
        await _db.into(_db.userProfileTable).insert(
            UserProfileTableData.fromJson(m),
            mode: InsertMode.insert);
      }
      for (final m in signals) {
        await _db.into(_db.profileSignals).insert(ProfileSignal.fromJson(m),
            mode: InsertMode.insert);
      }
      for (final m in adaptive) {
        await _db.into(_db.adaptiveState).insert(
            AdaptiveStateData.fromJson(m),
            mode: InsertMode.insert);
      }
      for (final m in categories) {
        await _db.into(_db.userCategories).insert(
            UserCategory.fromJson(m),
            mode: InsertMode.insert);
      }
      for (final m in buddyProg) {
        await _db.into(_db.buddyProgress).insert(
            BuddyProgressData.fromJson(m),
            mode: InsertMode.insert);
      }
    });

    return BackupImportResult(
      goals: goals.length,
      habits: habits.length,
      scheduleSlots: slots.length,
      notificationLog: logs.length,
      profileRows: profile.length,
      signals: signals.length,
      adaptiveRows: adaptive.length,
      categories: categories.length,
      buddyProgress: buddyProg.length,
    );
  }

  static List<Map<String, dynamic>> _listOfMaps(Object? v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
  }
}

class BackupImportResult {
  const BackupImportResult({
    required this.goals,
    required this.habits,
    required this.scheduleSlots,
    required this.notificationLog,
    required this.profileRows,
    required this.signals,
    required this.adaptiveRows,
    required this.categories,
    required this.buddyProgress,
  });
  final int goals;
  final int habits;
  final int scheduleSlots;
  final int notificationLog;
  final int profileRows;
  final int signals;
  final int adaptiveRows;
  final int categories;
  final int buddyProgress;

  @override
  String toString() =>
      'Imported $goals goals, $habits habits, $scheduleSlots slots, '
      '$notificationLog logs, $categories categories, $signals signals, '
      '$buddyProgress buddy progress rows.';
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}
