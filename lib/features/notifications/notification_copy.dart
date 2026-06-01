/// Pure copy + parsing helpers for habit notifications. Kept free of Flutter,
/// drift, and the notification plugin so they're unit-testable without a
/// running device.
library;

import '../../personalization/buddy_voice.dart';
import '../../theme/buddy.dart';

const String responseYes = 'yes';
const String responseNotYet = 'not_yet';

/// A simplified view of a habit's reminder slot — only the fields the copy
/// engine needs. Decouples the pure logic from drift's generated types.
class SlotView {
  const SlotView({
    required this.timeOfDay,
    this.enabled = true,
    this.weekdayMask = 0x7F,
    this.kind = 'time',
  });

  /// Minutes since midnight (0..1439).
  final int timeOfDay;
  final bool enabled;

  /// Bitmask of weekdays this slot fires on. Bit 0 = Monday, bit 6 = Sunday.
  /// Default 0x7F means all 7 days.
  final int weekdayMask;

  /// 'time' (user-specified daily reminder) | 'priming' (app-chosen
  /// frequency-habit nudge — eligible for the Phase 3 time-shift rule).
  final String kind;
}

/// A habit + its slots — the input shape to [computeOccurrences].
class HabitWithSlotViews {
  const HabitWithSlotViews({
    required this.id,
    required this.name,
    required this.category,
    required this.slots,
    this.timeWindow = 'anytime',
    this.active = true,
  });

  final String id;
  final String name;
  final String category;
  final String timeWindow;
  final bool active;
  final List<SlotView> slots;
}

/// One scheduled reminder occurrence. [computeOccurrences] emits a sorted
/// list of these for the rolling-window scheduler to register with the OS.
class Occurrence {
  const Occurrence({
    required this.habitId,
    required this.habitName,
    required this.category,
    required this.when,
    this.slotKind = 'time',
  });

  final String habitId;
  final String habitName;
  final String category;
  final DateTime when;
  /// Phase 3: 'time' = user-specified daily reminder (do not move);
  /// 'priming' = app-chosen frequency nudge (engine may shift to a better
  /// hour based on response/open density).
  final String slotKind;

  Occurrence copyWith({DateTime? when, String? slotKind}) => Occurrence(
        habitId: habitId,
        habitName: habitName,
        category: category,
        when: when ?? this.when,
        slotKind: slotKind ?? this.slotKind,
      );
}

/// Compute the next [daysAhead] days of reminder occurrences across all
/// active habits, sorted by time, capped at [maxCount]. Pure — testable
/// without a device. The scheduler turns these into OS-level alarms.
List<Occurrence> computeOccurrences({
  required List<HabitWithSlotViews> habits,
  required DateTime now,
  int daysAhead = 7,
  int maxCount = 50,
}) {
  final out = <Occurrence>[];
  for (final h in habits) {
    if (!h.active) continue;
    for (final slot in h.slots) {
      if (!slot.enabled) continue;
      final hour = slot.timeOfDay ~/ 60;
      final minute = slot.timeOfDay % 60;
      for (var d = 0; d < daysAhead; d++) {
        final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));
        // DateTime.weekday is 1 (Mon) .. 7 (Sun). Map to bits 0..6.
        final bit = 1 << (day.weekday - 1);
        if ((slot.weekdayMask & bit) == 0) continue;
        final when = DateTime(day.year, day.month, day.day, hour, minute);
        if (!when.isAfter(now)) continue;
        out.add(Occurrence(
          habitId: h.id,
          habitName: h.name,
          category: h.category,
          when: when,
          slotKind: slot.kind,
        ));
      }
    }
  }
  out.sort((a, b) => a.when.compareTo(b.when));
  if (out.length > maxCount) {
    return out.sublist(0, maxCount);
  }
  return out;
}

/// Maps a notification action id to a logged response, or null if the action
/// is unrecognized (e.g. the user tapped the body of the notification rather
/// than an action button). Callers must NOT log anything when this returns
/// null — body taps should just open the app.
String? responseFromAction(String? actionId) {
  switch (actionId) {
    case 'RESPOND_YES':
      return responseYes;
    case 'RESPOND_NOT_YET':
      return responseNotYet;
    default:
      return null;
  }
}

/// One acknowledgment line — a title and a body. Both rotate based on `now`
/// so the buddy doesn't feel like a robot repeating itself.
class AckCopy {
  const AckCopy(this.title, this.body);
  final String title;
  final String body;
}

