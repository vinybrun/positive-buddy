import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/theme/buddy.dart';
import 'package:habit_buddy/theme/theme_palettes.dart';

void main() {
  late AppDb db;
  late ProfileRepository repo;

  setUp(() {
    db = AppDb.forTesting(NativeDatabase.memory());
    repo = ProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('cold-start defaults match UserSettings.defaults', () async {
    final settings = await repo.readSettings();
    expect(settings.selectedBuddy, isNull);
    expect(settings.themeId, 'auto');
    expect(settings.customPrimaryColor, isNull);
    expect(settings.customAccentColor, isNull);
    expect(settings.darkMode, DarkModePref.system);
    expect(settings.presenceMode, 'both');
  });

  test('updateSettings persists v4 visual columns round-trip', () async {
    await repo.updateSettings(
      selectedBuddy: BuddyId.butterfly,
      themeId: ThemePaletteId.sky.id,
      customPrimaryColor: 0xFF112233,
      customAccentColor: 0xFFAABBCC,
      darkMode: DarkModePref.dark,
      presenceMode: 'active',
    );
    final s = await repo.readSettings();
    expect(s.selectedBuddy, BuddyId.butterfly);
    expect(s.themeId, ThemePaletteId.sky.id);
    expect(s.customPrimaryColor, 0xFF112233);
    expect(s.customAccentColor, 0xFFAABBCC);
    expect(s.darkMode, DarkModePref.dark);
    expect(s.presenceMode, 'active');
  });

  test('clearBuddy resets the buddy to null', () async {
    await repo.updateSettings(selectedBuddy: BuddyId.fox);
    expect((await repo.readSettings()).selectedBuddy, BuddyId.fox);
    await repo.updateSettings(clearBuddy: true);
    expect((await repo.readSettings()).selectedBuddy, isNull);
  });

  test('clearCustomPrimary/clearCustomAccent reset color overrides', () async {
    await repo.updateSettings(
      customPrimaryColor: 0xFF111111,
      customAccentColor: 0xFF222222,
    );
    await repo.updateSettings(
      clearCustomPrimary: true,
      clearCustomAccent: true,
    );
    final s = await repo.readSettings();
    expect(s.customPrimaryColor, isNull);
    expect(s.customAccentColor, isNull);
  });

  test('existing v3 settings columns still work alongside v4 columns',
      () async {
    await repo.updateSettings(
      followUpEnabled: false,
      ttlMinutes: 15,
      selectedBuddy: BuddyId.snake,
    );
    final s = await repo.readSettings();
    expect(s.followUpEnabled, isFalse);
    expect(s.ttlMinutes, 15);
    expect(s.selectedBuddy, BuddyId.snake);
  });
}
