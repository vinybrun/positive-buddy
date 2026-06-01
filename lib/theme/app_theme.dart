import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/profile_repository.dart';
import 'buddy.dart';
import 'buddy_themes.dart';
import 'theme_palettes.dart';

/// Single source of truth for app-wide ThemeData. Every screen reads from
/// `Theme.of(context).colorScheme`; this function decides what that scheme
/// resolves to.
///
/// `primaryOverride` and `accentOverride` are user-chosen colors from the
/// color-picker. When set, they replace `primary` / `secondary` on the
/// generated scheme; the rest of the M3 palette stays derived from the seed
/// (so disabled states, surfaces, etc. still feel coherent).
ThemeData buildTheme({
  required ThemePaletteId palette,
  Color? primaryOverride,
  Color? accentOverride,
}) =>
    buildThemeFromSpec(
      spec: palettes[palette]!,
      brightness: palette.brightness,
      primaryOverride: primaryOverride,
      accentOverride: accentOverride,
    );

/// Spec-based variant used by the custom-theme path (which doesn't have a
/// [ThemePaletteId] to look up). Both flow through the same scheme builder
/// so overrides behave identically.
ThemeData buildThemeFromSpec({
  required PaletteSpec spec,
  required Brightness brightness,
  Color? primaryOverride,
  Color? accentOverride,
}) {
  var scheme = ColorScheme.fromSeed(
    seedColor: spec.seed,
    brightness: brightness,
  );

  if (primaryOverride != null) {
    scheme = scheme.copyWith(
      primary: primaryOverride,
      onPrimary: _onColorFor(primaryOverride),
    );
  }
  if (accentOverride != null) {
    scheme = scheme.copyWith(
      secondary: accentOverride,
      onSecondary: _onColorFor(accentOverride),
    );
  }

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: spec.scaffold,
    // Transparent app bar across the app so the scaffold color paints
    // edge-to-edge into the status-bar/top area without a hard band.
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4),
    ),
  );
}

