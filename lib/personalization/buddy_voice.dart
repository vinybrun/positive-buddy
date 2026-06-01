/// Per-buddy voice pools. Each buddy re-skins the existing acknowledgment
/// copy with phrases that match its personality — same surfaces, same
/// number of variants, different *flavor*. No new screens, no new
/// notifications.
///
/// Kept Flutter-free so it's drop-in for the pure `notification_copy.dart`
/// pipeline.
library;

import '../theme/buddy.dart';

class _Ack {
  const _Ack(this.title, this.body);
  final String title;
  final String body;
}

/// "Yes, I did it" acknowledgments. ~5 variants per buddy keep the buddy
/// from feeling like a robot without bloating the phrase library.
const Map<BuddyId, List<_Ack>> _yesByBuddy = {
  BuddyId.fox: [
    _Ack('Slick.', "That's another one in the bag."),
    _Ack('Sharp.', "Good move. See you at the next one."),
    _Ack('Nicely done.', "Quietly stacking wins. I like it."),
    _Ack('Smart.', "Logged. Onward."),
    _Ack('Crafty.', "That's how it's done."),
  ],
  BuddyId.cat: [
    _Ack('Mm.', "Acceptable."),
    _Ack('Adequate.', "Carry on."),
    _Ack('Hm.', "Fine. Logged."),
    _Ack('Well done.', "I'll allow it."),
    _Ack('Noted.', "Yes. Good."),
  ],
  BuddyId.dog: [
    _Ack('YES!', "So proud of you. Let's keep going!"),
    _Ack('Good job!', "Knew you could do it!"),
    _Ack('Best!', "That's my person."),
    _Ack('Yes yes yes!', "Logged it. Onto the next!"),
    _Ack('Amazing!', "Look at you go."),
  ],
  BuddyId.butterfly: [
    _Ack('Lovely.', "Onward."),
    _Ack('Beautiful.', "One more, gently done."),
    _Ack('Sweet.', "Logged. Float on."),
    _Ack('Gentle win.', "I'll catch you at the next one."),
    _Ack('Light work.', "That's the rhythm."),
  ],
  BuddyId.snake: [
    _Ack('Done.', "Steady wins."),
    _Ack('Coiled progress.', "Logged."),
    _Ack('Smooth.', "Slow and sure."),
    _Ack('Marked.', "One more loop closed."),
    _Ack('Quiet win.', "Onward, unhurried."),
  ],
  BuddyId.bird: [
    _Ack('Flight time.', "Logged. Onward."),
    _Ack('Soaring.', "Nice work."),
    _Ack('Caught it.', "Stacking wins from above."),
    _Ack('Crisp.', "That one's yours."),
    _Ack('Skyward.', "Quietly climbing."),
  ],
};

/// Fallback pool when no buddy is selected (cold-start, pre-onboarding).
/// Kept close to v1's original phrasing.
const List<_Ack> _yesDefault = [
  _Ack('Nice 🎉', "That's a win. Catch you next time."),
  _Ack('Solid 💪', 'Logged. Proud of you.'),
  _Ack('Done 🌟', 'Keep that rhythm going.'),
  _Ack('Yes!', "I'll catch you at the next one."),
];

/// Soft-no acknowledgments. Each is just one short line — the
/// notification_copy "Got you" path will pair it with a next-slot promise.
const Map<BuddyId, List<String>> _softNoByBuddy = {
  BuddyId.fox: [
    "All good. We'll outsmart it next time.",
    "Smart of you not to force it.",
    "Pacing yourself. I respect that.",
  ],
  BuddyId.cat: [
    "Fine. Try later.",
    "Whatever you say.",
    "We'll see about that.",
  ],
  BuddyId.dog: [
    "It's okay! We'll get it next time!",
    "No worries — you've got this!",
    "All good, friend.",
  ],
  BuddyId.butterfly: [
    "Gently does it. Later, then.",
    "No pressure. I'll be back.",
    "All in good time.",
  ],
  BuddyId.snake: [
    "Patience. We continue.",
    "No rush. Loop back later.",
    "Coiled, waiting.",
  ],
  BuddyId.bird: [
    "Wind's wrong. We'll try again.",
    "Resting on the branch. Back later.",
    "Easy glide. Catch you next loop.",
  ],
};

