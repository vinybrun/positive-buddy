import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/theme/app_theme.dart';
import 'package:habit_buddy/theme/buddy.dart';
import 'package:habit_buddy/theme/theme_palettes.dart';

void main() {
  group('buildTheme', () {
    test('uses the palette seed for a light palette', () {
      final theme = buildTheme(palette: ThemePaletteId.sunrise);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      // Scaffold uses the palette's tinted background, not the default surface.
      expect(theme.scaffoldBackgroundColor,
          palettes[ThemePaletteId.sunrise]!.scaffold);
    });

    test('produces a dark scheme for a dark palette', () {
      final theme = buildTheme(palette: ThemePaletteId.midnight);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('primaryOverride wins over the seed-derived primary', () {
      const override = Color(0xFF112233);
      final theme = buildTheme(
        palette: ThemePaletteId.sunrise,
        primaryOverride: override,
      );
      expect(theme.colorScheme.primary, override);
      // Deep navy is dark — onPrimary should be white.
      expect(theme.colorScheme.onPrimary, Colors.white);
    });

    test('accentOverride picks black onSecondary for a light override', () {
      const override = Color(0xFFF6E58D); // pale yellow
      final theme = buildTheme(
        palette: ThemePaletteId.sunrise,
        accentOverride: override,
      );
      expect(theme.colorScheme.secondary, override);
      expect(theme.colorScheme.onSecondary, Colors.black);
    });
  });

  group('resolvePalette', () {
    test('null buddy + auto themeId falls back to sunrise in light', () {
      final p = resolvePalette(
        buddy: null,
        themeId: 'auto',
        brightness: Brightness.light,
      );
      expect(p, ThemePaletteId.sunrise);
    });

    test('null buddy + auto themeId picks a dark default in dark', () {
      final p = resolvePalette(
        buddy: null,
        themeId: 'auto',
        brightness: Brightness.dark,
      );
      expect(p.isDark, isTrue);
    });

    test('buddy default applies when themeId is auto', () {
      final p = resolvePalette(
        buddy: BuddyId.butterfly,
        themeId: 'auto',
        brightness: Brightness.light,
      );
      expect(p, ThemePaletteId.sky);
    });

    test('explicit palette wins when brightness matches', () {
      final p = resolvePalette(
        buddy: BuddyId.fox,
        themeId: ThemePaletteId.petal.id,
        brightness: Brightness.light,
      );
      expect(p, ThemePaletteId.petal);
    });

    test('mismatched-brightness explicit palette falls back to buddy default',
        () {
      // User picked petal (light) but the resolved brightness is dark — we
      // don't strand them on a light palette; fall back to fox's dark default.
      final p = resolvePalette(
        buddy: BuddyId.fox,
        themeId: ThemePaletteId.petal.id,
        brightness: Brightness.dark,
      );
      expect(p.isDark, isTrue);
    });
  });

  group('BuddyId / ThemePaletteId / DarkModePref fromId', () {
    test('roundtrip BuddyId ids', () {
      for (final b in BuddyId.values) {
        expect(BuddyId.fromId(b.id), b);
      }
    });

    test('unknown buddy id returns null', () {
      expect(BuddyId.fromId('octopus'), isNull);
    });

    test('unknown theme id returns null', () {
      expect(ThemePaletteId.fromId('chartreuse'), isNull);
    });

    test('DarkModePref defaults to system on unknown id', () {
      expect(DarkModePref.fromId('????'), DarkModePref.system);
      expect(DarkModePref.fromId(null), DarkModePref.system);
    });
  });
}
