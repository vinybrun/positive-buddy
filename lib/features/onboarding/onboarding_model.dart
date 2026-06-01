import 'dart:convert';
import 'package:flutter/material.dart';

import '../../theme/buddy.dart';

/// Tone preference. Drives copy selection during reminders + acks.
enum TonePreference {
  direct('direct', 'Just the facts', 'Plain, no fluff. "Time for water."'),
  empathetic(
      'empathetic',
      'Warm & encouraging',
      'Buddy energy. "Hey friend — quick check-in?"'),
  celebratory(
      'celebratory',
      'Hype me up',
      'Energetic, big wins. "LET\'S GOOO 🎉"'),
  mixed(
      'mixed',
      'Mix it up',
      'Varies day to day. Default if you\'re not sure.'),
  auto(
      'auto',
      'Figure it out',
      'I\'ll watch which tone you respond to and lean that way.');

  const TonePreference(this.id, this.label, this.subtitle);
  final String id;
  final String label;
  final String subtitle;

  static TonePreference fromId(String id) =>
      TonePreference.values.firstWhere((t) => t.id == id,
          orElse: () => TonePreference.mixed);
}

/// Captured during onboarding, persisted to `user_profile`. v11: the
/// goals + first-habit arrays moved to the GoalCreatorPage hand-off, so
/// onboarding only owns buddy + tone + budget + waking window now.
class OnboardingData {
  OnboardingData({
    this.buddy,
    this.tone = TonePreference.mixed,
    this.dailyBudget = 4,
    TimeOfDay? wakeStart,
    TimeOfDay? wakeEnd,
  })  : wakeStart = wakeStart ?? const TimeOfDay(hour: 7, minute: 0),
        wakeEnd = wakeEnd ?? const TimeOfDay(hour: 22, minute: 0);

  BuddyId? buddy;
  TonePreference tone;
  int dailyBudget;
  TimeOfDay wakeStart;
  TimeOfDay wakeEnd;

  String wakingWindowJson() {
    final json = {
      'start': '${wakeStart.hour.toString().padLeft(2, '0')}:${wakeStart.minute.toString().padLeft(2, '0')}',
      'end': '${wakeEnd.hour.toString().padLeft(2, '0')}:${wakeEnd.minute.toString().padLeft(2, '0')}',
    };
    return jsonEncode(json);
  }

  /// Parse the inverse of [wakingWindowJson]. Returns null when the input
  /// doesn't match the expected shape — caller should fall back to defaults.
  static ({TimeOfDay start, TimeOfDay end})? parseWakingWindow(String s) {
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final start = _parseHm(m['start'] as String?);
      final end = _parseHm(m['end'] as String?);
      if (start == null || end == null) return null;
      return (start: start, end: end);
    } catch (_) {
      return null;
    }
  }

  static TimeOfDay? _parseHm(String? s) {
    if (s == null) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }
}
