import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/profile_repository.dart';
import '../../theme/buddy.dart';
import '../../theme/buddy_asset.dart';
import '../../theme/buddy_themes.dart';
import '../../theme/theme_palettes.dart';
import '../buddy_progress/buddy_progress_repository.dart';
import '../buddy_progress/buddy_scoring_engine.dart';

/// Picker of the available buddies.
///
/// In **compact** mode the cards are sized to fit a phone-sized viewport
/// without scrolling. Compact mode also collapses the roster: only the
/// "featured" buddies (the ones with the new stage-evolution arc) sit
/// in the top row, with a **More +** tile that reveals the rest in an
/// expandable second row. Designed so we can add buddies later without
/// breaking the layout — only the first three slots are visible by
/// default, and the rest hide behind the toggle.
class BuddyPickerRow extends ConsumerStatefulWidget {
  const BuddyPickerRow({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
    this.order,
  });

  final BuddyId? selected;
  final ValueChanged<BuddyId> onSelected;
  final bool compact;

  /// Full roster order for the compact layout. The first [_featuredCount]
  /// entries show in the always-visible row; the rest hide behind "More".
  /// Null falls back to the built-in order. Reordering is persisted by the
  /// picker itself (see [_settle]).
  final List<BuddyId>? order;

  @override
  ConsumerState<BuddyPickerRow> createState() => _BuddyPickerRowState();
}

