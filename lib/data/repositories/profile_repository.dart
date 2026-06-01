import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../theme/buddy.dart';
import '../../theme/launcher_icon.dart';
import '../../theme/theme_palettes.dart';
import '../db/app_db.dart';
import 'habit_repository.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(appDbProvider));

/// Shared stream of the single user_profile row. Used by Settings and the
/// onboarding gate. Defined as a top-level provider (rather than via
/// `@riverpod` codegen) because riverpod_generator can't introspect the
/// drift-generated row type.
final userProfileProvider =
    StreamProvider<UserProfileTableData?>((ref) {
  return ref.watch(profileRepositoryProvider).watch();
});

/// Concrete settings struct surfaced to the UI. Mirrors the cell columns on
/// `user_profile` so the notification builder can pull a typed copy without
/// worrying about defaults or null fallbacks.
class UserSettings {
  const UserSettings({
    required this.followUpEnabled,
    required this.popupEnabled,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.customSoundsEnabled,
    required this.ttlMinutes,
    required this.selectedBuddy,
    required this.themeId,
    required this.customPrimaryColor,
    required this.customAccentColor,
    required this.customBackgroundColor,
    required this.bgBase,
    required this.bgTintColor,
    required this.bgTintStrength,
    required this.darkMode,
    required this.presenceMode,
    required this.widgetColorMode,
    required this.widgetShowCount,
    required this.buddyOrder,
  });

  final bool followUpEnabled;
  final bool popupEnabled;
  final bool vibrationEnabled;
  final bool soundEnabled;
  // v16: when true, reminders use the selected buddy's animal sound instead
  // of the system default. Only takes effect when [soundEnabled] is true.
  final bool customSoundsEnabled;
  final int ttlMinutes;
  // v4 visual personalization
  final BuddyId? selectedBuddy;
  // 'auto' means follow the buddy's default for the resolved brightness.
  final String themeId;
  final int? customPrimaryColor;
  final int? customAccentColor;
  // v8 legacy column — kept readable so old data isn't lost; the active
  // background path is the v9 triple below.
  final int? customBackgroundColor;
  // v9: background composition. Final scaffold = blend(base, tint, strength)
  // where base is 'light' (white) | 'dark' (black) | 'colorful' (no base —
  // tint alone). Brightness is inferred from the composed color.
  final BackgroundBase bgBase;
  final int bgTintColor;
  final int bgTintStrength; // 0..100
  final DarkModePref darkMode;
  // v4 presence (Android-only consumer)
  final String presenceMode;
  // v13 home-screen widget progress color: 'progressive' | 'primary'.
  final String widgetColorMode;
  // v14 whether widgets show the done/total count.
  final bool widgetShowCount;
  // v15 user-defined buddy order for the picker. Always a full permutation
  // of BuddyId.values — fromRow backfills any missing/unknown ids so the
  // list can be trusted as the complete roster.
  final List<BuddyId> buddyOrder;

  /// Built-in order: the evolving (staged) species first, then the rest —
  /// matches the picker's original featured/extras split so a fresh
  /// install looks unchanged.
  static List<BuddyId> get defaultBuddyOrder => [
        ...BuddyId.values.where((b) => b.hasStages),
        ...BuddyId.values.where((b) => !b.hasStages),
      ];

  /// Parse a stored JSON id-array into a sanitized full permutation:
  /// known ids in their stored order, then any buddies the stored list
  /// omitted (e.g. a species added in a later app version) appended in
  /// default order. Empty / malformed → [defaultBuddyOrder].
  static List<BuddyId> parseBuddyOrder(String? json) {
    if (json == null || json.isEmpty) return defaultBuddyOrder;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return defaultBuddyOrder;
      final seen = <BuddyId>[];
      for (final e in decoded) {
        final b = BuddyId.fromId(e is String ? e : null);
        if (b != null && !seen.contains(b)) seen.add(b);
      }
      for (final b in defaultBuddyOrder) {
        if (!seen.contains(b)) seen.add(b);
      }
      return seen;
    } catch (_) {
      return defaultBuddyOrder;
    }
  }

  static String encodeBuddyOrder(List<BuddyId> order) =>
      jsonEncode(order.map((b) => b.id).toList());

  /// Defaults used when no row exists yet. Kept in one place so the cold-start
  /// path and the migration default match.
  static const defaults = UserSettings(
    followUpEnabled: true,
    popupEnabled: true,
    vibrationEnabled: true,
    soundEnabled: false,
    customSoundsEnabled: true,
    ttlMinutes: 60,
    selectedBuddy: null,
    themeId: 'auto',
    customPrimaryColor: null,
    customAccentColor: null,
    customBackgroundColor: null,
    bgBase: BackgroundBase.auto,
    bgTintColor: 0xFFCC6B49, // sunrise orange — matches shipped look
    bgTintStrength: 15,
    darkMode: DarkModePref.system,
    presenceMode: 'both',
    widgetColorMode: 'primary',
    widgetShowCount: true,
    buddyOrder: [],
  );

  factory UserSettings.fromRow(UserProfileTableData? row) {
    if (row == null) return defaults;
    return UserSettings(
      followUpEnabled: row.followUpEnabled,
      popupEnabled: row.popupEnabled,
      vibrationEnabled: row.vibrationEnabled,
      soundEnabled: row.soundEnabled,
      customSoundsEnabled: row.customSoundsEnabled,
      ttlMinutes: row.ttlMinutes,
      selectedBuddy: BuddyId.fromId(row.selectedBuddy),
      themeId: row.themeId,
      customPrimaryColor: row.customPrimaryColor,
      customAccentColor: row.customAccentColor,
      customBackgroundColor: row.customBackgroundColor,
      bgBase: BackgroundBase.fromId(row.bgBase),
      bgTintColor: row.bgTintColor,
      bgTintStrength: row.bgTintStrength,
      darkMode: DarkModePref.fromId(row.darkMode),
      presenceMode: row.presenceMode,
      widgetColorMode: row.widgetColorMode,
      widgetShowCount: row.widgetShowCount,
      buddyOrder: parseBuddyOrder(row.buddyOrderJson),
    );
  }

  /// Buddy order guaranteed non-empty — falls back to the built-in order
  /// for the no-row default case (where [buddyOrder] is left empty because
  /// the const default can't build the list).
  List<BuddyId> get effectiveBuddyOrder =>
      buddyOrder.isEmpty ? defaultBuddyOrder : buddyOrder;
}

