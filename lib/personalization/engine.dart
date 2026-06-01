/// Pure-Dart personalization engine. No Flutter, no drift, no notification
/// plugin imports — everything in here is unit-testable with `flutter test`
/// running on the host VM.
///
/// The engine takes a [PersonalizationInput] (profile + planned occurrences +
/// recent logs + clock) and emits a [PersonalizationPlan] — the *filtered*
/// list of occurrences plus the tone key to use for each. The orchestrator
/// (rolling-window scheduler) applies the plan; the engine itself does no IO.
library;

import '../features/notifications/notification_copy.dart' show Occurrence;

/// Captured user preferences. Mirrors the columns on `user_profile` but in
/// a pure-Dart shape so the engine can be tested without drift.
class ProfileInput {
  const ProfileInput({
    required this.tonePreference,
    required this.dailyNotifBudget,
    required this.wakingStartHour,
    required this.wakingStartMinute,
    required this.wakingEndHour,
    required this.wakingEndMinute,
  });

  /// 'direct' | 'empathetic' | 'celebratory' | 'mixed' | 'auto'
  final String tonePreference;
  final int dailyNotifBudget;
  final int wakingStartHour;
  final int wakingStartMinute;
  final int wakingEndHour;
  final int wakingEndMinute;

  static const fallback = ProfileInput(
    tonePreference: 'mixed',
    dailyNotifBudget: 4,
    wakingStartHour: 7,
    wakingStartMinute: 0,
    wakingEndHour: 22,
    wakingEndMinute: 0,
  );

  bool insideWakingWindow(DateTime when) {
    final start = when.hour * 60 + when.minute >= wakingStartHour * 60 + wakingStartMinute;
    final end = when.hour * 60 + when.minute <= wakingEndHour * 60 + wakingEndMinute;
    return start && end;
  }
}

/// One scheduled occurrence as it leaves the engine — same as [Occurrence]
/// but with the engine's chosen tone key + a kept/dropped marker (we keep
/// the dropped ones in the plan so the scheduler can cancel them).
class PlannedOccurrence {
  const PlannedOccurrence({
    required this.occurrence,
    required this.toneKey,
    this.dropped = false,
    this.reason,
  });

  final Occurrence occurrence;
  final String toneKey;
  final bool dropped;
  final String? reason;

  PlannedOccurrence copyWith({
    Occurrence? occurrence,
    String? toneKey,
    bool? dropped,
    String? reason,
  }) =>
      PlannedOccurrence(
        occurrence: occurrence ?? this.occurrence,
        toneKey: toneKey ?? this.toneKey,
        dropped: dropped ?? this.dropped,
        reason: reason ?? this.reason,
      );
}

/// One observed user-engagement event the engine can learn from.
/// Mirrors a `profile_signals` row but stays pure Dart.
class EngagementSignal {
  const EngagementSignal({
    required this.kind,
    required this.ts,
    this.response,
  });

  /// 'response' | 'dismissal' | 'manual_edit' | 'app_open'
  final String kind;
  final DateTime ts;

  /// For 'response' signals: 'yes' | 'not_yet' | etc. (mirrors
  /// notification_log.response).
  final String? response;

  // Kind constants kept on the data class so the engine can reference
  // them without an extra import; the SignalRepository mirrors these.
  static const String kindResponse = 'response';
  static const String kindDismissal = 'dismissal';
  static const String kindManualEdit = 'manual_edit';
  static const String kindAppOpen = 'app_open';
}

/// Inputs the engine needs. Kept as a struct so adding new signals (recent
/// logs, adaptive_state) over time doesn't churn every rule's signature.
class PersonalizationInput {
  const PersonalizationInput({
    required this.profile,
    required this.candidates,
    required this.now,
    this.signals = const [],
    this.engagementState = EngagementState.active,
  });

  final ProfileInput profile;
  final List<Occurrence> candidates;
  final DateTime now;
  /// Phase 3/4: recent app_open + response + dismissal events. Engine
  /// rules read this to figure out when the user is around and how to
  /// talk to them. Empty list = cold start; rules fall back to defaults.
  final List<EngagementSignal> signals;
  /// Phase 4: classified engagement state. The adaptive-tone rule uses
  /// it to switch tone packs (warm "missed you" copy when the user has
  /// dropped off, etc.).
  final EngagementState engagementState;
}

/// Phase 4 classifier output.
enum EngagementState {
  /// Responded to a notification within the last ~3 days.
  active,

  /// Hasn't responded recently but has opened the app — still here,
  /// just dropping out of the loop. Tone shifts to gentle check-in.
  cooling,

