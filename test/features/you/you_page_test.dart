import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/features/onboarding/onboarding_model.dart';
import 'package:habit_buddy/features/you/you_page.dart';

/// Phase 4 — YouPage replaces the old ProfilePage + SettingsPage split.
/// Source-level + repo-level guards; we do NOT pump the widget tree
/// (it's a StreamProvider on real drift, debounce timers, etc.).
void main() {
  test('YouPage source has three sections + no Save button', () {
    final src = File('lib/features/you/you_page.dart').readAsStringSync();
    expect(src.contains("title: 'Buddy & look'"), isTrue);
    expect(src.contains("title: 'Reminders'"), isTrue);
    expect(src.contains("title: 'Data'"), isTrue);
    expect(src.contains("child: const Text('Save')"), isFalse);
    expect(src.contains('Future<void> _save()'), isFalse);
    // Carries the link back into Plan so users who land on You looking
    // for goals are redirected, not stranded.
    expect(src.contains('PlanPage()'), isTrue);
    expect(YouPage, isNotNull);
  });

  test('No goals editor on YouPage — that lives on PlanPage now', () {
    final src = File('lib/features/you/you_page.dart').readAsStringSync();
    expect(src.contains('_GoalsEditor'), isFalse);
    // The plan-your-goals link is a navigation row, not an inline editor.
    expect(src.contains('goalRepositoryProvider'), isFalse);
  });

  test('Old Profile + Settings pages are gone', () {
    expect(
        File('lib/features/profile/profile_page.dart').existsSync(), isFalse);
    expect(File('lib/features/settings/settings_page.dart').existsSync(),
        isFalse);
  });

  group('ProfileRepository.updateSettings — auto-save fields', () {
    late AppDb db;
    late ProfileRepository repo;

    setUp(() async {
      db = AppDb.forTesting(NativeDatabase.memory());
      repo = ProfileRepository(db);
      await repo.ensureExists();
    });

    tearDown(() async {
      await db.close();
    });

    test('tone preference persists', () async {
      await repo.updateSettings(tonePreference: 'celebratory');
      final row = await repo.read();
      expect(row!.tonePreference, 'celebratory');
    });

    test('daily reminder cap persists', () async {
      await repo.updateSettings(dailyNotifBudget: 9);
      final row = await repo.read();
      expect(row!.dailyNotifBudget, 9);
    });

    test('waking window persists as serialized JSON', () async {
      final data = OnboardingData(
        wakeStart: const TimeOfDay(hour: 6, minute: 30),
        wakeEnd: const TimeOfDay(hour: 23, minute: 15),
      );
      await repo.updateSettings(wakingWindowJson: data.wakingWindowJson());
      final row = await repo.read();
      final parsed =
          OnboardingData.parseWakingWindow(row!.wakingWindowJson)!;
      expect(parsed.start, const TimeOfDay(hour: 6, minute: 30));
      expect(parsed.end, const TimeOfDay(hour: 23, minute: 15));
    });

    test('behavior toggles persist', () async {
      await repo.updateSettings(
        popupEnabled: false,
        vibrationEnabled: false,
        soundEnabled: true,
        customSoundsEnabled: false,
        followUpEnabled: false,
        ttlMinutes: 240,
      );
      final row = await repo.read();
      expect(row!.popupEnabled, false);
      expect(row.vibrationEnabled, false);
      expect(row.soundEnabled, true);
      expect(row.customSoundsEnabled, false);
      expect(row.followUpEnabled, false);
      expect(row.ttlMinutes, 240);
    });

    test('customSoundsEnabled defaults to true (v16)', () async {
      await repo.ensureExists();
      final row = await repo.read();
      expect(row!.customSoundsEnabled, true);
    });
  });
}
