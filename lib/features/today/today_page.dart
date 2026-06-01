import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/log_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../main.dart' show notificationRefreshTickProvider;
import '../../personalization/buddy_voice.dart';
import '../../theme/buddy.dart';
import '../../theme/buddy_asset.dart';
import '../buddy_progress/buddy_progress_repository.dart';
import '../completion/graduation_prompt_card.dart';
import '../debug/debug_page.dart';
import '../habits/edit_habit_page.dart';
import '../habits/habit_categories.dart';
import '../plan/plan_page.dart';
import '../wins/wins_page.dart';
import '../you/you_page.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(_todayHabitsProvider);
    final goalsAsync = ref.watch(_activeGoalsProvider);
    final logsAsync = ref.watch(_todayLogsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final settings = UserSettings.fromRow(profileAsync.value);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Long-press the bar to reach the dev page. Not user-facing.
        title: GestureDetector(
          onLongPress: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const DebugPage()),
          ),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(width: double.infinity, height: kToolbarHeight),
        ),
        actions: [
          IconButton(
            tooltip: 'Plan',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlanPage()),
            ),
          ),
          IconButton(
            tooltip: 'Wins',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const WinsPage()),
            ),
          ),
          IconButton(
            tooltip: 'You',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YouPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: habitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (habits) {
            final goals = goalsAsync.value ?? const <Goal>[];
            final logs = logsAsync.value ?? const {};
            final pending = habits
                .where((h) => !_isDoneToday(logs[h.habit.id]))
                .length;
            // Group habits by goalId. Phase 1 hides any orphans (no goalId)
            // — Phase 2/5 guarantee every habit lives under a goal going
            // forward. Legacy orphans simply don't render on Today.
            final byGoal = <String, List<HabitWithSlots>>{};
            for (final h in habits) {
              final gid = h.habit.goalId;
              if (gid == null) continue;
              byGoal.putIfAbsent(gid, () => []).add(h);
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _BuddyHero(
                    buddy: settings.selectedBuddy,
                    pendingCount: pending,
                  ),
                ),
                const SliverToBoxAdapter(child: GraduationPromptCard()),
                if (goals.isEmpty)
                  const SliverToBoxAdapter(child: _PlanYourFirstGoalCta()),
                for (final g in goals)
                  SliverToBoxAdapter(
                    child: _GoalSection(
                      goal: g,
                      habits: byGoal[g.id] ?? const [],
                      logs: logs,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BuddyHero extends ConsumerWidget {
  const _BuddyHero({required this.buddy, required this.pendingCount});
  final BuddyId? buddy;
  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(_greetingProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final resolvedBuddy = buddy ?? BuddyId.fox;
    // v12: stage-aware avatar. We watch the buddy's progress row so a
    // fresh stage transition lights up immediately.
    final progressAsync = ref.watch(_buddyProgressProvider(resolvedBuddy));
    final stage = progressAsync.value?.maxStageReached ?? 0;
    final spritePath = BuddyAsset.stageFor(resolvedBuddy, stage) ??
        BuddyAsset.forPose(resolvedBuddy, BuddyPose.idle);
    final stageName = BuddyStage.nameFor(resolvedBuddy, stage);
    final greetingLine = stageName == null
        ? greeting
        : '$greeting · ${resolvedBuddy.label} the $stageName';
    final subtitle = pendingCount == 0
        ? 'All clear for today.'
        : greetingFor(resolvedBuddy, pendingCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Primary-tinted circle behind the buddy so the chosen accent
          // color shows up on the main canvas — without this the buddy
          // floats in the void and the primary picker feels disconnected.
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer,
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              spritePath,
              height: 92,
              width: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greetingLine, style: text.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: text.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-buddy progress stream for the Today header. Drift's stream will
/// re-emit on every commit to `buddy_progress`, so an end-of-day
/// reconcile lights up the next stage without manual invalidation.
final _buddyProgressProvider =
    StreamProvider.family<BuddyProgressData?, BuddyId>((ref, buddy) {
  return ref.watch(buddyProgressRepositoryProvider).watch(buddy);
});

class _PlanYourFirstGoalCta extends StatelessWidget {
  const _PlanYourFirstGoalCta();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Card(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PlanPage()),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: colors.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan your first goal',
                          style: text.titleMedium),
                      Text(
                        'Habits live under goals. Add one to get started.',
                        style: text.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({
    required this.goal,
    required this.habits,
    required this.logs,
  });

  final Goal goal;
  final List<HabitWithSlots> habits;
  final Map<String, NotificationLogData> logs;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final doneToday =
        habits.where((h) => _isDoneToday(logs[h.habit.id])).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(goal.title, style: text.titleSmall),
                ),
                if (habits.isNotEmpty)
                  Text(
                    '$doneToday / ${habits.length}',
                    style: text.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                'No habits here yet — open Plan to add one.',
                style: text.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          for (final h in habits)
            _HabitTile(entry: h, latestLog: logs[h.habit.id]),
        ],
      ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.entry, required this.latestLog});

  final HabitWithSlots entry;
  final NotificationLogData? latestLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = HabitCategory.fromId(entry.habit.category);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final isDone = _isDoneToday(latestLog);

    return InkWell(
      onTap: () => _showHabitSheet(context, ref, entry, latestLog),
      // Long-press jumps straight to editing the habit.
      onLongPress: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EditHabitPage(habitId: entry.habit.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.primaryContainer,
              child: Icon(category.icon,
                  size: 14, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.habit.name,
                style: text.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              height: 32,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: isDone
                    ? null
                    : () async {
                        await ref.read(logRepositoryProvider).logResponse(
                              habitId: entry.habit.id,
                              response: 'yes',
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(
                              content:
                                  Text(_yesCheerline(entry.habit.name)),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: Text(isDone ? 'Done' : 'Yes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showHabitSheet(
  BuildContext context,
  WidgetRef ref,
  HabitWithSlots entry,
  NotificationLogData? latestLog,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) {
      final text = Theme.of(sheetCtx).textTheme;
      final colors = Theme.of(sheetCtx).colorScheme;
      final isDone = _isDoneToday(latestLog);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.habit.name, style: text.titleLarge),
              const SizedBox(height: 6),
              if (entry.habit.kind == 'freq' &&
                  entry.habit.targetPerWeek != null)
                _WeeklyProgress(
                  habitId: entry.habit.id,
                  target: entry.habit.targetPerWeek!,
                )
              else if (entry.slots.isNotEmpty)
                Text(
                  entry.slots
                      .map((s) {
                        final h = s.timeOfDay ~/ 60;
                        final m = s.timeOfDay % 60;
                        return TimeOfDay(hour: h, minute: m).format(sheetCtx);
                      })
                      .join(' · '),
                  style: text.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              if (latestLog != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusDescription(latestLog),
                  style: text.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await ref.read(logRepositoryProvider).logResponse(
                            habitId: entry.habit.id,
                            response: 'not_yet',
                          );
                      if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('Not yet'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isDone
                        ? null
                        : () async {
                            await ref.read(logRepositoryProvider).logResponse(
                                  habitId: entry.habit.id,
                                  response: 'yes',
                                );
                            if (sheetCtx.mounted) {
                              Navigator.of(sheetCtx).pop();
                            }
                          },
                    child: Text(isDone ? 'Done today' : 'Yes — done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// A habit counts as done today when its latest log is a real completion —
/// an in-app "yes" OR a widget "manual_done" tap. Counters and tile state
/// all route through this so they never disagree (the widget logs
/// manual_done, which used to show "Done" on the tile but not in the count).
bool _isDoneToday(NotificationLogData? log) =>
    log?.response == 'yes' || log?.response == 'manual_done';

String _statusDescription(NotificationLogData l) {
  final t = l.respondedAt?.toLocal();
  final hm = t == null
      ? ''
      : ' at ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  return switch (l.response) {
    'yes' => 'Logged today$hm 🎉',
    'not_yet' => 'Said "not yet"$hm',
    'missed' => 'Missed earlier today',
    'manual_done' => 'Logged manually$hm',
    'expired' => 'Reminder expired',
    _ => l.response,
  };
}

String _yesCheerline(String name) {
  final n = name.trim();
  final lines = [
    'Nice — $n logged 🎉',
    'Boom 💪',
    '$n: done. Proud of you.',
    'Keep that rhythm going 🌟',
    'Solid. Catch you on the next one.',
  ];
  return lines[DateTime.now().microsecondsSinceEpoch.abs() % lines.length];
}

class _WeeklyProgress extends ConsumerWidget {
  const _WeeklyProgress({required this.habitId, required this.target});
  final String habitId;
  final int target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationRefreshTickProvider);
    final repo = ref.watch(habitRepositoryProvider);
    final stream = repo.watchWeeklyYesCount(habitId);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final done = snap.data ?? 0;
        final pct = (target == 0) ? 0.0 : (done / target).clamp(0.0, 1.0);
        final reached = done >= target;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reached
                  ? "$done / $target this week 🎉 you smashed it"
                  : "$done / $target this week",
              style: text.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }
}

final _greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 5) return 'Up late — hey there.';
  if (hour < 12) return 'Morning, friend.';
  if (hour < 17) return 'Hey — good to see you.';
  if (hour < 21) return 'Evening check-in.';
  return 'Wind-down time. Hi.';
});

final _todayHabitsProvider = StreamProvider<List<HabitWithSlots>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(habitRepositoryProvider).watchActiveWithSlots();
});

final _activeGoalsProvider = StreamProvider<List<Goal>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(goalRepositoryProvider).watchActive();
});

final _todayLogsProvider =
    StreamProvider<Map<String, NotificationLogData>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(logRepositoryProvider).watchTodayLogsByHabit();
});
