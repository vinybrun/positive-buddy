import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../main.dart' show notificationRefreshTickProvider;
import '../archived/archived_page.dart';
import '../completion/completed_habit_detail_page.dart';
import '../habits/habit_categories.dart';

/// Phase 3 — single retrospective surface. Combines what used to be two
/// separate screens (Insights + Completed) into one scroll: "Active" cards
/// (streak + last 7 dots) followed by a Graduated list.
class WinsPage extends ConsumerWidget {
  const WinsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationRefreshTickProvider);
    final activeAsync = ref.watch(_activeHabitsProvider);
    final completedAsync = ref.watch(_completedHabitsProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Wins')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Text('Active', style: text.titleMedium),
          ),
          activeAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (habits) {
              if (habits.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Log a few Yes responses and they'll start showing up here.",
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [for (final h in habits) _ActiveHabitCard(habit: h)],
              );
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text('Graduated', style: text.titleMedium),
          ),
          completedAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (habits) {
              if (habits.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Nothing graduated yet — a little shelf for the wins, '
                    'waiting to fill.',
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [
                  for (final h in habits) _GraduatedRow(habit: h),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text('Archived', style: text.titleMedium),
          ),
          const _ArchivedStatsCard(),
        ],
      ),
    );
  }
}

class _ArchivedStatsCard extends ConsumerWidget {
  const _ArchivedStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(_archivedGoalsProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return archivedAsync.when(
      loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator()),
      error: (e, _) => Padding(
          padding: const EdgeInsets.all(16), child: Text('$e')),
      data: (goals) {
        if (goals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Nothing archived. When you park a goal, the count lives here.",
              style: text.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          );
        }
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: FutureBuilder<int>(
              future: ref
                  .read(habitRepositoryProvider)
                  .countDeletedHabitsForGoals(
                      goals.map((g) => g.id).toList()),
              builder: (context, snap) {
                final h = snap.data ?? 0;
                final goalStr = goals.length == 1
                    ? '1 goal archived'
                    : '${goals.length} goals archived';
                final habitStr = h == 0
                    ? ''
                    : h == 1
                        ? ' · 1 habit parked'
                        : ' · $h habits parked';
                return Text('$goalStr$habitStr');
              },
            ),
            subtitle: const Text('Tap to view or restore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ArchivedPage(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveHabitCard extends ConsumerWidget {
  const _ActiveHabitCard({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDbProvider);
    final category = HabitCategory.fromId(habit.category);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: FutureBuilder<_InsightData>(
          future: _computeInsight(db, habit.id),
          builder: (context, snap) {
            final data = snap.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(category.icon,
                          color: colors.onPrimaryContainer, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(habit.name, style: text.titleSmall)),
                    if (data != null)
                      Text(
                        data.streak == 0
                            ? '—'
                            : data.streak == 1
                                ? '1 day'
                                : '${data.streak} days',
                        style: text.bodyMedium?.copyWith(color: colors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (data == null)
                  const LinearProgressIndicator()
                else
                  _LastWeekDots(yesDays: data.last7Dots),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LastWeekDots extends StatelessWidget {
  const _LastWeekDots({required this.yesDays});
  final List<bool> yesDays;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labels = _weekdayLabels(DateTime.now());
    return Row(
      children: [
        for (var i = 0; i < yesDays.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 18,
                  decoration: BoxDecoration(
                    color: yesDays[i]
                        ? colors.primary
                        : colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  labels[i],
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static List<String> _weekdayLabels(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final out = <String>[];
    for (var i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      out.add(switch (d.weekday) {
        DateTime.monday => 'M',
        DateTime.tuesday => 'T',
        DateTime.wednesday => 'W',
        DateTime.thursday => 'T',
        DateTime.friday => 'F',
        DateTime.saturday => 'S',
        DateTime.sunday => 'S',
        _ => '?',
      });
    }
    return out;
  }
}

class _GraduatedRow extends StatelessWidget {
  const _GraduatedRow({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final daysAgo = habit.completedAt == null
        ? null
        : DateTime.now().difference(habit.completedAt!).inDays;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.emoji_events_outlined),
        title: Text(habit.name),
        subtitle: Text(daysAgo == null
            ? 'Graduated'
            : daysAgo == 0
                ? 'Graduated today'
                : 'Graduated ${daysAgo}d ago'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CompletedHabitDetailPage(habitId: habit.id),
          ),
        ),
      ),
    );
  }
}

class _InsightData {
  const _InsightData({
    required this.streak,
    required this.last7Yes,
    required this.last7Dots,
  });
  final int streak;
  final int last7Yes;
  final List<bool> last7Dots;
}

Future<_InsightData> _computeInsight(AppDb db, String habitId) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final since = today.subtract(const Duration(days: 90)).toUtc();
  final rows = await (db.select(db.notificationLog)
        ..where((l) =>
            l.habitId.equals(habitId) &
            l.response.equals('yes') &
            l.respondedAt.isBiggerOrEqualValue(since))
        ..orderBy([(l) => OrderingTerm.desc(l.respondedAt)]))
      .get();
  final yesDays = <DateTime>{};
  for (final r in rows) {
    final t = r.respondedAt?.toLocal();
    if (t == null) continue;
    yesDays.add(DateTime(t.year, t.month, t.day));
  }
  var streak = 0;
  var cursor = today;
  while (yesDays.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  final dots = <bool>[];
  var weekYes = 0;
  for (var i = 6; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    final hit = yesDays.contains(d);
    dots.add(hit);
    if (hit) weekYes += 1;
  }
  return _InsightData(streak: streak, last7Yes: weekYes, last7Dots: dots);
}

final _activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  // Same filter as Today: active, not soft-deleted, not graduated.
  return ref.watch(habitRepositoryProvider).watchAll();
});

final _completedHabitsProvider = StreamProvider<List<Habit>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(habitRepositoryProvider).watchCompleted();
});

final _archivedGoalsProvider = StreamProvider<List<Goal>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(goalRepositoryProvider).watchArchived();
});