  /// No response AND no app_open for a week+. Tone shifts to warm
  /// "missed you," no guilt.
  dropped,

  /// Repeatedly hits the habit before being asked. The buddy ackowledges
  /// they've outgrown the prompt — a graduation hint.
  superseded,
}

class PersonalizationPlan {
  const PersonalizationPlan(this.occurrences);
  final List<PlannedOccurrence> occurrences;

  /// Convenience getter: just the kept ones, in time order. The scheduler
  /// loop uses this to figure out which alarms to register with the OS.
  List<PlannedOccurrence> get keepers =>
      occurrences.where((o) => !o.dropped).toList();
}

/// Rule signature. Each rule sees the current plan-in-progress and returns
/// a new plan. Rules are independently testable.
typedef PersonalizationRule = PersonalizationPlan Function(
  PersonalizationPlan plan,
  PersonalizationInput input,
);

/// Orchestrator. Runs registered rules in order. Always starts from a "keep
/// everything, default tone" plan.
class PersonalizationEngine {
  PersonalizationEngine(this.rules);

  final List<PersonalizationRule> rules;

  PersonalizationPlan plan(PersonalizationInput input) {
    var p = PersonalizationPlan(
      input.candidates
          .map((o) => PlannedOccurrence(occurrence: o, toneKey: _defaultTone(input.profile)))
          .toList(),
    );
    for (final rule in rules) {
      p = rule(p, input);
    }
    return p;
  }

  String _defaultTone(ProfileInput profile) {
    switch (profile.tonePreference) {
      case 'direct':
        return 'direct';
      case 'celebratory':
        return 'celebratory';
      case 'empathetic':
        return 'empathetic';
      case 'auto':
        // v1: auto without signal data behaves like 'mixed'. Phase 7 deepens.
        return 'mixed';
      default:
        return 'mixed';
    }
  }
}

/// Default rule set. The engine is composable — tests can swap rules in/out.
/// Order matters: shift first (so quiet-hours sees the final times), then
/// drop out-of-window, then cap, then adapt tone.
List<PersonalizationRule> defaultRules() => [
      smartTimeShiftRule,
      quietHoursRule,
      cadenceRule,
      adaptiveToneRule,
    ];

/// Drop occurrences that fall outside the user's waking window. The user
/// said "I'm asleep from 22:30 to 07:00 — don't ping me there." → trust them.
PersonalizationPlan quietHoursRule(
    PersonalizationPlan plan, PersonalizationInput input) {
  final next = <PlannedOccurrence>[];
  for (final p in plan.occurrences) {
    if (!input.profile.insideWakingWindow(p.occurrence.when)) {
      next.add(p.copyWith(dropped: true, reason: 'outside waking window'));
    } else {
      next.add(p);
    }
  }
  return PersonalizationPlan(next);
}

/// Cap total kept occurrences per local calendar day to the user's
/// `dailyNotifBudget`. Drops the latest ones in the day first — we'd
/// rather miss tonight's wind-down than this morning's meds.
PersonalizationPlan cadenceRule(
    PersonalizationPlan plan, PersonalizationInput input) {
  // Group keepers by local calendar day.
  final byDay = <String, List<int>>{}; // day -> indices in plan.occurrences
  for (var i = 0; i < plan.occurrences.length; i++) {
    final p = plan.occurrences[i];
    if (p.dropped) continue;
    final w = p.occurrence.when;
    final key = '${w.year}-${w.month}-${w.day}';
    (byDay[key] ??= []).add(i);
  }

  final next = [...plan.occurrences];
  final budget = input.profile.dailyNotifBudget;
  for (final entry in byDay.entries) {
    final indices = entry.value;
    if (indices.length <= budget) continue;
    // Sort indices by occurrence time ascending. Keep the first [budget],
    // drop the rest with a reason marker.
    indices.sort((a, b) => next[a]
        .occurrence
        .when
        .compareTo(next[b].occurrence.when));
    for (var k = budget; k < indices.length; k++) {
      final i = indices[k];
      next[i] = next[i].copyWith(
        dropped: true,
        reason: 'over daily budget ($budget)',
      );
    }
  }
  return PersonalizationPlan(next);
}

// ----------------------------------------------------------------------------
// Phase 3 — smart time shift. Moves "priming" (freq-habit) occurrences
// to the hour where the user is statistically most likely to engage,
// based on app_open + yes-response history. Time-based occurrences are
// never shifted — the user picked those times deliberately.

