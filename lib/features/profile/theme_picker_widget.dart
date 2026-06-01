import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/buddy.dart';
import '../../theme/buddy_themes.dart';
import '../../theme/theme_palettes.dart';

/// Single horizontal row of 5 pack swatches — one per buddy, but identified
/// only by color so the picker reads as "five themes" rather than "five
/// animals". Each swatch shows the pack's *currently-resolved* brightness
/// variant: in Light mode all five show their light palettes; in Dark mode
/// all five show their dark palettes. Toggling Appearance flips them.
///
/// A "Custom" chip appears at the right when the user has switched to a
/// custom theme by picking a color; it's a state indicator, not a button.
class BuddyThemePackRow extends StatelessWidget {
  const BuddyThemePackRow({
    super.key,
    required this.selectedThemeId,
    required this.selectedBuddy,
    required this.onPackSelected,
  });

  /// 'auto' | 'custom' | a [BuddyId.id] | a legacy [ThemePaletteId.id].
  final String selectedThemeId;

  /// Used only to highlight the buddy's pack when [selectedThemeId] is
  /// 'auto'. Null when no buddy is picked yet.
  final BuddyId? selectedBuddy;

  final ValueChanged<BuddyId> onPackSelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isCustom = selectedThemeId == customThemeId;
    final selectedPack = BuddyId.fromId(selectedThemeId);
    // 'auto' highlights the buddy's pack so the user always sees what's
    // actually being applied.
    final highlighted = selectedPack ?? (isCustom ? null : selectedBuddy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            children: [
              for (final b in BuddyId.values) ...[
                _PackSwatch(
                  buddy: b,
                  brightness: brightness,
                  selected: highlighted == b && !isCustom,
                  onTap: () => onPackSelected(b),
                ),
                const SizedBox(width: 12),
              ],
              if (isCustom) _CustomChip(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackSwatch extends StatelessWidget {
  const _PackSwatch({
    required this.buddy,
    required this.brightness,
    required this.selected,
    required this.onTap,
  });
  final BuddyId buddy;
  final Brightness brightness;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pack = buddyDefaultThemes[buddy]!;
    final paletteId = brightness == Brightness.dark ? pack.dark : pack.light;
    final spec = palettes[paletteId]!;
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(child: Container(color: spec.scaffold)),
                Expanded(child: Container(color: spec.seed)),
              ],
            ),
            if (selected)
              Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 18, color: colors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.primary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette, color: colors.onPrimary, size: 18),
          const SizedBox(width: 6),
          Text(
            'Custom',
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