/// Look up the yes-ack pool for a buddy. Returns the v1 default pool when
/// no buddy is set, or when the buddy has no dedicated pool yet (e.g. v12
/// bird buddy whose copy is still being authored). The fallback keeps the
/// pool size invariant so notification builder never gets an empty list.
List<(String, String)> yesAcksFor(BuddyId? buddy) {
  final pool = buddy == null ? _yesDefault : (_yesByBuddy[buddy] ?? _yesDefault);
  return [for (final a in pool) (a.title, a.body)];
}

/// Look up the soft-no flavor line for a buddy. Returns null for a null
/// buddy (caller should fall back to v1's "No stress" lines).
List<String>? softNoFor(BuddyId? buddy) {
  if (buddy == null) return null;
  return _softNoByBuddy[buddy];
}

// ---------------------------------------------------------------------------
// Phase 4 — re-engagement copy. When the engine classifies the user as
// cooling / dropped / superseded, the notification builder pulls from
// these pools instead of the per-habit defaults. The goal is empathy:
// never guilt-trippy, just warm + honest. A touch of cheesy is allowed.

/// 'cooling' tone — user is missing some pings but still around. Gentle
/// check-in, no judgment.
const Map<BuddyId, List<_Ack>> _coolingByBuddy = {
  BuddyId.fox: [
    _Ack("Hey, still here?",
        "Drop me a yes when you can. No pressure on the rhythm."),
    _Ack("Quick nudge.", "I noticed you've been busy. Want a hand getting back into it?"),
  ],
  BuddyId.cat: [
    _Ack("Stretching, hm?", "Pick it up when you're ready."),
    _Ack("It's been a minute.", "I'm here when you are."),
  ],
  BuddyId.dog: [
    _Ack("Hey friend!",
        "I miss you a little. Whenever you're ready, I'm right here."),
    _Ack("Tail wags!", "Even a small step today would feel great. Up to you."),
  ],
  BuddyId.butterfly: [
    _Ack("Softly checking in.",
        "Life happens. I'll be here when the rhythm comes back."),
    _Ack("Drifting by.", "No pressure — just saying hi."),
  ],
  BuddyId.snake: [
    _Ack("Still coiled, still here.",
        "Whenever you uncoil, I'm with you."),
    _Ack("Slow rhythm.", "We pick it up when you're ready."),
  ],
};

/// 'dropped' tone — user hasn't been around in 7+ days. Warm
/// "missed you" with zero guilt. The point is to bring them back
/// without the app feeling needy.
const Map<BuddyId, List<_Ack>> _droppedByBuddy = {
  BuddyId.fox: [
    _Ack("Long time.",
        "Not gonna lecture. Just letting you know I'm still here if you want to start fresh."),
  ],
  BuddyId.cat: [
    _Ack("Oh — you again.",
        "Pretending I didn't notice you were gone. Want to try a small thing?"),
  ],
  BuddyId.dog: [
    _Ack("You're back!",
        "No questions. So glad to see you. Even one small win today would be amazing."),
  ],
  BuddyId.butterfly: [
    _Ack("Welcome back.",
        "Life pulled you elsewhere — that's okay. Want to gently restart?"),
  ],
  BuddyId.snake: [
    _Ack("You returned.",
        "Time bends. We can begin again, calmly. One small thing."),
  ],
};

