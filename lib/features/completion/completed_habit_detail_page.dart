import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../theme/buddy.dart';
import '../../theme/buddy_asset.dart';
import 'completion_service.dart';

/// Phase 5 — throwback view for a graduated habit. Shows the dot grid
/// of consistency, days-to-master, and a "Share" button that renders
/// the celebration card to PNG and pipes it to the OS share sheet.
class CompletedHabitDetailPage extends ConsumerStatefulWidget {
  const CompletedHabitDetailPage({super.key, required this.habitId});
  final String habitId;

  @override
  ConsumerState<CompletedHabitDetailPage> createState() =>
      _CompletedHabitDetailPageState();
}

class _CompletedHabitDetailPageState
    extends ConsumerState<CompletedHabitDetailPage> {
  final GlobalKey _captureKey = GlobalKey();

  Future<void> _share() async {
    final boundary = _captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final stamp =
        DateTime.now().millisecondsSinceEpoch.toString();
    final file = await File('${dir.path}/positive_buddy_win_$stamp.png')
        .writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: 'Just graduated a habit with Positive Buddy 🎉',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = UserSettings.fromRow(
        ref.watch(userProfileProvider).value);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Throwback'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share),
            onPressed: _share,
          ),
        ],
      ),
      body: FutureBuilder<Habit?>(
        future: ref.read(habitRepositoryProvider).getById(widget.habitId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final habit = snap.data;
          if (habit == null) {
            return const Center(child: Text('Habit not found.'));
          }
          return FutureBuilder(
            future: ref
                .read(completionServiceProvider)
                .dailyHistory(habit.id, days: 90),
            builder: (context, histSnap) {
              if (!histSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final history = histSnap.data!;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  RepaintBoundary(
                    key: _captureKey,
                    child: _ShareCard(
                      habit: habit,
                      history: history,
                      buddy: settings.selectedBuddy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share this win'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.habit,
    required this.history,
    required this.buddy,
  });
  final Habit habit;
  final List history; // List<DailyOutcome>
  final BuddyId? buddy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final yesCount = history.where((d) => d.didYes as bool).length;
    final totalDays = history.length;
    final daysToMaster =
        habit.completedAt?.difference(habit.createdAt).inDays;
    // Find longest streak.
    var longest = 0;
    var run = 0;
    for (final d in history) {
      if (d.didYes as bool) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 0;
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.1),
            colors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (buddy != null)
                Image.asset(
                  BuddyAsset.forPose(buddy!, BuddyPose.cheer),
                  width: 56,
                  height: 56,
                ),
              if (buddy != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Graduated 🎓',
                        style: text.labelLarge
                            ?.copyWith(color: colors.primary)),
                    Text(habit.name, style: text.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Days kept', value: '$yesCount / $totalDays'),
              _StatChip(label: 'Longest streak', value: '$longest'),
              if (daysToMaster != null)
                _StatChip(
                    label: 'Time to graduate', value: '${daysToMaster}d'),
            ],
          ),
          const SizedBox(height: 16),
          _DotGrid(history: history),
          const SizedBox(height: 12),
          Text(
            'Made with Positive Buddy',
            style: text.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: text.headlineSmall),
        Text(label,
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}

class _DotGrid extends StatelessWidget {
  const _DotGrid({required this.history});
  final List history;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Render as a grid of small dots, 14 per row (~2 weeks per row),
    // most-recent-on-bottom.
    final rows = <Widget>[];
    const perRow = 14;
    for (var i = 0; i < history.length; i += perRow) {
      final slice = history.skip(i).take(perRow).toList();
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            for (final d in slice)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (d.didYes as bool)
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                ),
              ),
          ],
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

