/// Animal companion the user picks during onboarding. Drives the default
/// theme palette, illustrations, launcher icon, and per-buddy copy variants.
///
/// String ids are what's persisted to `user_profile.selectedBuddy`.
enum BuddyId {
  // Display name (4–5 chars) is the buddy's *character* name. The id
  // ('fox', 'cat', …) stays the type slug used for asset lookups.
  fox('fox', 'Russ'),
  cat('cat', 'Mira'),
  dog('dog', 'Bento'),
  butterfly('butterfly', 'Lumi'),
  snake('snake', 'Sage'),
  // v12: third evolving species (snake + fox + bird share the 5-stage
  // evolution art). Other buddies stay static for now.
  bird('bird', 'Skye');

  const BuddyId(this.id, this.label);
  final String id;
  final String label;

  /// True if this species has the 5-stage evolution sprite set bundled.
  /// The Today header + buddy picker check this before swapping in a
  /// stage-aware avatar; static buddies fall back to emotion poses.
  bool get hasStages =>
      this == BuddyId.fox || this == BuddyId.snake || this == BuddyId.bird;

  static BuddyId? fromId(String? id) {
    if (id == null) return null;
    for (final b in BuddyId.values) {
      if (b.id == id) return b;
    }
    return null;
  }
}

/// 5-stage evolution arc per species. Stage 0 is the "just picked" form
/// the user sees in the buddy picker; later stages unlock as the
/// [BuddyScoringEngine] credits days into the per-buddy total.
///
/// We expose the stage-name string per (species, stage) so the Today
/// header can show "Sage • Cobra" without leaking the next stage's name.
class BuddyStage {
  const BuddyStage._();

  /// Total number of stages including the initial one. 5 means stages
  /// 0..4 are valid.
  static const int count = 5;

  /// Stage-name labels (English). Indexed by species id.
  static const Map<String, List<String>> _stageNames = {
    'snake': ['Egg', 'Hatchling', 'Cobra', 'Great Serpent', 'Leviathan'],
    'fox': ['Cub', 'Young Fox', 'Red Fox', 'Snow Fox', 'Ninetails'],
    'bird': ['Chick', 'Fledgling', 'Macaw', 'Phoenix', 'Forest Spirit'],
  };

  /// Returns the English name for a given (species, stage). If the
  /// species has no stage data (cat/dog/butterfly), returns null.
  static String? nameFor(BuddyId buddy, int stage) {
    final names = _stageNames[buddy.id];
    if (names == null) return null;
    final clamped = stage.clamp(0, names.length - 1);
    return names[clamped];
  }
}