class _BuddyPickerRowState extends ConsumerState<BuddyPickerRow>
    with WidgetsBindingObserver {
  // Number of buddies shown in the always-visible featured row.
  static const _featuredCount = 3;

  // Default to expanded if the current selection lives behind "More" —
  // otherwise the picker would silently hide which buddy is in use.
  bool _expanded = false;

  // Buddy we've already floated to the front this session, so repeated
  // settle events (More-close, then app-pause, then dispose) don't each
  // re-write the same order. Cleared when the selection changes.
  BuddyId? _floated;

  // Captured plain reference to the repo so [_settle] can persist from
  // dispose() without touching `ref` after the element is torn down.
  ProfileRepository? _repo;

  /// Effective, sanitized full roster order.
  List<BuddyId> get _order {
    final given = widget.order;
    if (given == null || given.isEmpty) return _defaultOrder;
    final seen = <BuddyId>[];
    for (final b in given) {
      if (!seen.contains(b)) seen.add(b);
    }
    for (final b in _defaultOrder) {
      if (!seen.contains(b)) seen.add(b);
    }
    return seen;
  }

  static List<BuddyId> get _defaultOrder => [
        ...BuddyId.values.where((b) => b.hasStages),
        ...BuddyId.values.where((b) => !b.hasStages),
      ];

  /// True when [buddy] would be hidden behind the "More" tray given the
  /// current order (i.e. it's not in the featured slots).
  bool _isHidden(BuddyId? buddy) {
    if (buddy == null) return false;
    final i = _order.indexOf(buddy);
    return i < 0 || i >= _featuredCount;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_isHidden(widget.selected)) _expanded = true;
  }

  @override
  void didUpdateWidget(covariant BuddyPickerRow old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) _floated = null;
    if (_isHidden(widget.selected) && !_expanded) {
      setState(() => _expanded = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app counts as "the user stopped" — safe to settle the
    // order even if the More tray is still open.
    if (state == AppLifecycleState.paused) _settle();
  }

  @override
  void dispose() {
    // Leaving the page is also a settle point.
    _settle();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// If the selected buddy is currently hidden behind "More", float it to
  /// the front of the persisted order so it's visible next time. Called
  /// only on settle events (More closed, page left, app paused) — never
  /// while the user is still poking around an open tray.
  void _settle() {
    final sel = widget.selected;
    if (sel == null || sel == _floated) return;
    final order = _order;
    final idx = order.indexOf(sel);
    if (idx >= 0 && idx < _featuredCount) return; // already visible
    _floated = sel;
    final reordered = [sel, ...order.where((b) => b != sel)];
    // Fire-and-forget; the userProfile stream rebuilds the picker with the
    // new order. Uses the captured repo so this is safe from dispose().
    _repo?.updateSettings(
      buddyOrderJson: UserSettings.encodeBuddyOrder(reordered),
    );
  }

  @override
  Widget build(BuildContext context) {
    _repo = ref.read(profileRepositoryProvider);
    if (!widget.compact) {
      // Full mode: original horizontal-scroll behavior, no collapsing.
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final b in BuddyId.values)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BuddyCard(
                  buddy: b,
                  selected: widget.selected == b,
                  onTap: () => widget.onSelected(b),
                  compact: false,
                ),
              ),
          ],
        ),
      );
    }

    // Compact mode: featured row + optional expanded extras row.
    final order = _order;
    final featured = order.take(_featuredCount).toList();
    final extras = order.skip(_featuredCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final b in featured)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _BuddyCard(
                    buddy: b,
                    selected: widget.selected == b,
                    onTap: () => widget.onSelected(b),
                    compact: true,
                  ),
                ),
              ),
            // "More +" tile — proportional with the buddy slots so the
            // grid stays even. Tap toggles the expanded row.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _MoreCard(
                  expanded: _expanded,
                  onTap: () {
                    final closing = _expanded;
                    setState(() => _expanded = !_expanded);
                    // Closing the tray is a settle point: float the chosen
                    // buddy up so it's visible without re-opening More.
                    if (closing) _settle();
                  },
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      for (final b in extras)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _BuddyCard(
                              buddy: b,
                              selected: widget.selected == b,
                              onTap: () => widget.onSelected(b),
                              compact: true,
                            ),
                          ),
                        ),
                      // Pad with empty slots so each card matches the
                      // width of the featured row's tiles — keeps the
                      // grid visually aligned no matter how many extras
                      // there are.
                      for (var i = extras.length; i < featured.length + 1; i++)
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BuddyCard extends ConsumerWidget {
  const _BuddyCard({
    required this.buddy,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final BuddyId buddy;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final defaultPalette = buddyDefaultThemes[buddy]!.light;
    final paletteSeed = palettes[defaultPalette]!.seed;
    final progressAsync = ref.watch(_progressForProvider(buddy));
    final maxStage = progressAsync.value?.maxStageReached ?? 0;
    final totalScore = progressAsync.value?.totalScore ?? 0;
    // Evolution ring only makes sense for species that actually evolve.
    final showRing = buddy.hasStages;
    final ringProgress = BuddyScoringEngine.progressToNextStage(totalScore);
    final spritePath = BuddyAsset.stageFor(buddy, maxStage) ??
        BuddyAsset.forPose(buddy, BuddyPose.idle);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: compact
            ? const EdgeInsets.fromLTRB(4, 6, 4, 6)
            : const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : null,
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (ctx, constraints) {
                final tile = compact
                    ? constraints.maxWidth.clamp(40.0, 80.0)
                    : 96.0;
                // Inset the avatar so the progress ring sits just outside
                // it rather than overlapping the artwork.
                final stroke = (tile * 0.06).clamp(3.0, 5.0);
                final inset = showRing ? stroke + 3 : 0.0;
                final avatar = tile - inset * 2;
                final circle = Container(
                  width: avatar,
                  height: avatar,
                  decoration: BoxDecoration(
                    color: paletteSeed.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    spritePath,
                    width: avatar,
                    height: avatar,
                    fit: BoxFit.cover,
                  ),
                );
                if (!showRing) return circle;
                // Ring color is the BUDDY'S own brand color, deliberately
                // independent of the active theme primary — it reads as
                // "this creature's growth", not "the app's accent".
                return SizedBox(
                  width: tile,
                  height: tile,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(tile, tile),
                        painter: _EvolutionRingPainter(
                          progress: ringProgress,
                          color: paletteSeed,
                          stroke: stroke,
                        ),
                      ),
                      circle,
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              buddy.label,
              style: (compact ? text.labelMedium : text.labelLarge)?.copyWith(
                color: selected ? colors.primary : null,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.expanded, required this.onTap});
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (ctx, constraints) {
                final tile = constraints.maxWidth.clamp(40.0, 80.0);
                return Container(
                  width: tile,
                  height: tile,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    expanded ? Icons.expand_less : Icons.add,
                    size: (tile * 0.5).clamp(20.0, 40.0),
                    color: colors.onSurfaceVariant,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              'More',
              style: text.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Border ring drawn around an evolving buddy's avatar. A faint full-circle
/// track plus a brighter arc that sweeps from the top clockwise in
/// proportion to how close the buddy is to its next evolution. At 1.0 the
/// arc closes into a full ring — the "fully evolved" badge.
class _EvolutionRingPainter extends CustomPainter {
  const _EvolutionRingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress; // 0..1
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      rect,
      -math.pi / 2, // start at 12 o'clock
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_EvolutionRingPainter old) =>
      old.progress != progress || old.color != color || old.stroke != stroke;
}

/// Per-buddy progress lookup. A FutureProvider (not Stream) so widget
/// tests don't leave dangling drift watchers — the picker doesn't need
/// the real-time updates that the Today header does; cards only refresh
/// when their dependents (notificationRefreshTick) bump.
final _progressForProvider =
    FutureProvider.family<BuddyProgressData?, BuddyId>((ref, buddy) {
  return ref.watch(buddyProgressRepositoryProvider).read(buddy);
});
