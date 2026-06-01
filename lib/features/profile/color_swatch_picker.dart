import 'package:flutter/material.dart';

/// Compact color picker: a curated grid of swatches plus three RGB sliders
/// inside an expansion tile for "I want exactly this color." Avoids pulling
/// in a third-party picker package — the curated swatches handle the
/// common cases and the sliders cover everything else.
class ColorSwatchPicker extends StatefulWidget {
  const ColorSwatchPicker({
    super.key,
    required this.label,
    required this.current,
    required this.overridden,
    required this.onChanged,
    required this.onCleared,
    this.swatches = primarySwatches,
  });

  final String label;

  /// The color currently in effect — either the user's override or the
  /// resolved theme color when no override is set. Used to highlight the
  /// matching swatch so the picker stays in sync with what the app is
  /// actually rendering.
  final Color current;

  /// True when [current] is a user-set override (so the Reset affordance
  /// should appear). False when [current] is the resolved theme color.
  final bool overridden;

  final ValueChanged<Color> onChanged;
  final VoidCallback onCleared;

  /// Predefined palette shown as quick-pick chips. Defaults to
  /// [primarySwatches]; the background picker passes [backgroundSwatches]
  /// instead so users see scaffold-appropriate colors (off-whites + deep
  /// neutrals) rather than vivid accents.
  final List<Color> swatches;

  /// Curated colors for the Primary picker — one row's worth of vivid
  /// hues that read well as foreground accents. Kept compact so the
  /// buddy preview above stays in view while the user scrolls past.
  static const primarySwatches = <Color>[
    Color(0xFFCC6B49), // sunrise terracotta
    Color(0xFFD06A8A), // rose
    Color(0xFFE0B45E), // honey
    Color(0xFF7A8F5C), // sage
    Color(0xFF5B8EAD), // powder blue
    Color(0xFF6E4B8B), // mulberry
    Color(0xFF2C3E50), // midnight
  ];

  /// Vibrant accent palette for the Background picker's "tint" slot.
  static const tintSwatches = <Color>[
    Color(0xFFCC6B49), // terracotta
    Color(0xFFD06A8A), // rose
    Color(0xFFE7B96B), // golden
    Color(0xFF7A8F5C), // sage
    Color(0xFF5B8EAD), // powder blue
    Color(0xFF8AA0FF), // periwinkle
    Color(0xFF8C7BB5), // lavender
    Color(0xFF6F9B8E), // teal
  ];

  // v9: the direct background swatch grid is gone — the BG is now composed
  // from base + tint + strength. Kept the field name retired (no list
  // constant) so any external referrer fails fast at the analyzer.

  @override
  State<ColorSwatchPicker> createState() => _ColorSwatchPickerState();
}

class _ColorSwatchPickerState extends State<ColorSwatchPicker> {
  bool _mixerOpen = false;

  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Small preview dot so the user always sees the effective color,
            // even when it's a seed-derived value not present in the swatch
            // grid (e.g. the active pack's primary).
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: current,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (widget.overridden)
              TextButton.icon(
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Reset'),
                onPressed: widget.onCleared,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in widget.swatches)
              _Swatch(
                color: c,
                selected: current.toARGB32() == c.toARGB32(),
                onTap: () => widget.onChanged(c),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // Plain toggle instead of ExpansionTile — the latter's internal
        // state interacts badly with MaterialApp theme rebuilds (red-screen
        // InheritedElement assertion when switching pack/dark mode).
        InkWell(
          onTap: () => setState(() => _mixerOpen = !_mixerOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mix a custom color',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Icon(_mixerOpen
                    ? Icons.expand_less
                    : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_mixerOpen)
          _RgbSliders(
            value: current,
            onChanged: widget.onChanged,
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(
      {required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? outline : Colors.black12,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 18,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _RgbSliders extends StatefulWidget {
  const _RgbSliders({required this.value, required this.onChanged});
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  State<_RgbSliders> createState() => _RgbSlidersState();
}

class _RgbSlidersState extends State<_RgbSliders> {
  late double _r;
  late double _g;
  late double _b;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.value);
  }

  @override
  void didUpdateWidget(covariant _RgbSliders old) {
    super.didUpdateWidget(old);
    if (old.value.toARGB32() != widget.value.toARGB32()) {
      _syncFrom(widget.value);
    }
  }

  void _syncFrom(Color c) {
    // Color.r/g/b are 0..1 doubles in modern Flutter. Convert to 0..255.
    _r = (c.r * 255).roundToDouble();
    _g = (c.g * 255).roundToDouble();
    _b = (c.b * 255).roundToDouble();
  }

  void _emit() {
    final c = Color.fromARGB(255, _r.round(), _g.round(), _b.round());
    widget.onChanged(c);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Channel(
          label: 'R',
          value: _r,
          color: Colors.red,
          onChanged: (v) => setState(() {
            _r = v;
            _emit();
          }),
        ),
        _Channel(
          label: 'G',
          value: _g,
          color: Colors.green,
          onChanged: (v) => setState(() {
            _g = v;
            _emit();
          }),
        ),
        _Channel(
          label: 'B',
          value: _b,
          color: Colors.blue,
          onChanged: (v) => setState(() {
            _b = v;
            _emit();
          }),
        ),
      ],
    );
  }
}

class _Channel extends StatelessWidget {
  const _Channel({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(value.round().toString(),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