PersonalizationPlan smartTimeShiftRule(
    PersonalizationPlan plan, PersonalizationInput input) {
  if (input.signals.isEmpty) return plan;
  // Build a per-hour density score over the last 14 days. Both app_open
  // and yes-response count, with yes-response weighted higher (responding
  // is a stronger signal of "I'm reachable" than just opening the app).
  const lookback = Duration(days: 14);
  final cutoff = input.now.subtract(lookback);
  final scores = List<double>.filled(24, 0);
  for (final s in input.signals) {
    if (s.ts.isBefore(cutoff)) continue;
    final h = s.ts.toLocal().hour;
    if (s.kind == EngagementSignal.kindAppOpen) {
      scores[h] += 1.0;
    } else if (s.kind == EngagementSignal.kindResponse &&
        s.response == 'yes') {
      scores[h] += 3.0;
    }
  }
  if (scores.every((v) => v == 0)) return plan;
  // Find the highest-density hour inside the waking window.
  int? bestHour;
  double bestScore = -1;
  for (var h = 0; h < 24; h++) {
    final inWindow =
        h >= input.profile.wakingStartHour &&
            h <= input.profile.wakingEndHour;
    if (!inWindow) continue;
    if (scores[h] > bestScore) {
      bestScore = scores[h];
      bestHour = h;
    }
  }
  if (bestHour == null) return plan;
  final next = <PlannedOccurrence>[];
  for (final p in plan.occurrences) {
    if (p.dropped || p.occurrence.slotKind != 'priming') {
      next.add(p);
      continue;
    }
    final w = p.occurrence.when;
    final shifted = DateTime(w.year, w.month, w.day, bestHour, 0);
    next.add(p.copyWith(
      occurrence: p.occurrence.copyWith(when: shifted),
      reason: 'shifted to user\'s active hour ($bestHour:00)',
    ));
  }
  return PersonalizationPlan(next);
}

// ----------------------------------------------------------------------------
// Phase 4 — adaptive tone. Overlays an engagement-state-driven tone on
// top of the profile's base preference. Active users get the buddy's
// normal voice; cooling/dropped users get gentler check-ins; superseded
// users get "you've clearly got this" celebratory copy that feeds into
// Phase 5's graduation prompt.

PersonalizationPlan adaptiveToneRule(
    PersonalizationPlan plan, PersonalizationInput input) {
  final adaptive = switch (input.engagementState) {
    EngagementState.active => null,
    EngagementState.cooling => 'cooling',
    EngagementState.dropped => 'dropped',
    EngagementState.superseded => 'superseded',
  };
  if (adaptive == null) return plan;
  return PersonalizationPlan([
    for (final p in plan.occurrences)
      p.copyWith(toneKey: adaptive),
  ]);
}

/// Pure classifier — exposed for tests and used by the reconcile path
/// to fill in [PersonalizationInput.engagementState].
EngagementState classifyEngagement({
  required List<EngagementSignal> signals,
  required DateTime now,
}) {
  if (signals.isEmpty) return EngagementState.active;
  final lastResponse = signals
      .where((s) => s.kind == EngagementSignal.kindResponse)
      .fold<DateTime?>(null,
          (acc, s) => acc == null || s.ts.isAfter(acc) ? s.ts : acc);
  final lastOpen = signals
      .where((s) => s.kind == EngagementSignal.kindAppOpen)
      .fold<DateTime?>(null,
          (acc, s) => acc == null || s.ts.isAfter(acc) ? s.ts : acc);

  // Superseded: ≥5 manual_done responses in the last 14 days with NO
  // "not_yet" or "missed" in the same window. The user's living the
  // habit unprompted.
  const lookback = Duration(days: 14);
  final cutoff = now.subtract(lookback);
  final recent = signals.where((s) => s.ts.isAfter(cutoff)).toList();
  final manualDone = recent
      .where((s) =>
          s.kind == EngagementSignal.kindResponse &&
          s.response == 'manual_done')
      .length;
  final lapses = recent.where((s) =>
      s.kind == EngagementSignal.kindResponse &&
      (s.response == 'not_yet' || s.response == 'missed')).length;
  if (manualDone >= 5 && lapses == 0) return EngagementState.superseded;

  if (lastResponse != null &&
      now.difference(lastResponse).inDays <= 3) {
    return EngagementState.active;
  }
  final daysSinceOpen =
      lastOpen == null ? 9999 : now.difference(lastOpen).inDays;
  if (daysSinceOpen >= 7) return EngagementState.dropped;
  return EngagementState.cooling;
}