/// WCAG-style contrast picker for "text on this color." Returns white or
/// black depending on the perceived luminance of [bg]. Used when a custom
/// primary/secondary lands somewhere the auto-derived `onPrimary` would
/// look wrong (e.g. a pale yellow override would still get black text
/// from the seed-derived scheme, which is right — but a deep navy override
/// needs white). Computing it ourselves is more reliable than trusting the
/// seed-derived onColor for an arbitrary user choice.
Color _onColorFor(Color bg) {
  return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

/// Sentinel themeId meaning "use the customPrimary + customAccent colors
/// the user picked, over a brightness-appropriate neutral scaffold."
const String customThemeId = 'custom';

/// Resolved palette for the current user profile + requested brightness.
///
/// `themeId` can be:
///   - `'auto'` — follow the current buddy's pack for the brightness.
///   - A pack key (one of [BuddyId.id]) — render that pack's pair, taking
///     the matching brightness side. Lets the user pick a pack independent
///     of their buddy.
///   - A bare [ThemePaletteId.id] — legacy v4 data. Honored only if its
///     brightness matches; otherwise we fall through to the buddy default
///     so toggling dark mode doesn't strand the user on a mismatched
///     palette.
///
/// For `themeId == 'custom'` the caller should NOT call `resolvePalette`;
/// they should use [resolveSpec] which knows how to synthesize a custom
/// PaletteSpec from the user's picked colors.
///
/// Visible for testing.
ThemePaletteId resolvePalette({
  required BuddyId? buddy,
  required String themeId,
  required Brightness brightness,
}) {
  if (themeId == 'auto') {
    return defaultPaletteFor(buddy, brightness);
  }
  // Pack id (= a buddy id used as a theme key)
  final packBuddy = BuddyId.fromId(themeId);
  if (packBuddy != null) {
    final pack = buddyDefaultThemes[packBuddy]!;
    return brightness == Brightness.dark ? pack.dark : pack.light;
  }
  // Legacy: explicit palette id stored from v4. Honor if brightness
  // matches, else fall back.
  final palette = ThemePaletteId.fromId(themeId);
  if (palette != null && palette.brightness == brightness) {
    return palette;
  }
  return defaultPaletteFor(buddy, brightness);
}

/// Same as [resolvePalette] but returns a concrete [PaletteSpec], handling
/// custom-background and custom-primary overrides.
///
/// Precedence (v8):
/// 1. If [customBackground] is set, it becomes the scaffold AND drives the
///    `brightness` value passed back to the caller. The seed is
///    [customPrimary] if set, otherwise the buddy's default for the
///    inferred brightness. This is the primary "user wants their own look"
///    path — the pack picker is irrelevant in this mode.
/// 2. Else if `themeId == 'custom'`, use the legacy custom path (custom
///    primary over a neutral scaffold).
/// 3. Else resolve the pack via [resolvePalette].
PaletteSpec resolveSpec({
  required BuddyId? buddy,
  required String themeId,
  required Brightness brightness,
  Color? customPrimary,
  Color? customAccent,
  Color? customBackground,
}) {
  if (customBackground != null) {
    final inferred = brightnessForBackground(customBackground);
    final seed = customPrimary ??
        palettes[defaultPaletteFor(buddy, inferred)]!.seed;
    return PaletteSpec(seed: seed, scaffold: customBackground);
  }
  if (themeId == customThemeId) {
    final seed = customPrimary ??
        palettes[defaultPaletteFor(buddy, brightness)]!.seed;
    final scaffold = brightness == Brightness.dark
        ? const Color(0xFF181826)
        : const Color(0xFFF6F2E8);
    return PaletteSpec(seed: seed, scaffold: scaffold);
  }
  return palettes[resolvePalette(
    buddy: buddy,
    themeId: themeId,
    brightness: brightness,
  )]!;
}

/// Picks light vs dark text/icon contrast for a given background. Above
/// 0.5 luminance we treat the surface as light (dark text); below, dark
/// (light text). Drives the theme's `Brightness` so Material components
/// pick their on-surface defaults appropriately.
Brightness brightnessForBackground(Color bg) =>
    bg.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark;

/// v9 background composition: blend a solid [base] with [tint] at the
/// given [strength] (0..100). 'colorful' base means "tint only" — the
/// strength is ignored and the tint shows as-is. 'auto' resolves to
/// light or dark using the [systemBrightness] argument.
///
/// The math is straight alpha-composition: out = base * (1 - a) + tint * a
/// where a = strength / 100. With a=0 the result is the pure base, with
/// a=1 the result is the pure tint.
Color composeBackground({
  required BackgroundBase base,
  required Color tint,
  required int strength,
  Brightness systemBrightness = Brightness.light,
}) {
  if (base == BackgroundBase.colorful) {
    return tint;
  }
  final effective = base == BackgroundBase.auto
      ? (systemBrightness == Brightness.dark
          ? BackgroundBase.dark
          : BackgroundBase.light)
      : base;
  final baseColor = effective == BackgroundBase.light
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
  final a = (strength.clamp(0, 100)) / 100.0;
  int mix(int a8, int b8) => (a8 * (1 - a) + b8 * a).round();
  return Color.fromARGB(
    255,
    mix((baseColor.r * 255).round(), (tint.r * 255).round()),
    mix((baseColor.g * 255).round(), (tint.g * 255).round()),
    mix((baseColor.b * 255).round(), (tint.b * 255).round()),
  );
}

class AppThemeSet {
  const AppThemeSet({
    required this.light,
    required this.dark,
    required this.mode,
  });
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
}

/// Riverpod provider exposing the live theme set. Watches the user profile
/// stream; the MaterialApp consumes `light`/`dark`/`mode` and Flutter handles
/// system-brightness switching automatically.
final themeProvider = Provider<AppThemeSet>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final settings = UserSettings.fromRow(profileAsync.value);
  final primaryOverride = settings.customPrimaryColor == null
      ? null
      : Color(settings.customPrimaryColor!);
  final accentOverride = settings.customAccentColor == null
      ? null
      : Color(settings.customAccentColor!);

  // v9 (auto): build both light and dark themes with the tint composed
  // over the matching base, and let ThemeMode.system pick at runtime.
  if (settings.bgBase == BackgroundBase.auto) {
    ThemeData buildFor(Brightness b) {
      final bg = composeBackground(
        base: BackgroundBase.auto,
        tint: Color(settings.bgTintColor),
        strength: settings.bgTintStrength,
        systemBrightness: b,
      );
      final spec = resolveSpec(
        buddy: settings.selectedBuddy,
        themeId: settings.themeId,
        brightness: b,
        customPrimary: primaryOverride,
        customAccent: accentOverride,
        customBackground: bg,
      );
      return buildThemeFromSpec(
        spec: spec,
        brightness: b,
        primaryOverride: primaryOverride,
        accentOverride: accentOverride,
      );
    }

    return AppThemeSet(
      light: buildFor(Brightness.light),
      dark: buildFor(Brightness.dark),
      mode: ThemeMode.system,
    );
  }

  // Explicit Light/Dark/Colorful: one theme, both slots resolve to it,
  // mode pinned to the inferred brightness so system toggles can't
  // override the user's pick.
  final backgroundOverride = composeBackground(
    base: settings.bgBase,
    tint: Color(settings.bgTintColor),
    strength: settings.bgTintStrength,
  );
  final brightness = brightnessForBackground(backgroundOverride);
  final spec = resolveSpec(
    buddy: settings.selectedBuddy,
    themeId: settings.themeId,
    brightness: brightness,
    customPrimary: primaryOverride,
    customAccent: accentOverride,
    customBackground: backgroundOverride,
  );
  final theme = buildThemeFromSpec(
    spec: spec,
    brightness: brightness,
    primaryOverride: primaryOverride,
    accentOverride: accentOverride,
  );
  return AppThemeSet(
    light: theme,
    dark: theme,
    mode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
  );
});
