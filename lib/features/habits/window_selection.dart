import 'dart:convert';

import 'package:flutter/material.dart';

import 'time_windows.dart';

/// User's "When?" choice for a habit. Either:
///   - One or more preset windows (`windows` non-empty, `customRange` null), or
///   - A literal custom range (`customRange` non-null, `windows` empty).
///
/// The two modes are mutually exclusive per Phase 6 UX decision; the picker
/// clears one when the user activates the other.
class WindowSelection {
  WindowSelection({
    Set<TimeWindow>? windows,
    this.customRange,
  }) : windows = windows ?? <TimeWindow>{TimeWindow.anytime} {
    assert(
      customRange == null || (this.windows.isEmpty || this.windows.isEmpty),
      'custom range and preset windows are exclusive — caller must pick one',
    );
  }

  final Set<TimeWindow> windows;
  final CustomTimeRange? customRange;

  bool get hasCustomRange => customRange != null;

  /// "Representative" window id for copy purposes — pick the first non-
  /// anytime window in canonical enum order, falling back to anytime when
  /// the user picked only anytime / no preset. Custom ranges flatten to
  /// "anytime" so the copy engine falls back to slot-derived band.
  String get representativeWindowId {
    if (hasCustomRange) return 'anytime';
    final priority = [
      TimeWindow.morning,
      TimeWindow.afternoon,
      TimeWindow.evening,
      TimeWindow.beforeBed,
      TimeWindow.withMeals,
    ];
    for (final p in priority) {
      if (windows.contains(p)) return p.id;
    }
    return TimeWindow.anytime.id;
  }

  /// Convert to the JSON string stored in `Habits.timeWindowsJson`. Empty
  /// `[]` when a custom range is set.
  String toJsonString() {
    if (hasCustomRange) return '[]';
    final list = windows.map((w) => w.id).toList()..sort();
    return jsonEncode(list);
  }

  static WindowSelection fromDb({
    required String timeWindowsJson,
    required int? customStartMinutes,
    required int? customEndMinutes,
    // Legacy v3 single-window value, used only if `timeWindowsJson` is
    // missing or malformed.
    String? legacyTimeWindow,
  }) {
    if (customStartMinutes != null && customEndMinutes != null) {
      return WindowSelection(
        windows: const {},
        customRange: CustomTimeRange(
          startMinutes: customStartMinutes,
          endMinutes: customEndMinutes,
        ),
      );
    }
    Set<TimeWindow> windows;
    try {
      final decoded = jsonDecode(timeWindowsJson);
      if (decoded is List && decoded.isNotEmpty) {
        windows = decoded
            .whereType<String>()
            .map(TimeWindow.fromId)
            .toSet();
        if (windows.isEmpty) {
          windows = {TimeWindow.fromId(legacyTimeWindow)};
        }
      } else {
        windows = {TimeWindow.fromId(legacyTimeWindow)};
      }
    } catch (_) {
      windows = {TimeWindow.fromId(legacyTimeWindow)};
    }
    return WindowSelection(windows: windows);
  }
}

class CustomTimeRange {
  const CustomTimeRange({
    required this.startMinutes,
    required this.endMinutes,
  });

  /// Minutes since midnight (0..1439). [endMinutes] may be < [startMinutes]
  /// for a window that wraps past midnight (e.g. 22:00–02:00).
  final int startMinutes;
  final int endMinutes;

  TimeOfDay get start =>
      TimeOfDay(hour: startMinutes ~/ 60, minute: startMinutes % 60);
  TimeOfDay get end =>
      TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);

  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}
