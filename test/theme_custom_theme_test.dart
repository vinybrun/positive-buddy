import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/theme/app_theme.dart';
import 'package:habit_buddy/theme/buddy.dart';
import 'package:habit_buddy/theme/buddy_themes.dart';
import 'package:habit_buddy/theme/theme_palettes.dart';

void main() {
  group('resolveSpec — Phase 1 custom theme', () {
    test('"custom" themeId uses the customPrimary as the seed', () {
      const teal = Color(0xFF00897B);
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: customThemeId,
        brightness: Brightness.light,
        customPrimary: teal,
        customAccent: const Color(0xFFFFB300),
      );
      expect(spec.seed, teal);
    });

    test('"custom" themeId picks a dark scaffold in dark mode', () {
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: customThemeId,
        brightness: Brightness.dark,
        customPrimary: const Color(0xFF00897B),
        customAccent: const Color(0xFFFFB300),
      );
      // Sanity: the scaffold is dark (low luminance), not a pale tinted
      // light-mode background bleeding into dark mode.
      expect(spec.scaffold.computeLuminance(), lessThan(0.1));
    });

    test('"custom" themeId picks a light scaffold in light mode', () {
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: customThemeId,
        brightness: Brightness.light,
        customPrimary: const Color(0xFF00897B),
        customAccent: const Color(0xFFFFB300),
      );
      expect(spec.scaffold.computeLuminance(), greaterThan(0.5));
    });

    test('"custom" themeId without customPrimary falls back to buddy seed',
        () {
      // Defensive — if the persisted state is somehow themeId='custom' with
      // no color stored, we should still render something sensible.
      final spec = resolveSpec(
        buddy: BuddyId.snake,
        themeId: customThemeId,
        brightness: Brightness.light,
        customPrimary: null,
        customAccent: null,
      );
      final snakeLight = buddyDefaultThemes[BuddyId.snake]!.light;
      expect(spec.seed, palettes[snakeLight]!.seed);
    });

    test('non-custom themeId ignores the customPrimary/customAccent args',
        () {
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: BuddyId.fox.id,
        brightness: Brightness.light,
        customPrimary: const Color(0xFF00FF00),
        customAccent: const Color(0xFFFF00FF),
      );
      final foxLight = buddyDefaultThemes[BuddyId.fox]!.light;
      expect(spec.seed, palettes[foxLight]!.seed);
    });
  });

  group('resolveSpec — v8 custom background', () {
    test('custom background wins over themeId, becomes scaffold', () {
      const bg = Color(0xFFEEE5D3);
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: BuddyId.dog.id, // would normally pick meadow seed
        brightness: Brightness.light,
        customBackground: bg,
      );
      expect(spec.scaffold, bg);
    });

    test('custom background + custom primary: seed is the primary', () {
      const bg = Color(0xFFEEE5D3);
      const seed = Color(0xFF00897B);
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: 'auto',
        brightness: Brightness.light,
        customBackground: bg,
        customPrimary: seed,
      );
      expect(spec.scaffold, bg);
      expect(spec.seed, seed);
    });

    test('custom background without primary picks buddy seed by inferred brightness',
        () {
      // Dark BG → expect a dark-pack seed for the buddy.
      const darkBg = Color(0xFF101820);
      final spec = resolveSpec(
        buddy: BuddyId.fox,
        themeId: 'auto',
        brightness: Brightness.light, // explicitly wrong on purpose
        customBackground: darkBg,
      );
      // brightnessForBackground(darkBg) == dark, so the fox dark pack
      // (mulberry) should drive the seed.
      expect(spec.seed, palettes[ThemePaletteId.mulberry]!.seed);
      expect(spec.scaffold, darkBg);
    });

    test('brightnessForBackground splits on luminance 0.5', () {
      expect(brightnessForBackground(const Color(0xFFFFFFFF)), Brightness.light);
      expect(brightnessForBackground(const Color(0xFF000000)), Brightness.dark);
      expect(brightnessForBackground(const Color(0xFFF6F2E8)), Brightness.light);
      expect(brightnessForBackground(const Color(0xFF181826)), Brightness.dark);
    });
  });

  group('resolveSpec — pack id maps to brightness-appropriate variant', () {
    test('fox pack in light returns sunrise', () {
      final spec = resolveSpec(
        buddy: null,
        themeId: BuddyId.fox.id,
        brightness: Brightness.light,
      );
      expect(spec.seed, palettes[ThemePaletteId.sunrise]!.seed);
    });

    test('fox pack in dark returns mulberry', () {
      final spec = resolveSpec(
        buddy: null,
        themeId: BuddyId.fox.id,
        brightness: Brightness.dark,
      );
      expect(spec.seed, palettes[ThemePaletteId.mulberry]!.seed);
    });

    test('cat pack in light returns petal', () {
      final spec = resolveSpec(
        buddy: null,
        themeId: BuddyId.cat.id,
        brightness: Brightness.light,
      );
      expect(spec.seed, palettes[ThemePaletteId.petal]!.seed);
    });

    test('cat pack in dark returns cherry', () {
      final spec = resolveSpec(
        buddy: null,
        themeId: BuddyId.cat.id,
        brightness: Brightness.dark,
      );
      expect(spec.seed, palettes[ThemePaletteId.cherry]!.seed);
    });
  });
}
