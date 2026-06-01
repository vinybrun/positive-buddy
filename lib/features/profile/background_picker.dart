import 'package:flutter/material.dart';

import '../../data/repositories/profile_repository.dart';

/// v9 background composition picker.
///
/// The user picks three things and the theme provider blends them into
/// the final scaffold color:
///   - **Base**: Light (white), Dark (black), or Colorful (no base —
///     the tint shows alone).
///   - **Tint**: a vibrant color.
///   - **Strength**: 0..100, how much of the tint shows over the base.
///     Ignored when base = Colorful.
///
/// Layout: side-by-side — base radio column on the left, tint swatch
/// grid on the right. Strength slider underneath. Live preview swatch
/// next to the section title so the user sees the composed result.
class BackgroundPicker extends StatefulWidget {
  const BackgroundPicker({
    super.key,
    required this.base,
    required this.tint,
    required this.strength,
    required this.tintSwatches,
    required this.onBaseChanged,
    required this.onTintChanged,
    required this.onStrengthChanged,
  });

  final BackgroundBase base;
  final Color tint;
  final int strength; // 0..100
  final List<Color> tintSwatches;
  final ValueChanged<BackgroundBase> onBaseChanged;
  final ValueChanged<Color> onTintChanged;
  final ValueChanged<int> onStrengthChanged;

  @override
  State<BackgroundPicker> createState() => _BackgroundPickerState();
}

class _BackgroundPickerState extends State<BackgroundPicker> {
  bool _mixerOpen = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final showStrength = widget.base != BackgroundBase.colorful;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Background', style: text.labelLarge),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BaseTile(
                      label: 'Auto',
                      selected: widget.base == BackgroundBase.auto,
                      onTap: () =>
                          widget.onBaseChanged(BackgroundBase.auto),
                    ),
                    _BaseTile(
                      label: 'Light',
                      selected: widget.base == BackgroundBase.light,
                      onTap: () =>
                          widget.onBaseChanged(BackgroundBase.light),
                    ),
                    _BaseTile(
                      label: 'Dark',
                      selected: widget.base == BackgroundBase.dark,
                      onTap: () =>
                          widget.onBaseChanged(BackgroundBase.dark),
                    ),
                    _BaseTile(
                      label: 'Colorful',
                      selected: widget.base == BackgroundBase.colorful,
                      onTap: () =>
                          widget.onBaseChanged(BackgroundBase.colorful),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in widget.tintSwatches)
                          _TintSwatch(
                            color: c,
                            selected:
                                widget.tint.toARGB32() == c.toARGB32(),
                            onTap: () => widget.onTintChanged(c),
                          ),
                      ],
                    ),
                    if (showStrength) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                value: widget.strength.toDouble(),
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: '${widget.strength}%',
                                onChanged: (v) =>
                                    widget.onStrengthChanged(v.round()),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${widget.strength}%',
                              textAlign: TextAlign.right,
                              style: text.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Plain toggle for the RGB mixer — same pattern as the primary
        // picker, avoids ExpansionTile's theme-rebuild issues.
        InkWell(
          onTap: () => setState(() => _mixerOpen = !_mixerOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mix a custom tint',
                    style: text.bodyMedium,
                  ),
                ),
                Icon(_mixerOpen ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_mixerOpen)
          _RgbTintSliders(
            value: widget.tint,
            onChanged: widget.onTintChanged,
          ),
      ],
    );
  }
}

class _BaseTile extends StatelessWidget {
  const _BaseTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.primary : colors.outline,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
            Expanded(child: Text(label, style: text.bodyLarge)),
          ],
        ),
      ),
    );
  }
}

class _TintSwatch extends StatelessWidget {
  const _TintSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });
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

class _RgbTintSliders extends StatefulWidget {
  const _RgbTintSliders({required this.value, required this.onChanged});
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  State<_RgbTintSliders> createState() => _RgbTintSlidersState();
}

class _RgbTintSlidersState extends State<_RgbTintSliders> {
  late double _r, _g, _b;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.value);
  }

  @override
  void didUpdateWidget(covariant _RgbTintSliders old) {
    super.didUpdateWidget(old);
    if (old.value.toARGB32() != widget.value.toARGB32()) {
      _syncFrom(widget.value);
    }
  }

  void _syncFrom(Color c) {
    _r = (c.r * 255).roundToDouble();
    _g = (c.g * 255).roundToDouble();
    _b = (c.b * 255).roundToDouble();
  }

  void _emit() {
    widget.onChanged(
      Color.fromARGB(255, _r.round(), _g.round(), _b.round()),
    );
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
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