/// Compose the warm follow-up that replaces the notification after the user
/// responds. Pure function — no IO, deterministic for a given `now`.
///
/// [timeWindowId] biases the band phrasing for tomorrow's reminder when the
/// habit has an explicit optimal window (e.g. "Vitamin D" → morning,
/// "Floss" → before bed). Falls back to the band derived from the slot
/// hour when null or 'anytime'.
AckCopy composeAcknowledgment({
  required String response,
  required List<SlotView> slots,
  required DateTime now,
  String? timeWindowId,
  BuddyId? buddy,
}) {
  if (response == responseYes) {
    final pool = yesAcksFor(buddy);
    final pick = pool[now.microsecondsSinceEpoch.abs() % pool.length];
    return AckCopy(pick.$1, pick.$2);
  }

  // For 'not_yet' (and anything else we treat as a soft no), reassure +
  // promise the next reminder.
  final earliest = _earliestUpcomingSlot(slots, now);

  if (earliest == null) {
    final softNo = softNoFor(buddy);
    final body = softNo == null
        ? "No fixed time — I'll catch you next time you're around."
        : softNo[now.microsecondsSinceEpoch.abs() % softNo.length];
    return AckCopy('Got you 🙂', body);
  }

  final today = DateTime(now.year, now.month, now.day);
  final earliestDay = DateTime(earliest.year, earliest.month, earliest.day);
  final daysAhead = earliestDay.difference(today).inDays;
  // Prefer the habit's stated optimal window when it gives a usable phrase;
  // fall back to the band derived from the next slot's hour.
  final bandFromWindow = _bandFromWindowId(timeWindowId);
  final band = bandFromWindow ?? timeBand(earliest.hour);

  if (daysAhead == 0) {
    // Prefer the buddy's soft-no flavor when present; the band-aware
    // default kicks in only when no buddy is selected.
    final softNo = softNoFor(buddy);
    if (softNo != null) {
      final flavor = softNo[now.microsecondsSinceEpoch.abs() % softNo.length];
      return AckCopy('No stress', "$flavor Back this $band.");
    }
    final phrases = [
      "Still time today — I'll nudge you again this $band 💪",
      "No stress, I've got you. Circling back this $band 🙂",
      "All good. Back at it this $band.",
    ];
    return AckCopy(
      'No stress',
      phrases[now.microsecondsSinceEpoch.abs() % phrases.length],
    );
  }

  final emoji = bandEmoji(band);
  if (daysAhead == 1) {
    return AckCopy('Got you', "I'll remind you tomorrow $band $emoji");
  }
  return AckCopy('Got you', "I'll catch you in a couple days, $band $emoji");
}

/// Convert a TimeWindow id (kept as a plain string here to avoid pulling
/// `time_windows.dart` into the pure-copy library) into a band phrase.
/// Returns null for `anytime`/`with_meals`/unknown — caller should fall
/// back to the slot-hour band.
String? _bandFromWindowId(String? id) {
  return switch (id) {
    'morning' => 'morning',
    'afternoon' => 'afternoon',
    'evening' => 'evening',
    'before_bed' => 'evening',
    _ => null,
  };
}

/// The next enabled slot strictly after `now`. Slots without `enabled=true`
/// are skipped. Slots ≤ 1 minute from now are treated as "the one we just
/// responded to" and skipped to tomorrow.
DateTime? _earliestUpcomingSlot(List<SlotView> slots, DateTime now) {
  DateTime? best;
  for (final s in slots) {
    if (!s.enabled) continue;
    final h = s.timeOfDay ~/ 60;
    final m = s.timeOfDay % 60;
    var candidate = DateTime(now.year, now.month, now.day, h, m);
    if (!candidate.isAfter(now.add(const Duration(minutes: 1)))) {
      candidate = candidate.add(const Duration(days: 1));
    }
    if (best == null || candidate.isBefore(best)) best = candidate;
  }
  return best;
}

String timeBand(int hour) {
  if (hour < 5) return 'late night';
  if (hour < 12) return 'morning';
  if (hour < 17) return 'afternoon';
  if (hour < 21) return 'evening';
  return 'night';
}

String bandEmoji(String band) {
  return switch (band) {
    'morning' => '🌅',
    'afternoon' => '☀️',
    'evening' => '🌙',
    _ => '🌙',
  };
}