/// 'superseded' tone — user has clearly mastered this habit and is
/// doing it unprompted. The buddy gives them the win and hints at
/// graduating to a new goal.
const Map<BuddyId, List<_Ack>> _supersededByBuddy = {
  BuddyId.fox: [
    _Ack("You've outsmarted me.",
        "This one's basically yours now. Want to set a new goal?"),
  ],
  BuddyId.cat: [
    _Ack("Hmph. Impressive.",
        "I don't think you need me on this one anymore."),
  ],
  BuddyId.dog: [
    _Ack("LOOK AT YOU!",
        "You're crushing this without my pings. I'm so proud. Ready for the next goal?"),
  ],
  BuddyId.butterfly: [
    _Ack("You've found the rhythm.",
        "This one flies on its own now. Pick the next thing when you're ready."),
  ],
  BuddyId.snake: [
    _Ack("Mastered, quietly.",
        "You've made this part of you. Time to coil around the next thing?"),
  ],
};

const List<_Ack> _coolingDefault = [
  _Ack("Hey, still here?", "Drop me a yes when you can. No pressure."),
];
const List<_Ack> _droppedDefault = [
  _Ack("Long time.",
      "Not gonna lecture. I'm here if you want to start fresh."),
];
const List<_Ack> _supersededDefault = [
  _Ack("Look at that.",
      "You don't really need me anymore — ready for the next goal?"),
];

/// Look up the re-engagement title+body for a buddy in a given adaptive
/// tone. Returns a `(title, body)` record the notification builder can
/// drop straight into the channel template. Null buddy → generic default.
(String title, String body) adaptiveAckFor(
    BuddyId? buddy, String toneKey, DateTime now) {
  List<_Ack> pool;
  switch (toneKey) {
    case 'cooling':
      pool = buddy == null
          ? _coolingDefault
          : (_coolingByBuddy[buddy] ?? _coolingDefault);
    case 'dropped':
      pool = buddy == null
          ? _droppedDefault
          : (_droppedByBuddy[buddy] ?? _droppedDefault);
    case 'superseded':
      pool = buddy == null
          ? _supersededDefault
          : (_supersededByBuddy[buddy] ?? _supersededDefault);
    default:
      pool = _coolingDefault;
  }
  final pick = pool[now.microsecondsSinceEpoch.abs() % pool.length];
  return (pick.title, pick.body);
}

/// Whether [toneKey] is one of the Phase 4 adaptive tones (vs a base
/// tone like 'mixed' / 'direct' / 'celebratory'). The notification
/// builder uses this to decide whether to override the per-habit copy
/// with [adaptiveAckFor].
bool isAdaptiveTone(String toneKey) =>
    toneKey == 'cooling' ||
    toneKey == 'dropped' ||
    toneKey == 'superseded';

/// The single-line Today-page greeting under the title. Reflects the
/// buddy's personality + the user's pending-habit count. Short — fits one
/// line on the smallest reasonable device.
String greetingFor(BuddyId? buddy, int pending) {
  if (buddy == null) {
    if (pending == 0) return "Nothing on the list right now.";
    return "$pending left for today.";
  }
  final name = buddy.label;
  if (pending == 0) {
    return switch (buddy) {
      BuddyId.fox => "$name's lounging. Nothing left today.",
      BuddyId.cat => "$name's napping. You're free.",
      BuddyId.dog => "$name's done for the day. Good work!",
      BuddyId.butterfly => "$name's drifting. Nothing pending.",
      BuddyId.snake => "$name's still. Nothing to do.",
      BuddyId.bird => "$name's perched. Nothing left today.",
    };
  }
  final n = pending;
  final plural = n == 1 ? '' : 's';
  return switch (buddy) {
    BuddyId.fox => "$name's here. $n thing$plural left.",
    BuddyId.cat => "$name's watching. $n thing$plural to do.",
    BuddyId.dog => "$name's ready! $n thing$plural to go.",
    BuddyId.butterfly => "$name's hovering. $n thing$plural pending.",
    BuddyId.snake => "$name's curled up. $n thing$plural ahead.",
    BuddyId.bird => "$name's circling. $n thing$plural to do.",
  };
}
