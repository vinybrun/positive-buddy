import 'package:flutter/material.dart';

import 'time_windows.dart';
import 'window_selection.dart';

/// Single-select chip row for time windows plus an exclusive "Custom…" pill
/// that opens a two-tap time-range picker. Used by both Add Habit and Edit
/// Habit screens. Picking a preset replaces the current selection; picking
/// Custom… clears the preset and stores a literal range.
class WindowPicker extends StatelessWidget {
  const WindowPicker({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  final WindowSelection selection;
  final ValueChanged<WindowSelection> onChanged;

  void _selectPreset(TimeWindow w) {
    onChanged(WindowSelection(windows: {w}));
  }

  Future<void> _openCustomPicker(BuildContext context) async {
    final initialStart =
        selection.customRange?.start ?? const TimeOfDay(hour: 8, minute: 0);
    final start = await showTimePicker(
      context: context,
      initialTime: initialStart,
      helpText: 'Start of range',
    );
    if (start == null || !context.mounted) return;
    final initialEnd =
        selection.customRange?.end ?? const TimeOfDay(hour: 11, minute: 0);
    final end = await showTimePicker(
      context: context,
      initialTime: initialEnd,
      helpText: 'End of range',
    );
    if (end == null) return;
    onChanged(WindowSelection(
      windows: const {},
      customRange: CustomTimeRange(
        startMinutes: CustomTimeRange.toMinutes(start),
        endMinutes: CustomTimeRange.toMinutes(end),
      ),
    ));
  }

  void _clearCustom() {
    onChanged(WindowSelection(windows: {TimeWindow.anytime}));
  }

  String _formatRange(BuildContext context, CustomTimeRange r) {
    return '${r.start.format(context)} – ${r.end.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    if (selection.hasCustomRange) {
      // Custom mode — show a single pill with the range and an edit/clear
      // affordance. No preset chips when in this mode.
      final r = selection.customRange!;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          InputChip(
            avatar: const Icon(Icons.schedule, size: 16),
            label: Text(_formatRange(context, r)),
            onPressed: () => _openCustomPicker(context),
            onDeleted: _clearCustom,
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
          TextButton.icon(
            onPressed: () => _openCustomPicker(context),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Adjust'),
          ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final w in TimeWindow.values)
          ChoiceChip(
            avatar: Icon(w.icon, size: 16),
            label: Text(w.label),
            selected: selection.windows.contains(w),
            onSelected: (_) => _selectPreset(w),
          ),
        ActionChip(
          avatar: const Icon(Icons.schedule, size: 16),
          label: const Text('Custom…'),
          onPressed: () => _openCustomPicker(context),
        ),
      ],
    );
  }
}
