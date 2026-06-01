import 'buddy.dart';

/// Pose the buddy is shown in. Each pose is a distinct PNG asset; the
/// caller picks one based on what the screen is communicating (default
/// greeting, post-completion celebration, quiet-hours / no-reminders,
/// empty state).
enum BuddyPose {
  idle('idle'),
  cheer('cheer'),
  sleepy('sleepy'),
  curious('curious');

  const BuddyPose(this.id);
  final String id;
}

/// Resolves a (buddy, pose) pair to its bundled asset path. Files are
/// generated as placeholders during Phase 3; the artist will replace
/// them in-place without code changes.
class BuddyAsset {
  static String forPose(BuddyId buddy, BuddyPose pose) =>
      'assets/buddies/${buddy.id}/${pose.id}.png';

  /// 512×512 PNG used as the notification large icon and as the source
  /// for the launcher icon foreground (Phase 4 resizes to 432×432).
  static String iconFor(BuddyId buddy) =>
      'assets/buddies/icons/${buddy.id}.png';

  /// 432×432 PNG specifically sized for the launcher adaptive icon
  /// foreground layer. Sits beside [iconFor] so the build pipeline
  /// (Phase 4) doesn't have to crop on the fly.
  static String launcherFor(BuddyId buddy) =>
      'assets/buddies/launcher/${buddy.id}.png';

  /// v12: stage sprite path for the 5-stage evolution arc. Stage is
  /// 0-indexed; assets are 1-indexed on disk. Returns null when the
  /// species has no stage art bundled (cat/dog/butterfly).
  static String? stageFor(BuddyId buddy, int stage) {
    if (!buddy.hasStages) return null;
    final clamped = stage.clamp(0, 4);
    return 'assets/buddies/${buddy.id}/stages/stage_${clamped + 1}.png';
  }
}