/// Picker-side composition base for the page background. Combined with
/// a tint color + strength to produce the actual scaffold color.
///
/// `auto` follows the system: light = white base, dark = black base. The
/// theme provider expands this into two ThemeData (light + dark) and
/// pins `ThemeMode.system` so the OS picks at runtime.
enum BackgroundBase {
  auto('auto'),
  light('light'),
  dark('dark'),
  // No solid base — the tint color shows as-is regardless of strength.
  colorful('colorful');

  const BackgroundBase(this.id);
  final String id;

  static BackgroundBase fromId(String? id) {
    for (final b in BackgroundBase.values) {
      if (b.id == id) return b;
    }
    return BackgroundBase.auto;
  }
}

class ProfileRepository {
  ProfileRepository(this._db);
  final AppDb _db;

  Stream<UserProfileTableData?> watch() =>
      (_db.select(_db.userProfileTable)..limit(1))
          .watchSingleOrNull();

  Future<UserProfileTableData?> read() =>
      (_db.select(_db.userProfileTable)..limit(1)).getSingleOrNull();

  /// Fast path for the notification builder: returns settings without
  /// streaming, with defaults if no row exists.
  Future<UserSettings> readSettings() async {
    final row = await read();
    return UserSettings.fromRow(row);
  }

  Future<void> ensureExists() async {
    final existing = await read();
    if (existing == null) {
      await _db.into(_db.userProfileTable).insert(
            UserProfileTableCompanion.insert(updatedAt: DateTime.now()),
          );
    }
  }

