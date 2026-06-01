import 'dart:ui' show Brightness;

import 'buddy.dart';
import 'theme_palettes.dart';

/// Each buddy comes with a suggested light *and* dark palette. The user can
/// override either choice in profile, but until they do these are what gets
/// applied automatically when they pick the buddy.
class BuddyDefaultThemes {
  const BuddyDefaultThemes({required this.light, required this.dark});
  final ThemePaletteId light;
  final ThemePaletteId dark;
}

const Map<BuddyId, BuddyDefaultThemes> buddyDefaultThemes = {
  BuddyId.fox: BuddyDefaultThemes(
    light: ThemePaletteId.sunrise,
    dark: ThemePaletteId.mulberry,
  ),
  BuddyId.cat: BuddyDefaultThemes(
    light: ThemePaletteId.petal,
    dark: ThemePaletteId.cherry,
  ),
  BuddyId.dog: BuddyDefaultThemes(
    light: ThemePaletteId.meadow,
    dark: ThemePaletteId.forest,
  ),
  BuddyId.butterfly: BuddyDefaultThemes(
    light: ThemePaletteId.sky,
    dark: ThemePaletteId.midnight,
  ),
  BuddyId.snake: BuddyDefaultThemes(
    light: ThemePaletteId.moss,
    dark: ThemePaletteId.jade,
  ),
  // v12: bird/Skye reuses the sky+midnight pair (similar feel to
  // butterfly but distinct vibe via the phoenix evolution arc).
  BuddyId.bird: BuddyDefaultThemes(
    light: ThemePaletteId.sky,
    dark: ThemePaletteId.midnight,
  ),
};

ThemePaletteId defaultPaletteFor(BuddyId? buddy, Brightness brightness) {
  // Fall back to the original v1 sunrise palette for users who haven't
  // picked a buddy yet — preserves the look of the shipped app.
  final defaults = buddy == null
      ? const BuddyDefaultThemes(
          light: ThemePaletteId.sunrise,
          dark: ThemePaletteId.midnight,
        )
      : buddyDefaultThemes[buddy]!;
  return brightness == Brightness.dark ? defaults.dark : defaults.light;
}
