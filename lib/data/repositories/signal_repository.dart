import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_db.dart';
import 'habit_repository.dart';

part 'signal_repository.g.dart';

/// Phase 3 — the only writer to the `profile_signals` table. The engine
/// reads from it during reconcile to figure out when the user is most
/// active; that drives smart scheduling and (Phase 4) tone choice.
@Riverpod(keepAlive: true)
SignalRepository signalRepository(Ref ref) =>
    SignalRepository(ref.watch(appDbProvider));

class SignalRepository {
  SignalRepository(this._db);
  final AppDb _db;

  /// 'response' = user tapped Yes / Not yet on a notification.
  /// 'dismissal' = user swiped a notification away without responding.
  /// 'manual_edit' = user changed a habit or schedule by hand.
  /// 'app_open' = the app moved to the foreground.
  static const String kindResponse = 'response';
  static const String kindDismissal = 'dismissal';
  static const String kindManualEdit = 'manual_edit';
  static const String kindAppOpen = 'app_open';

  Future<void> record({
    required String kind,
    Map<String, dynamic> payload = const {},
    DateTime? ts,
  }) async {
    await _db.into(_db.profileSignals).insert(
          ProfileSignalsCompanion.insert(
            ts: ts ?? DateTime.now(),
            kind: kind,
            payloadJson: jsonEncode(payload),
          ),
        );
  }

  /// Read signals newer than [since]. Used by the engine to decide where
  /// the user's productive hours actually are.
  Future<List<ProfileSignal>> readSince(DateTime since) {
    return (_db.select(_db.profileSignals)
          ..where((s) => s.ts.isBiggerOrEqualValue(since))
          ..orderBy([(s) => OrderingTerm.asc(s.ts)]))
        .get();
  }

  /// Convenience for tests + the engine: yes-response signals only.
  Future<List<ProfileSignal>> readYesResponsesSince(DateTime since) {
    return (_db.select(_db.profileSignals)
          ..where((s) =>
              s.ts.isBiggerOrEqualValue(since) & s.kind.equals(kindResponse))
          ..orderBy([(s) => OrderingTerm.asc(s.ts)]))
        .get();
  }
}