  Future<void> updateSettings({
    bool? followUpEnabled,
    bool? popupEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? customSoundsEnabled,
    int? ttlMinutes,
    // v4 visual personalization. Pass `clearBuddy: true` to set buddy back
    // to null; for the colors, pass `clearCustomPrimary` / `clearCustomAccent`.
    BuddyId? selectedBuddy,
    bool clearBuddy = false,
    String? themeId,
    int? customPrimaryColor,
    bool clearCustomPrimary = false,
    int? customAccentColor,
    bool clearCustomAccent = false,
    int? customBackgroundColor,
    bool clearCustomBackground = false,
    BackgroundBase? bgBase,
    int? bgTintColor,
    int? bgTintStrength,
    DarkModePref? darkMode,
    String? presenceMode,
    String? widgetColorMode,
    bool? widgetShowCount,
    String? buddyOrderJson,
    // Phase 0 auto-save: profile form fields that previously lived behind a
    // Save button now write immediately too.
    String? tonePreference,
    int? dailyNotifBudget,
    String? wakingWindowJson,
    String? goalsJson,
  }) async {
    await ensureExists();
    await _db.update(_db.userProfileTable).write(UserProfileTableCompanion(
          followUpEnabled: followUpEnabled == null
              ? const Value.absent()
              : Value(followUpEnabled),
          popupEnabled: popupEnabled == null
              ? const Value.absent()
              : Value(popupEnabled),
          vibrationEnabled: vibrationEnabled == null
              ? const Value.absent()
              : Value(vibrationEnabled),
          soundEnabled: soundEnabled == null
              ? const Value.absent()
              : Value(soundEnabled),
          customSoundsEnabled: customSoundsEnabled == null
              ? const Value.absent()
              : Value(customSoundsEnabled),
          ttlMinutes:
              ttlMinutes == null ? const Value.absent() : Value(ttlMinutes),
          selectedBuddy: clearBuddy
              ? const Value(null)
              : (selectedBuddy == null
                  ? const Value.absent()
                  : Value(selectedBuddy.id)),
          themeId: themeId == null ? const Value.absent() : Value(themeId),
          customPrimaryColor: clearCustomPrimary
              ? const Value(null)
              : (customPrimaryColor == null
                  ? const Value.absent()
                  : Value(customPrimaryColor)),
          customAccentColor: clearCustomAccent
              ? const Value(null)
              : (customAccentColor == null
                  ? const Value.absent()
                  : Value(customAccentColor)),
          customBackgroundColor: clearCustomBackground
              ? const Value(null)
              : (customBackgroundColor == null
                  ? const Value.absent()
                  : Value(customBackgroundColor)),
          bgBase:
              bgBase == null ? const Value.absent() : Value(bgBase.id),
          bgTintColor: bgTintColor == null
              ? const Value.absent()
              : Value(bgTintColor),
          bgTintStrength: bgTintStrength == null
              ? const Value.absent()
              : Value(bgTintStrength),
          darkMode:
              darkMode == null ? const Value.absent() : Value(darkMode.id),
          presenceMode: presenceMode == null
              ? const Value.absent()
              : Value(presenceMode),
          widgetColorMode: widgetColorMode == null
              ? const Value.absent()
              : Value(widgetColorMode),
          widgetShowCount: widgetShowCount == null
              ? const Value.absent()
              : Value(widgetShowCount),
          buddyOrderJson: buddyOrderJson == null
              ? const Value.absent()
              : Value(buddyOrderJson),
          tonePreference: tonePreference == null
              ? const Value.absent()
              : Value(tonePreference),
          dailyNotifBudget: dailyNotifBudget == null
              ? const Value.absent()
              : Value(dailyNotifBudget),
          wakingWindowJson: wakingWindowJson == null
              ? const Value.absent()
              : Value(wakingWindowJson),
          goalsJson:
              goalsJson == null ? const Value.absent() : Value(goalsJson),
          updatedAt: Value(DateTime.now()),
        ));
    // v4/v15: queue the Android launcher icon to swap when the app
    // backgrounds. We do NOT fire immediately — that would terminate the
    // running task mid-tap. See LauncherIconBridge for the why. The icon
    // reflects the buddy's *evolved* form, so we read its max stage.
    if (clearBuddy) {
      LauncherIconBridge.queueForBuddy(null);
    } else if (selectedBuddy != null) {
      LauncherIconBridge.queueForBuddy(
        selectedBuddy,
        stage: await _maxStageFor(selectedBuddy),
      );
    }
  }

  /// Max evolution stage reached for [buddy], read straight from the
  /// progress row. 0 when the buddy has never been scored.
  Future<int> _maxStageFor(BuddyId buddy) async {
    final row = await (_db.select(_db.buddyProgress)
          ..where((p) => p.buddyId.equals(buddy.id))
          ..limit(1))
        .getSingleOrNull();
    return row?.maxStageReached ?? 0;
  }

  /// Phase 3 — onboarding writes the captured profile into the single row.
  /// [selectedBuddyId] is the v4 buddy choice; pass null only if onboarding
  /// is somehow finishing without one picked (defensive — the UI requires it).
  ///
  /// v11: `markOnboarded` defaults to true (back-compat) but the wizard
  /// passes false so it can keep the OnboardingPage mounted while pushing
  /// the goal wizard. The user_profile stream flips the home tree the
  /// instant `onboarded=true`, which would unmount the pushed wizard.
  Future<void> writeOnboarding({
    required String tonePreference,
    required int dailyNotifBudget,
    required String wakingWindowJson,
    required String goalsJson,
    String? selectedBuddyId,
    bool markOnboarded = true,
  }) async {
    await ensureExists();
    await _db.update(_db.userProfileTable).write(UserProfileTableCompanion(
          tonePreference: Value(tonePreference),
          dailyNotifBudget: Value(dailyNotifBudget),
          wakingWindowJson: Value(wakingWindowJson),
          goalsJson: Value(goalsJson),
          selectedBuddy: selectedBuddyId == null
              ? const Value.absent()
              : Value(selectedBuddyId),
          onboarded:
              markOnboarded ? const Value(true) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ));
    // Queue the launcher icon swap for when the user backgrounds the app
    // — applying mid-onboarding would kill the running task. A freshly
    // picked buddy is always at stage 0.
    final picked = BuddyId.fromId(selectedBuddyId);
    if (picked != null) {
      LauncherIconBridge.queueForBuddy(picked, stage: 0);
    }
  }

  Future<void> setOnboarded(bool value) async {
    await ensureExists();
    await _db.update(_db.userProfileTable).write(UserProfileTableCompanion(
          onboarded: Value(value),
          updatedAt: Value(DateTime.now()),
        ));
  }
}
