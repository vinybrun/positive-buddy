import 'package:flutter/material.dart';

/// Named, hand-picked color palette. Each maps to a seed + scaffold tint at
/// a specific brightness, so the same id reads as either a "light, colorful"
/// or a "dark, lively" theme depending on its declared brightness.
enum ThemePaletteId {
  // Light & colorful — one per buddy pack
  sunrise('sunrise', 'Sunrise', Brightness.light),
  petal('petal', 'Petal', Brightness.light),
  meadow('meadow', 'Meadow', Brightness.light),
  sky('sky', 'Sky', Brightness.light),
  moss('moss', 'Moss', Brightness.light),
  // Dark & lively — one per buddy pack
  mulberry('mulberry', 'Mulberry', Brightness.dark),
  cherry('cherry', 'Cherry', Brightness.dark),
  forest('forest', 'Forest', Brightness.dark),
  midnight('midnight', 'Midnight', Brightness.dark),
  jade('jade', 'Jade', Brightness.dark);

  const ThemePaletteId(this.id, this.label, this.brightness);
  final String id;
  final String label;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  static ThemePaletteId? fromId(String? id) {
    if (id == null) return null;
    for (final p in ThemePaletteId.values) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Concrete color tokens for a palette. `seed` drives the Material 3
/// `ColorScheme.fromSeed`; `scaffold` is a tinted page background that sits
/// on top of the generated surface color for a slightly warmer feel.
class PaletteSpec {
  const PaletteSpec({
    required this.seed,
    required this.scaffold,
  });
  final Color seed;
  final Color scaffold;
}

const Map<ThemePaletteId, PaletteSpec> palettes = {
  // Original v1 colors — kept verbatim so existing installs see no change
  // until they actively pick a new theme.
  ThemePaletteId.sunrise: PaletteSpec(
    seed: Color(0xFFCC6B49),
    scaffold: Color(0xFFFBF6EF),
  ),
  ThemePaletteId.meadow: PaletteSpec(
    seed: Color(0xFF7A8F5C),
    scaffold: Color(0xFFF6F2E8),
  ),
  ThemePaletteId.sky: PaletteSpec(
    seed: Color(0xFF5B8EAD),
    scaffold: Color(0xFFF1EEE6),
  ),
  ThemePaletteId.petal: PaletteSpec(
    seed: Color(0xFFD06A8A),
    scaffold: Color(0xFFFDF3F2),
  ),
  ThemePaletteId.midnight: PaletteSpec(
    seed: Color(0xFF8AA0FF),
    scaffold: Color(0xFF181826),
  ),
  ThemePaletteId.forest: PaletteSpec(
    seed: Color(0xFFE7B96B),
    scaffold: Color(0xFF14201A),
  ),
  ThemePaletteId.mulberry: PaletteSpec(
    seed: Color(0xFFEAA597),
    scaffold: Color(0xFF211218),
  ),
  // New v6 palettes so each buddy pack is visually distinct.
  ThemePaletteId.moss: PaletteSpec(
    seed: Color(0xFF558B5E),
    scaffold: Color(0xFFEFF3E8),
  ),
  ThemePaletteId.cherry: PaletteSpec(
    seed: Color(0xFFE08FA8),
    scaffold: Color(0xFF1F1218),
  ),
  ThemePaletteId.jade: PaletteSpec(
    seed: Color(0xFF7FB991),
    scaffold: Color(0xFF13211B),
  ),
};

/// User's appearance preference. `system` follows the OS dark-mode setting;
/// `light` and `dark` override it. The chosen palette already declares a
/// brightness — this preference picks which of the buddy's two default
/// palettes (or the user's explicit override) to use.
enum DarkModePref {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark');

  const DarkModePref(this.id, this.label);
  final String id;
  final String label;

  static DarkModePref fromId(String? id) {
    if (id == null) return DarkModePref.system;
    for (final m in DarkModePref.values) {
      if (m.id == id) return m;
    }
    return DarkModePref.system;
  }
}
